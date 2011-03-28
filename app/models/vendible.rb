class Vendible < ActiveRecord::Base
  belongs_to :product
  has_and_belongs_to_many :option_values
end

=begin
STUFF TO DO LATER
  status (:active, :inactive, :discontinued)
  inventory (backorder, returns, available)
  cart interface
  images
  pricing (retail, cost, profit?)
  scopes
  shipping details (weight, height, width, depth)
  display
=end
