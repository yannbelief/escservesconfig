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

class Environment < Sequel::Model(:environments)
    plugin :validation_class_methods
    plugin :schema
    plugin :hook_class_methods

    many_to_many :appversions, :class => :Appversion
    many_to_one :owner, :class => :Owner
    one_to_many :values, :class => :Value

    set_schema do
        primary_key :id, :null => false
        String :name
        column :public_key, File
        column :private_key, File

        foreign_key :owner_id, :table => :owners, :type => Integer
    end

    validates_uniqueness_of :name

    before_create do |env|
        env.owner_id = 1
    end
    
    def self.default
        Environment[:name => "default"]
    end
    
    def has_version(version)
      self.appversions.find { |v| v[:id] == version[:id]}
    end
    
    def default?
      self[:id] == Environment.default[:id]
    end
    
    def apps
        apps = Array.new
        self.appversions.each do |appversion|
            apps.push(appversion.app) unless apps.include? appversion.app
        end
        apps
    end
    
    def createCryptoKeys()
      key = OpenSSL::PKey::RSA.generate(256)
      public_key = key.public_key.to_pem
      private_key = key.to_pem 
      self.update(:public_key => public_key, :private_key => private_key)
    end
    
    def copy(name)
      DB.transaction do
        newEnv = Environment.create(:name => name)
        newEnv.createCryptoKeys() unless self.default?     
      
        srcEnvId = self[:id]
        destEnvId = newEnv[:id]
        # Copy versions into new env
        self.appversions.each do |existingAppVersion|
          newEnv.add_appversion(existingAppVersion)
          # Copy overridden values
          existingAppVersion.all_keys.each do |key|
              value = Value[:key_id => key[:id], :appversion_id => existingAppVersion[:id], :environment_id => srcEnvId]
              Value.create(:key_id => key[:id], :appversion_id => existingAppVersion[:id], :environment_id => destEnvId, :value => value[:value], :is_encrypted => value[:is_encrypted]) unless value.nil?
          end
        end
        newEnv
      end
    end
end

EscData.init_model(Environment)

if Environment[:name => 'default'].nil?
    Environment.create(:name => 'default')
end

