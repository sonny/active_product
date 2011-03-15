class ActiveProductBaseMigration < ActiveRecord::Migration

  def self.up

    create_table "assets", :force => true do |t|
      t.integer  "viewable_id"
      t.string   "viewable_type", :limit => 50
      t.string   "attachment_content_type"
      t.string   "attachment_file_name"
      t.integer  "attachment_size"
      t.integer  "position"
      t.string   "type", :limit => 75
      t.datetime "attachment_updated_at"
      t.integer  "attachment_width"
      t.integer  "attachment_height"
      t.text     :alt
    end

    add_index(:assets, :viewable_id)
    add_index(:assets, [:viewable_type, :type])

    create_table "inventory_units", :force => true do |t|
      t.integer  "variant_id"
      t.integer  "order_id"
      t.string   "state"
      t.integer  "lock_version", :default => 0
      t.integer  :shipment_id
      t.integer  :return_authorization_id
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index(:inventory_units, :variant_id)
    add_index(:inventory_units, :order_id)
    add_index(:inventory_units, :shipment_id)

    create_table "option_types", :force => true do |t|
      t.string   "name",         :limit => 100
      t.string   "presentation", :limit => 100
      t.integer  :position, :default => 0, :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "option_types_prototypes", :id => false, :force => true do |t|
      t.integer "prototype_id"
      t.integer "option_type_id"
    end

    create_table :option_values, :force => true do |t|
      t.integer  "option_type_id"
      t.string   "name"
      t.integer  "position"
      t.string   "presentation"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table :option_values_variants, 
    :id => false, 
    :force => true do |t|
      t.integer :variant_id
      t.integer :option_value_id
    end

    add_index :option_values_variants, ["variant_id"]
    add_index :option_values_variants, [:variant_id, :option_value_id]

    create_table "product_option_types", :force => true do |t|
      t.integer  "product_id"
      t.integer  "option_type_id"
      t.integer  "position"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "product_properties", :force => true do |t|
      t.integer  "product_id"
      t.integer  "property_id"
      t.string   "value"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table(:product_groups) do |t|
      t.column :name,       :string
      t.column :permalink,  :string
      t.column :order,      :string
    end

    create_table :product_groups_products, :id => false do |t|
      t.references :product
      t.references :product_group
    end

    create_table(:product_scopes) do |t|
      t.column :product_group_id, :integer
      t.column :name,             :string
      t.column :arguments,        :text
    end

    add_index :product_groups, :name
    add_index :product_groups, :permalink
    add_index :product_scopes, :name
    add_index :product_scopes, :product_group_id

    create_table "products", :force => true do |t|
      t.string   "name",                 :default => "", :null => false
      t.text     "description"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "permalink"
      t.datetime "available_on"
      t.integer  "tax_category_id"
      t.integer  "shipping_category_id"
      t.integer  :count_on_hand, :default => 0, :null => false
      t.datetime "deleted_at"
      t.string   "meta_description"
      t.string   "meta_keywords"
    end

    add_index "products", ["available_on"], :name => "index_products_on_available_on"
    add_index "products", ["deleted_at"], :name => "index_products_on_deleted_at"
    add_index "products", ["name"], :name => "index_products_on_name"
    add_index "products", ["permalink"], :name => "index_products_on_permalink"

    create_table "properties", :force => true do |t|
      t.string   "name"
      t.string   "presentation", :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "properties_prototypes", :id => false, :force => true do |t|
      t.integer "prototype_id"
      t.integer "property_id"
    end

    create_table "prototypes", :force => true do |t|
      t.string   "name"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table :variants, :force => true do |t|
      t.integer  :product_id
      t.string   :sku, :default => "", :null => false
      t.decimal  :price,      :precision => 8, :scale => 2, :null => false
      t.decimal  :weight,     :precision => 8, :scale => 2
      t.decimal  :height,     :precision => 8, :scale => 2
      t.decimal  :width,      :precision => 8, :scale => 2
      t.decimal  :depth,      :precision => 8, :scale => 2
      t.decimal  :cost_price, :precision => 8, :scale => 2, :default => nil, :null => true
      t.integer  :count_on_hand, :default => 0, :null => false

      t.integer  :position
      t.datetime :deleted_at
      t.boolean  :is_master, :default => false
    end

    add_index "variants", ["product_id"], :name => "index_variants_on_product_id"

  end #self.up

  def self.down
    # wipe the tables
    remove_table :assets
    remove_table :inventory_units
    remove_table :option_values_variants
    remove_table :variants
    remove_table :option_values
    remove_table :product_option_types
    remove_table :option_types
    remove_table :option_types_prototypes
    remove_table :product_scopes
    remove_table :product_groups_products
    remove_table :product_groups
    remove_table :product_properties
    remove_table :properties_prototypes
    remove_table :properties
    remove_table :prototypes
    remove_table :products
  end
end
