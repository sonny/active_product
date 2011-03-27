# PRODUCTS
# Products represent an entity for sale in a store.
# Products can have variations, called variants
# Products properties include description, permalink, availability,
#   shipping category, etc. that do not change by variant.
#
# MASTER VARIANT
# Every product has one master variant, which stores master price and sku, size and weight, etc.
# The master variant does not have option values associated with it.
# Price, SKU, size, weight, etc. are all delegated to the master variant.
# Contains on_hand inventory levels only when there are no variants for the product.
#
# VARIANTS
# All variants can access the product properties directly (via reverse delegation).
# Inventory units are tied to Variant.
# The master variant can have inventory units, but not option values.
# All other variants have option values and may have inventory units.
# Sum of on_hand each variant's inventory level determine "on_hand" level for the product.
#
class Product < ActiveRecord::Base
  include ActiveProduct::Product::Unimplemented
  include ActiveProduct::Product::Deprecated

=begin
  has_many :product_option_types, :dependent => :destroy
  has_many :option_types, :through => :product_option_types
  has_many :product_properties, :dependent => :destroy
  has_many :properties, :through => :product_properties
  has_many :images, :as => :viewable, :order => :position, :dependent => :destroy
=end
  has_and_belongs_to_many :product_groups
=begin
  belongs_to :tax_category
  has_and_belongs_to_many :taxons
  belongs_to :shipping_category
=end
  has_one :master,
    :class_name => 'Variant',
    :conditions => ["variants.is_master = ? AND variants.deleted_at IS NULL", true]

  delegate_belongs_to :master, :sku, :price, :weight, :height, :width, :depth, :is_master
  delegate_belongs_to :master, :cost_price if Variant.table_exists? && Variant.column_names.include?("cost_price")

  after_create :set_master_variant_defaults
#  after_create :add_properties_and_option_types_from_prototype
#  before_create :ensure_master
  before_save :recalculate_count_on_hand
  after_save :update_memberships if ProductGroup.table_exists?
  after_save :set_master_on_hand_to_zero_when_product_has_variants
  after_save :save_master

  has_many :variants,
    :conditions => ["variants.is_master = ? AND variants.deleted_at IS NULL", false],
    :order => 'variants.position ASC'


  has_many :variants_including_master,
    :class_name => 'Variant',
    :conditions => ["variants.deleted_at IS NULL"],
    :dependent => :destroy

  has_many :variants_with_only_master,
    :class_name => 'Variant',
    :conditions => ["variants.deleted_at IS NULL AND variants.is_master = ?", true],
    :dependent => :destroy

  validates :name, :price, :permalink, :presence => true
=begin
  accepts_nested_attributes_for :product_properties, :allow_destroy => true, :reject_if => lambda { |pp| pp[:property_name].blank? }

  make_permalink if Product.respond_to? :make_permalink

  alias :options :product_option_types

  include ::Scopes::Product

  #RAILS3 TODO -  scopes are duplicated here and in scopres/product.rb - can we DRY it up?
  # default product scope only lists available and non-deleted products
  scope :not_deleted,     where("products.deleted_at is NULL")

  scope :available,       lambda { |*on| where("products.available_on <= ?", on.first || Time.zone.now ) }

  #RAILS 3 TODO - this scope doesn't match the original 2.3.x version, needs attention (but it works)
  scope :active,          not_deleted.available

  scope :on_hand,         where("products.count_on_hand > 0")

  if (ActiveRecord::Base.connection.adapter_name == 'PostgreSQL')
    if ActiveRecord::Base.connection.tables.include?("products")
      scope :group_by_products_id, { :group => "products." + Product.column_names.join(", products.") }
    end
  else
    scope :group_by_products_id, { :group => "products.id" }
  end

  if self.respond_to? :search_methods
    search_methods :group_by_products_id 
  end

  scope :id_equals, lambda { |input_id| where("products.id = ?", input_id) }

  scope :taxons_name_eq, lambda { |name| joins(:taxons).where("taxons.name = ?", name) }

  def to_param
    return permalink if permalink.present?
    name.to_url
  end
=end
  # returns true if the product has any variants (the master variant is not a member of the variants array)
  def has_variants?
    !variants.empty?
  end
