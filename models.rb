require 'bundler/setup'
require 'bcrypt'
Bundler.require

ActiveRecord::Base.establish_connection

class User < ActiveRecord::Base
    has_secure_password
    validates :username, presence: true, uniqueness: true
    validates :password, presence: true
end

class Post < ActiveRecord::Base
    validates :post_title, presence: true
    validates :description, presence: true
end

class Download < ActiveRecord::Base
end