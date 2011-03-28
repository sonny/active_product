class ActiveProductBaseMigration < ActiveRecord::Migration

  def self.up

    create_table :option_types, :force => true do |t|
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :option_values, :force => true do |t|
      t.integer  :option_type_id
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :product_option_types, :force => true do |t|
      t.integer  :product_id
      t.integer  :option_type_id
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :vendibles, :force => true do |t|
      t.integer  :product_id
      t.string   :sku,        :null => false
      t.decimal  :price,      :precision => 8, :scale => 2, :null => false
    end

    add_index :vendibles, [:product_id], :name => "index_vendibles_on_product_id"

    create_table :option_values_vendibles, :id => false, :force => true do |t|
      t.integer :vendible_id
      t.integer :option_value_id
    end

    add_index :option_values_vendibles, [:vendible_id]
    add_index :option_values_vendibles, [:vendible_id, :option_value_id]
  end
  def self.down
    [ :option_values_vendibles,
      :vendibles,
      :product_option_types,
      :option_types,
      :option_values,
      :products ].each { |t| remove_table t }
  end
end


=begin
option_types
      t.string   :presentation
      t.integer  :position, :default => 0, :null => false

option_values
      t.integer  "position"
      t.string   "presentation"

product_option_types
      t.integer  :position

vendibles
      t.decimal  :weight,     :precision => 8, :scale => 2
      t.decimal  :height,     :precision => 8, :scale => 2
      t.decimal  :width,      :precision => 8, :scale => 2
      t.decimal  :depth,      :precision => 8, :scale => 2
      t.decimal  :cost_price, :precision => 8, :scale => 2, :default => nil, :null => true
      t.integer  :count_on_hand, :default => 0, :null => false

      t.integer  :position
      t.datetime :deleted_at
      t.boolean  :is_master, :default => false

=end