=begin
  # returns the number of inventory units "on_hand" for this product
  def on_hand
    has_variants? ? variants.inject(0){|sum, v| sum + v.on_hand} : master.on_hand
  end

  # adjusts the "on_hand" inventory level for the product up or down to match the given new_level
  def on_hand=(new_level)
    raise "cannot set on_hand of product with variants" if has_variants? && Spree::Config[:track_inventory_levels]
    master.on_hand = new_level
  end

  # Returns true if there are inventory units (any variant) with "on_hand" state for this product
  def has_stock?
    master.in_stock? || !!variants.detect{|v| v.in_stock?}
  end

  def tax_category
    if self[:tax_category_id].nil?
      TaxCategory.first(:conditions => {:is_default => true})
    else
      TaxCategory.find(self[:tax_category_id])
    end
  end

  # Adding properties and option types on creation based on a chosen prototype
  attr_reader :prototype_id
  def prototype_id=(value)
    @prototype_id = value.to_i
  end

  def add_properties_and_option_types_from_prototype
    if prototype_id && prototype = Prototype.find_by_id(prototype_id)
      prototype.properties.each do |property|
        product_properties.create(:property => property)
      end
      self.option_types = prototype.option_types
    end
  end

  # for adding products which are closely related to existing ones
  # define "duplicate_extra" for site-specific actions, eg for additional fields
  def duplicate
    p = self.clone
    p.name = 'COPY OF ' + self.name
    p.deleted_at = nil
    p.created_at = p.updated_at = nil
    p.taxons = self.taxons

    p.product_properties = self.product_properties.map {|q| r = q.clone; r.created_at = r.updated_at = nil; r}

    image_clone = lambda {|i| j = i.clone; j.attachment = i.attachment.clone; j}
    p.images = self.images.map {|i| image_clone.call i}

    variant = self.master.clone
    variant.sku = 'COPY OF ' + self.master.sku
    variant.deleted_at = nil
    variant.images = self.master.images.map {|i| image_clone.call i}
    p.master = variant

    if self.has_variants?
      # don't clone the actual variants, just the characterising types
      p.option_types = self.option_types
    else
    end
    # allow site to do some customization
    p.send(:duplicate_extra) if p.respond_to?(:duplicate_extra)
    p.save!
    p
  end

  # use deleted? rather than checking the attribute directly. this
  # allows extensions to override deleted? if they want to provide
  # their own definition.
  def deleted?
    !!deleted_at
  end

  # split variants list into hash which shows mapping of opt value onto matching variants
  # eg categorise_variants_from_option(color) => {"red" -> [...], "blue" -> [...]}
  def categorise_variants_from_option(opt_type)
    return {} unless option_types.include?(opt_type)
    variants.active.group_by {|v| v.option_values.detect {|o| o.option_type == opt_type} }
  end

  def self.like_any(fields, values)
    like = ActiveRecord::Base.connection.adapter_name == 'PostgreSQL' ? 'ILIKE' : 'LIKE'
    where_str = fields.map{|field| Array.new(values.size, "products.#{field} #{like} ?").join(' OR ') }.join(' OR ')
    self.where([where_str, values.map{|value| "%#{value}%"} * fields.size].flatten)
  end
=end
  private

  def recalculate_count_on_hand
    product_count_on_hand = has_variants? ?
        variants.inject(0) {|acc, v| acc + v.count_on_hand} :
        (master ? master.count_on_hand : 0)
    self.count_on_hand = product_count_on_hand
  end

  # the master on_hand is meaningless once a product has variants as the inventory
  # units are now "contained" within the product variants
  def set_master_on_hand_to_zero_when_product_has_variants
    master.on_hand = 0 if has_variants? && 
      ActiveProduct::Engine.config.track_inventory_levels
  end

  # ensures the master variant is flagged as such
  def set_master_variant_defaults
    master.is_master = true
  end

  # there's a weird quirk with the delegate stuff that does not automatically save the delegate object
  # when saving so we force a save using a hook.
  def save_master
    master.save if master && (master.changed? || master.new_record?)
  end

  def update_memberships
    self.product_groups = ProductGroup.all.select{|pg| pg.include?(self)}
  end

end
