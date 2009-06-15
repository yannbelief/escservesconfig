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
class AltUIController < EscController
	map '/altui'
	
#	  layout('index'){|path, wish| wish == 'html' }
	
    def index
    end    
    
    def search(text = "")
        envs = Array.new
        Environment.where('name like ?', '%' + text + '%').each do |env|
            envs.push(env[:name])
        end
        apps = Array.new
        App.where('name like ?', '%' + text + '%').each do |app|
            apps.push(app[:name])
        end
        
        ret = {"apps", apps.sort, "envs", envs.sort};
        response.headers["Content-Type"] = "application/json"
        return ret.to_json
    end
end
