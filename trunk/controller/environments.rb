
require 'json'

class EnvironmentsController < Ramaze::Controller
    map('/environments')

    def index(env = nil, app = nil, key = nil)
        # Getting...
        if request.get?
            # List all environments
            if env.nil?
                listEnvs()
            # List all apps in specified environment
            elsif app.nil?
                listApps(env)
            # List keys and values for app in environment
            elsif key.nil?
                listKeys(env, app)
            # We're getting value for specific key
            else 
                getValue(env, app, key)
            end


        # Setting...
        elsif request.post? || request.put?
            # Undefined
            if env.nil?
                response.status = 400
            # You're putting an env
            elsif app.nil?
                createEnv(env)
            # You're putting an app
            elsif key.nil?
                createApp(env, app)
            # You're putting a value to a key
            else             
                setValue(env, app, key)
            end
        end
    end


    private

    def listEnvs
        envs = Array.new
        Environment.all.each do |env|
            envs.push(env[:name])
        end
        return envs.sort.to_json
    end

    def listApps(env)
        # List all apps in specified environment
        myenv = Environment[:name => env]
        if myenv.nil?
            response.status = 404
        else
            apps = Array.new
            myenv.apps.each do |app|
                apps.push(app[:name])
            end
            return apps.sort.to_json
        end
    end

    
    def listKeys(env, app)
        # List keys and values for app in environment
        myenv = Environment[:name => env]
        myapp = App[:name => app]
        if myenv.nil? || myapp.nil? # Env does not exist
            response.status = 404
        else 
            # TODO: Get the list of keys for the application. Iterate through the list a call getValue(env, app, key). Return the lot
            
        end
    end


    def getValue(env, app, key)
        values = Value[:key => key, :app => App[:name => app][:id], :environment => Environment[:name => env][:id]]
        if values.nil? 
            # Not in the specified env, is it in default?
            values = Value[:key => key, :app => App[:name => app][:id], :environment => Environment[:name => "default"][:id]]
            if values.nil?
                response.status = 404
            else
                return values[:value]
            end
        else
            return values[:value]
        end
    end

    def createEnv(env)
        begin
            Environment.create(:name => env)
            response.status = 201
        rescue
            response.status = 403
        end
    end

    def createApp(env, app)
        begin
            newapp = App.create(:name => app)
            newapp.add_environment(Environment[:name => 'default'])

            if env != 'default'
                newapp.add_environment(Environment[:name => env])
            end

            response.status = 201
        rescue
            response.status = 403
        end
    end

    def setValue(env, app, key)
        value = request.body.read
        #myvalue = Value[:app => App[:name => app][:id], :environment => Environment[:name => env][:id], :key => key]
        myapp = App[:name => app]
        mykey = Key[:name => key, :app_id => myapp[:id]]
        # New one, let's create
        if mykey.nil?
            mykey = Key.create(:name => key, :app_id => myapp[:id])
            Value.create(:key => key, :value => value, :app => App[:name => app][:id], :environment => Environment[:name => env][:id])
            response.status = 201
        # We're updating the config
        else             
            myvalue.update(:value => value)
            response.status = 200
        end
    end
end