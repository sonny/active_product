class Product < ActiveRecord::Base
  include ActiveProduct::Product::Status if ActiveProduct::Engine.config.include_product_status
#  has_many :product_option_types, :dependent => :destroy
#  has_many :option_types, :through => :product_option_types

  has_many :vendibles, :dependent => :destroy

  validates :name, :presence => true
end

=begin
STUFF TO DO LATER
  images
  permalink
  product_groups
  taxes
  shipping
  taxons
  inventory
  pricing
  scopes
  search
=end
