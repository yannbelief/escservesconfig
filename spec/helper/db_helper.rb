
require 'rubygems'

gem 'ramaze', '=2009.06.12'
require 'ramaze'
require 'ramaze/spec'

require __DIR__('../../start')

module DBHelper
    def reset_db
        App.create_table!
        Environment.create_table!
        Owner.create_table!
        Key.create_table!
        Value.create_table!
        AppsEnvironments.create_table!

        if Environment[:name => 'default'].nil?
            Environment.create(:name => 'default')
        end

        if Owner[:name => 'nobody'].nil?
            nobody = Owner.create(:name => 'nobody', :email => 'nobody@nowhere.com', :password => 'nothing')
            nobody.add_environment(Environment[:name => 'default'])
        end
    end

end

shared :db_helper do
    extend DBHelper
end
