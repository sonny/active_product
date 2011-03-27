#lib/active_product/engine.rb
require "active_product"
require "rails"

module ActiveProduct
  class Engine < Rails::Engine
    config.autoload_paths += %W(#{config.root}/lib/auto)

    generators do
      # move generators from auto loaded location
      require "#{config.root}/lib/active_product/generators.rb"
    end

    # config options ported from Spree::Config
    config.track_inventory_levels = false


  end
end
