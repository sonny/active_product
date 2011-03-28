module ActiveProduct
  module Product
    module Status
      def self.included(base)
        base.extend ClassConfig
        base.send :include, InstanceConfig
      end

      module ClassConfig
        def statuses
          [:active, :inactive, :pending]
        end
      end

      module InstanceConfig
      end
    end
  end
end
