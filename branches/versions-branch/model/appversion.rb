class Appversion < Sequel::Model(:appversions)
    plugin :validation_class_methods
    plugin :schema
    plugin :hook_class_methods

    many_to_one :parent, :class => :Appversion
    many_to_one :app, :class => :App
    many_to_many :environments, :class => :Environment
    one_to_many :keys, :class => :Key
    one_to_many :values, :class => :Value
    
    set_schema do
      primary_key :id, :null => false
      String :name
      
      foreign_key :app_id, :table => :apps, :type => Integer
      foreign_key :parent_id, :table => :appversions, :type => Integer
    end
        
    after_create do |appversion|
        appversion.add_environment(Environment[:name => 'default'])
    end

    def delete_from_environment(env)
      DB.transaction do
        if self.has_child_versions?
          return false
        end
        if env.default? 
          if self.only_exists_in(env)
            self.remove_environment(env)
            self.delete
            self.app.delete if self.app.versions.size == 0
            return true
          else
            return false
          end
        else
          self.remove_environment(env)
          return true
        end
      end
    end
    
    def delete_key_value(key, env)
        if env.default?
          if self.key_has_non_default_value(key)
            return false
          else
            self.delete_key(key)
            self.delete_value(key, env)
            return true
          end
        else
            return self.delete_value(key, env)
        end
    end
    
    def key_has_non_default_value(key)
      self.environments.each do |appenv|
          if (not Value[:key_id => key[:id], :appversion_id => self[:id], :environment_id => appenv[:id]].nil?) and (appenv.name != "default")
              return true
              break
          end
      end
      return false
    end
    
    def delete_key(key)
        myKey = Key[:name => key[:name], :appversion_id => self[:id]]
        myKey.delete unless myKey.nil?
    end
    
    def delete_value(key, env)
        myValue = Value[:key_id => key[:id], :appversion_id => self[:id], :environment_id => env[:id]]
        if myValue.nil?
          false
        else
          myValue.delete
          true
        end
    end
    
    def only_exists_in(env)
      self.environments.each do |e| 
        if env[:name] != e[:name]
          return false
        end
      end
      return true
    end
    
    def has_child_versions?
      !Appversion[:parent_id => self[:id]].nil?
    end
    
    def find_key(keyName)
        self.all_keys.find { |k| k[:name] == keyName }
    end
    
    def all_keys()
        allKeys = []
        self.keys.each do |key|
            allKeys.push(key)
        end
        if !parent.nil?
            parent.all_keys().each do |pKey|
              k = allKeys.find { |k| k.sameAs(pKey)}
              allKeys.push(pKey) unless !k.nil?
            end
        end
        allKeys
    end
end

EscData.init_model(Appversion)