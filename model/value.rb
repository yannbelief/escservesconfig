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

require 'time'

class Value < Sequel::Model(:values)
    plugin :schema
    plugin :hook_class_methods

    many_to_one :key, :class => :Key
    many_to_one :environment, :class => :Environment

    set_schema do
        primary_key :id, :null => false
        String :value
        Boolean :is_encrypted
        DateTime :modified
        
        foreign_key :key_id, :table => :keys, :type => Integer
        foreign_key :environment_id, :table => :environments, :type => Integer
    end
    
    def before_save
        return false if super == false
        self.modified = Time.now
    end

    def default?
        self[:environment_id] == Environment.default[:id]
    end
end

EscData.init_model(Value)
