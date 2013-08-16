module Ans
  module Matchers
    def have_out_of_range_validation(columns=nil)
      HaveOutOfRangeValidation.new columns
    end

    class HaveOutOfRangeValidation
      def initialize(columns)
        @columns = columns || {}
      end

      def matches?(subject)
        @error_columns = []
        @exceptions = []

        subject.class.columns.each do |column|
          column_name = column.name.to_sym
          if over = over_value(column)
            sub = subject.dup
            sub[column_name] = over
            begin
              sub.save
            rescue => e
              @error_columns.push column_name
              @exceptions.push e
            end
          end
        end

        @error_columns.blank?
      end

      def description
        "have out of range validation"
      end
      def negative_failure_message
        description
      end
      def failure_message
        message = "out of range validation not exist"
        message << "\ncolumn:"
        (@error_columns || []).each{|column_name| message << "\n  #{column_name}"}
        message << "\nexception:"
        (@exceptions || []).each{|e| message << "\n  #{e}"}
        message
      end

      private

      def over_value(column)
        return if column.primary
        @columns[column.name] || @columns[column.name.to_sym] || case column.type
        when :integer
          (2**8)**column.limit/2
        when :string
          "a"*(column.limit+1)
        end
      end
    end
  end
end
