#lib/active_product/engine.rb
require "active_product"
require "rails"

module ActiveProduct
  class Engine < Rails::Engine
    config.autoload_paths += %W(#{config.root}/lib/auto)

    # config options ported from Spree::Config
    config.track_inventory_levels = false
  end
end
