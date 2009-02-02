
class AppsEnvironments < Sequel::Model
    set_schema do
        integer :app_id
        integer :environment_id
    end
end

init_model(AppsEnvironments)

class AppsKeys < Sequel::Model
    set_schema do
        integer :app_id
        integer :key_id
    end
end

init_model(AppsKeys)
