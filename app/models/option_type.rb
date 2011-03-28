class OptionType < ActiveRecord::Base
  has_many :option_values, :dependent => :destroy
  has_many :product_option_types, :dependent => :destroy

  validates :name, :presence => true
end

=begin
STUFF TO DO LATER
  sort order
  display
  scope
=end
