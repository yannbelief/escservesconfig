#   Copyright 2009 ThoughtWorks
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

require 'json'
require 'openssl'

class EnvironmentsController < EscController
    map('/environments')

    def index(env = nil, app = nil, key = nil)
        # Sanity check what we've got first
        validate_env_name(env)

        validate_app_name(app)
        
        if key && (not key_name_valid?(key))
            respond("Invalid key name. Valid characters are ., a-z, A-Z, 0-9, _ and -", 403)
        end

        @env = env
        @app = get_app_name(app) unless app.nil?
        @version = get_version_name(app) unless app.nil?
        @version = 'default' if @version.nil?
        @key = key
        
        Ramaze::Log.info "Controller ...Env:#{@env} App:#{@app} Version:#{@version} Key:#{@key}"
        
        # Getting...
        if request.get?
            # List all environments
            if @env.nil?
                listEnvs
            # List all apps in specified environment
            elsif @app.nil?
                listApps
            # List all versions - see versions.rb
            # List keys and values for app version in environment
            elsif @key.nil?
                listKeys
            # We're getting value for specific key
            else 
                getValue
            end

        # Copying...
        elsif request.post?
            # Undefined
            if @env.nil?
                respond("Undefined", 400)
            # You're copying an env
            elsif @app.nil?
                # env is the target, Location Header has the source
                copyEnv
            end

        # Creating...
        elsif request.put?
            # Undefined
            if @env.nil?
                response.status = 400
            # You're creating a new env
            elsif @app.nil?
                createEnv
            # You're creating a new app with default version
            elsif @version.nil?
                createAppVersion
            # You're creating a new app with given version
            elsif @key.nil?
                createAppVersion
            # Key stuff
            else
                setValue
            end

        # Deleting...
        elsif request.delete?
            # Undefined
            if @env.nil?
                response.status = 400
            # You're deleting an env
            elsif @app.nil?
                deleteEnv
            # You're deleting default version of app
            elsif @version.nil?
                deleteAppVersion
            # You're deleting the given app version
            elsif @key.nil?
                deleteAppVersion
            # You're deleting a key
            else             
                deleteKey
            end
        end
    end

    private

    def getEnv(failOnError = true)
      get_env(@env, failOnError)
    end
    
    def getApp(failOnError = true)
      get_app(@app, failOnError)
    end
    
    def getAppversion(failOnError = true)
      get_app_version(@version, failOnError)
    end
    
    def getKey(failOnError = true)
        @myKey = @myAppversion.find_key(@key) unless @myAppversion.nil?
        respond("There is no key '#{@key}' for Application version'#{@app}-#{@version}' in Environment '#{@env}'.", 404) if @myKey.nil? and failOnError
        @keyId = @myKey[:id] unless @myKey.nil?
    end

    #
    # Deletion
    #

    def deleteEnv
        respond("Not allowed to delete default environment!", 403) if @env == "default"
        getEnv
        check_auth(@myEnv.owner.name, "Environment #{@env}")
        @myEnv.delete
        respond("Environment '#{@env}' deleted.", 200)
    end

    def deleteAppVersion
        getEnv
        getApp
        getAppversion
        
        if @myEnv.default?
            if @myAppversion.delete_from_environment(@myEnv)
              respond("Applicaton version '#{@app}-#{@version}' deleted.", 200)
            else
              respond("Applicaton version '#{@app}-#{@version}' could not be deleted. It exists in non-default environments or has child versions.", 403)
            end
        else
            check_auth(@myEnv.owner.name, "Environment #{@env}")
            if @myAppversion.delete_from_environment(@myEnv)
              respond("Application version'#{@app}-#{@version}' deleted from the '#{@env}' environment.", 200)
            else
              respond("Application version'#{@app}-#{@version}' could not be deleted from the '#{@env}' environment. It has child versions.", 403)
            end
        end
    end

    def deleteKey
        getEnv
        getApp
        getAppversion
        getKey

        if @myEnv.default?
            if @myAppversion.delete_key_value(@myKey, @myEnv)
                respond("Key '#{@key}' deleted from application '#{@app}'.", 200)
            else
                respond("Key #{@key} can't be deleted. It has non default values set.", 403)
            end
        else         
            check_auth(@myEnv.owner.name, "Environment #{@env}")
            if @myAppversion.delete_key_value(@myKey, @myEnv)
                respond("Key '#{@key}' deleted from the '#{@env}' environment.", 200)
            else
                respond("Key '#{@key}' has no value in the '#{@env}' environment.", 404)
            end
        end
        
    end

    #
    # Getters
    #

    def listEnvs
        envs = Array.new
        Environment.all.each do |env|
            envs.push(env[:name])
        end
        response.headers["Content-Type"] = "application/json"
        return envs.sort.to_json
    end

    def listApps
        # List all apps in specified environment
        getEnv
        response.headers["Content-Type"] = "application/json"
        return @myEnv.apps.to_json
    end
    
    def listKeys
        # List keys and values for app version in environment
        getEnv
        getApp
        getAppversion
 
        if @myEnv.has_version(@myAppversion)
            pairs = Array.new
            defaults = Array.new
            overrides = Array.new
            encrypted = Array.new
            keyValues = @myApp.all_key_values(@myAppversion, @myEnv)
            keyValues.each do |keyValue|
                defaults.push(keyValue.key) if keyValue.default?
                overrides.push(keyValue.key) if keyValue.overridden?
                encrypted.push(keyValue.key) if keyValue.encrypted?
                pairs.push("#{keyValue.key}=#{keyValue.value.gsub("\n", "")}\n")
            end

            response.headers["Content-Type"] = "text/plain"
            response.headers["X-Default-Values"] = defaults.sort.to_json
            response.headers["X-Override-Values"] = overrides.sort.to_json
            response.headers["X-Encrypted"] = encrypted.sort.to_json
            return pairs.sort
        else
            respond("Application '#{@app}' (version '#{@myAppversion[:name]}') is not included in Environment '#{@env}'.", 404)
        end
    end


    def getValue
        Ramaze::Log.info "getValue:"
        getEnv
        getApp
        getAppversion
        
        if !@myEnv.has_version(@myAppversion)
            respond("Application version'#{@app}-#{@version}' is not included in Environment '#{@env}'.", 404)
        end

        getKey(false)

        value = @myApp.get_key_value(@myKey, @myAppversion, @myEnv)
        if value.nil?
            respond("No default value", 404)
        else
            response.headers["X-Value-Type"] = "default" if value.default?
            response.headers["X-Value-Type"] = "override" if value.overridden?
        end

        if value.encrypted?
            response.headers["Content-Type"] = "application/octet-stream"
            response.headers["Content-Transfer-Encoding"] = "base64"
        else
            response.headers["Content-Type"] = "text/plain"
        end

        return value.value
    end

    #
    # Creaters
    #

    def createEnv
        respond("Environment '#{@env}' already exists.", 200) if Environment[:name => @env]
        DB.transaction do
          @myEnv = Environment.create(:name => @env)
          createCryptoKeys(@env, "pair")
        end   
        respond("Environment created.", 201)
    end

    def createAppVersion
        getEnv
        check_auth(@myEnv.owner.name, "Environment #{@env}")
        getApp(false)
        getAppversion(false)
        parentVersionName = request.body.read
        parentVersionName = 'default' if parentVersionName.empty?
        parentVersion = @myApp.version_by_name(parentVersionName) unless @myApp.nil?
         
        respond("Invalid parent version '#{parentVersionName}'", 200) if parentVersionName != 'default' and parentVersion.nil?
        respond("Application version '#{@version}' already exists in #{@app} in environment '#{@env}'.", 200) if @myAppversion and @myEnv.has_version(@myEnv)
        
        @myAppversion = App.create_version(@app, @version, parentVersion, @myEnv)
        
        respond("Application '#{@app}' with version '#{@version}' with parent '#{parentVersionName}' created in environment '#{@env}'.", 201)
        
    end

    def setValue
        Ramaze::Log.info "SetValue:"
        getEnv
        check_auth(@myEnv.owner.name, "Environment #{@env}")
        getApp
        getAppversion
        
        value = request.body.read
        if request.env['QUERY_STRING'] =~ /encrypt/
            encrypted = true
            # Do some encryption
            public_key = OpenSSL::PKey::RSA.new(@myEnv.public_key)
            encrypted_value = Base64.encode64(public_key.public_encrypt(value)).strip()
            value = encrypted_value
        else
            encrypted = false
        end
        
        if @myApp.set_key_value(@key, @myAppversion, @myEnv, value, encrypted)
          respond("Created key '#{@key}", 201)
        else
          respond("Updated key '#{@key}", 200)
        end
    end
    
    def copyEnv
        respond("Missing Location header. Can't copy environment", 406) unless request.env['HTTP_CONTENT_LOCATION']

        srcEnv = Environment[:name => request.env['HTTP_CONTENT_LOCATION']]
        respond("Source environment '#{request.env['HTTP_CONTENT_LOCATION']}' does not exist.", 404) if srcEnv.nil?

        getEnv(false)
        respond("Target environment #{@env} already exists.", 409) unless @myEnv.nil?

        @myEnv = srcEnv.copy(@env)
        respond("Created copy '#{@env}", 201)
    end
end    

