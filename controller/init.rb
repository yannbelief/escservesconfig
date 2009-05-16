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

require 'openssl'
require 'base64'
require 'md5'

class EscController < Ramaze::Controller
    private

    def validate_env_name(name)
      if name && (not env_name_valid?(name))
          respond("Invalid environment name. Valid characters are ., a-z, A-Z, 0-9, _ and -", 403)
      end
    end
    
    def validate_app_name(name)
      if name && (not app_name_valid?(name))
          respond("Invalid application name. Valid characters are ., a-z, A-Z, 0-9, _ and -", 403)
      end
    end
    
    def app_name_valid?(name)
      name =~ /\A[.a-zA-Z0-9_-]+(#(([0-9]+[.]{1}[0-9]+)|default)){0,1}\Z/
    end
    
    def env_name_valid?(name)
      name =~ /\A[.a-zA-Z0-9_-]+\Z/
    end
    
    def key_name_valid?(name)
      name =~ /\A[.a-zA-Z0-9_-]+\Z/
    end
    
    def get_app_name(name)
        return name.slice(0, name.index('#')) if name.index('#')
        return name
    end
    
    def get_version_name(name)
        name.slice(name.index('#')+1, name.length) unless name.index('#').nil?
    end
    
    def get_env(envName, failOnError)
        @myEnv = Environment[:name => envName]
        respond("Environment '#{envName}' does not exist.", 404) if @myEnv.nil? and failOnError
        @envId = @myEnv[:id] unless @myEnv.nil?
        @defaultId = Environment[:name => "default"][:id]
    end

    def get_app(appName, failOnError)
        @myApp = App[:name => appName]
        respond("Application '#{appName}' does not exist.", 404) if @myApp.nil? and failOnError
        @appId = @myApp[:id] unless @myApp.nil?
    end

    def get_app_version(versionName, failOnError)
          @myAppversion = Appversion[:name => versionName, :app_id =>  @appId]
          respond("Application version'#{versionName}' does not exist.", 404) if @myAppversion.nil? and failOnError
          @appVersionId = @myAppversion[:id] unless @myAppversion.nil?
    end

    def createCryptoKeys(env, pair)
        # Create a keypair
        if env == "default"
            response.status = 401
            return "Default environment doesn't have encryption"
        end
        if pair != "pair"
            response.status = 403
            return "Can only create keys in pairs"
        end
        myenv = Environment[:name => env]
        if myenv.nil?
            response.status = 404
            return "Environment '#{env}' does not exist."
        else
            myenv.createCryptoKeys
            response.status = 201
            response.headers["Content-Type"] = "text/plain" 
            return myenv[:public_key] + "\n" + myenv[:private_key]
        end
    end
  

    def check_auth(id = nil, realm = "")
        if id == "nobody"
            return id
        end

        response['WWW-Authenticate'] = "Basic realm=\"ESCAPE Server - #{realm}\""

        if auth = request.env['HTTP_AUTHORIZATION']
            (user, pass) = Base64.decode64(auth.split(" ")[1]).split(':')
            id = user if id.nil?
            owner = Owner[:name => user]
            if owner && (owner.password == MD5.hexdigest(pass)) && (id == user)
                return user
            end
        end

        respond 'Unauthorized', 401
    end
end

# Here go your requires for subclasses of Controller:
require 'controller/main'
require 'controller/environments'
require 'controller/versions'
require 'controller/crypt'
require 'controller/owner'
require 'controller/user'
require 'controller/auth'

