class ActiveProductProductsBaseMigration < ActiveRecord::Migration

  def self.up
    create_table :products, :force => true do |t|
      t.string   :name,     :default => "", :null => false
      t.text     :description
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_index :products, [:name], :name => "index_products_on_name"
  end #self.up

  def self.down
    remove_table :products
  end
end

=begin
REMOVED STUFF
      t.string   "permalink"
      t.datetime "available_on"
      t.integer  "tax_category_id"
      t.integer  "shipping_category_id"
      t.integer  :count_on_hand, :default => 0, :null => false
      t.datetime "deleted_at"
      t.string   "meta_description"
      t.string   "meta_keywords"
    add_index "products", ["available_on"], :name => "index_products_on_available_on"
    add_index "products", ["permalink"], :name => "index_products_on_permalink"
    add_index "products", ["deleted_at"], :name => "index_products_on_deleted_at"
=end
