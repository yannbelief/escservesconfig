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

class VersionsController < EscController
    map('/versions')

    def index(env = nil, app = nil)
       validate_env_name(env)
       validate_app_name(app)
       
       if request.get?
         list_app_versions(env, get_app_name(app))
       elsif request.put?
         add_version_to_env(env, get_app_name(app), get_version_name(app))
       else
         response.status = 400
       end
       
    end
    
    private
    
    def add_version_to_env(envName, appName, versionName)
        get_env(envName, true)
        check_auth(@myEnv.owner.name, "Environment #{envName}")
        get_app(appName, true)
        get_app_version(versionName, true)
        
        @myEnv.add_appversion(@myAppversion)
        respond("Version added.", 200)
    end
    
    def list_app_versions(envName, appName)
        # List all app versions in specified app and environment
        get_env(envName, true)
        get_app(appName, true)

        appVersions = Array.new
        @myEnv.appversions.each do |appversion|
            appVersions.push(appversion[:name])
        end

        response.headers["Content-Type"] = "application/json"
        return appVersions.sort.to_json
    end
end