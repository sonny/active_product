module ActiveProduct::Product
  module Deprecated

    def self.included(base)
      base.extend(ClassMethods)
      base.send :include, InstanceMethods

      base.class_eval do
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def master_price
        warn "[DEPRECATION] `Product.master_price` is deprecated.  Please use `Product.price` instead. (called from #{caller[0]})"
        self.price
      end

      def master_price=(value)
        warn "[DEPRECATION] `Product.master_price=` is deprecated.  Please use `Product.price=` instead. (called from #{caller[0]})"
        self.price = value
      end

      def variants?
        warn "[DEPRECATION] `Product.variants?` is deprecated.  Please use `Product.has_variants?` instead. (called from #{caller[0]})"
        self.has_variants?
      end

      def variant
        warn "[DEPRECATION] `Product.variant` is deprecated.  Please use `Product.master` instead. (called from #{caller[0]})"
        self.master
      end
    end

  end
end
