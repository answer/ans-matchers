module Ans
  module Matchers
    def success_persistance_of(attr)
      SuccessPersistanceOf.new attr
    end

    class SuccessPersistanceOf
      attr_reader :failure_message, :negative_failure_message

      def initialize(attribute)
        @attribute = attribute.to_s
        @options = {}
      end

      def values(values)
        @options[:values] = values
        self
      end

      def matches?(subject)
        @subject = subject

        ensure_values.each do |value|
          @subject[@attribute] = value
          unless @subject.save
            @failure_message = %Q{failed persistance
value: [#{value}]}
            return false
          end
        end

        @negative_failure_message = "success persistance of #{@attribute}"
        true
      end

      def description
        "success persistance of #{@attribute}"
      end

      private

      def ensure_values
        v = @options[:values]
        v.present? ? v : [nil]
      end

    end
  end
end
