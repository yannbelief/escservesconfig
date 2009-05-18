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

require __DIR__('key_value')

require 'json'

class App < Sequel::Model(:apps)
    plugin :validation_class_methods
    plugin :schema
    plugin :hook_class_methods

    one_to_many :versions, :class => :Appversion

    set_schema do
        primary_key :id, :null => false
        String :name
    end

    validates_uniqueness_of :name

    after_create do |app|
       Appversion.create(:name => 'default', :app_id => self[:id]) 
    end
    
    def version_by_name(versionName)
       Appversion[:name => versionName, :app_id => self[:id]]
    end
    
    def default_version()
      self.version_by_name('default')
    end
    
    def to_json()
      versionsInfo = Array.new
      self.versions.each do |v|
        parentName = ''
        parentName = v.parent[:name] unless v.parent.nil?
        versionsInfo.push([v[:name], parentName])
      end
      JSON.generate [self[:name], versionsInfo]
    end
    
    def versions_in_env(env)
      versionsInfo = Array.new
      self.versions.each do |v|
        if env.has_version(v)
          parentName = ''
          parentName = v.parent[:name] unless v.parent.nil?
          versionsInfo.push([v[:name], parentName])
        end
      end
      versionsInfo
    end
    
    def self.create_version(appName, versionName, parentVersion, env)
      DB.transaction do
        theApp = App[:name => appName]
        if theApp.nil?
          theApp = App.create(:name => appName)
        end
        theAppVersion = theApp.version_by_name(versionName) #default version is created when app is created.
        if theAppVersion.nil?
          if parentVersion.nil?
            parent_id = theApp.default_version()[:id]
          else
            parent_id = parentVersion[:id]
          end 
          theAppVersion = Appversion.create(:name => versionName, :app_id => theApp[:id], :parent_id => parent_id)
        end
        env.add_appversion(theAppVersion) if !env.has_version(theAppVersion) 
        theAppVersion
      end
    end

    def all_key_values(version, env)
        keyValues = []
        version.all_keys.each do |key|
          keyValues.push(get_key_value(key, version, env))
        end
        keyValues
    end
    
    def get_key_value(key, version, env)
        # Assume: version must be this app, version must be in env
        # TODO: what if the key was deleted in the version (but existed in parent)
        return nil if key.nil?
        overridden = false
        default = false
        value = Value[:key_id => key[:id], :appversion_id=>version[:id], :environment_id => env[:id]]
        if value.nil?
            if version.parent.nil?
                value = Value[:key_id => key[:id], :appversion_id=>version[:id], :environment_id => Environment.default[:id]] 
                default = true unless value.nil?
            else
                return get_key_value(key, version.parent, env)
            end
        else
            overridden = true
        end
        KeyValue.new(key[:name], value[:value], value[:is_encrypted], overridden, default) unless value.nil?
    end
    
    def set_key_value(keyName, version, env, value, encrypted)
        # Assume: version must be in this app, version must be in env
        myKey = version.find_key(keyName)
        DB.transaction do
          # New one, let's create
          if myKey.nil?
            myKey = Key.create(:name => keyName, :appversion_id => version[:id])
            version.add_key(myKey)
            Value.create(:key_id => myKey[:id], :appversion_id=>version[:id], :environment_id => Environment.default[:id], :value => value, :is_encrypted => encrypted)
            Value.create(:key_id => myKey[:id], :appversion_id=>version[:id], :environment_id => env[:id], :value => value, :is_encrypted => encrypted)
            true
            # We're updating the config
          else           
            myValue = Value[:key_id => myKey[:id], :appversion_id=>version[:id], :environment_id => env[:id]]
            if myValue.nil? # New value...
                Value.create(:key_id => myKey[:id], :appversion_id=>version[:id], :environment_id => env[:id], :value => value, :is_encrypted => encrypted)
                true
            else # Updating the value
                myValue.update(:value => value, :is_encrypted => encrypted)
                false
            end
          end
        end
    end
end

EscData.init_model(App)

