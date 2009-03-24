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

# This controller handles the specific owner of each given environment
class OwnerController < EscController
    map('/owner')

    def index(env = nil)
        # Sanity check what we've got first
        if env && (not env =~ /\A[.a-zA-Z0-9_-]+\Z/)
            respond "Invalid environment name. Valid characters are ., a-z, A-Z, 0-9, _ and -", 403
        end

        # Undefined
        if env.nil?
            respond "Undefined", 400
        end

        # Getting...
        if request.get?
            getOwner(env)
        elsif request.post?
            setOwner(env)
        elsif request.delete?
            clearOwner(env)
        else
            respond "Undefined", 400
        end
    end

    private

    def getOwner(env)
        myEnv = Environment[:name => env]
        
        if myEnv.nil?
            respond "Environment '#{env}' does not exist", 404
        end

        owner = Owner[:id => myEnv.owner_id]

        response.headers["Content-Type"] = "text/plain"   
        return owner.name
    end

    def setOwner(env)
        myEnv = Environment[:name => env]
        
        if myEnv.nil?
            respond "Environment '#{env}' does not exist", 404
        end

        if myEnv.owner_id == 1
            auth = check_auth(nil, env)
        else
            auth = check_auth(myEnv.owner.name, env)
        end

        owner = Owner[:name => auth]

        respond("Owner #{auth} not found", 404) if owner.nil?

        myEnv.owner = owner
        myEnv.save
    end

    def clearOwner(env)
        myEnv = Environment[:name => env]

        if myEnv.nil?
            respond "Environment '#{env}' does not exist", 404
        end

        if myEnv.owner_id == 1
            respond("Environment #{env} is not owned by anyone", 200)
        else
            auth = check_auth(myEnv.owner.name, env)
        end

        myEnv.owner = Owner[:name => "nobody"]
        myEnv.save
    end
    
end
