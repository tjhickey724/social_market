class User < ActiveRecord::Base
   acts_as_authentic
   has_one :portfolio
   has_many :stocks, :through => :portfolios
end
