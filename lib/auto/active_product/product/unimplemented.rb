module ActiveProduct::Product
  module Unimplemented

    def self.unimplemented_method(method)
      raise "This method [#{method}] is unimplemented"
    end

    def self.included(base)
      base.extend(ClassMethods)
      base.send :include, InstanceMethods

      base.class_eval do
        self.ui_methods = [:make_permalink, :search_methods]
      end
    end

    module ClassMethods
      attr_accessor :ui_methods

      def respond_to?(sym, include_private=false)
        return respond_to_missing?(sym, include_private) unless 
          !ui_methods.member?(sym)
        super
      end

      def make_permalink(*args)
        Unimplemented.unimplemented_method :make_permalink
      end

      def search_methods(*args)
        Unimplemented.unimplemented_method :search_methods
      end

    end

    module InstanceMethods
    end

  end
end
