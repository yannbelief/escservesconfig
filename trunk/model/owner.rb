
class Owner < Sequel::Model(:owners)
    set_schema do
        primary_key :id
        text :email
    end
end

init_model(Owner)

