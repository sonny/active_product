class ActiveProductProductsStatusMigration < ActiveRecord::Migration
  def self.up
    add_column :products, :status, :string, :default => 'active', :null => false
  end 

  def self.down
    remove_column :products, :status
  end
end
