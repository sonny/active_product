#lib/active_product/engine.rb
require "active_product"
require "rails"

module ActiveProduct
  class Engine < Rails::Engine
    config.autoload_paths += %W(#{config.root}/lib/auto)

  end
end
