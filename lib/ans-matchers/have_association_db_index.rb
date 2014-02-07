module Ans
  module Matchers
    def have_association_db_index(opts=nil)
      HaveAssociationDbIndex.new opts
    end

    class HaveAssociationDbIndex
      def initialize(opts)
        opts ||= {}
        @except_columns = Hash[(opts[:except] || []).map{|column| [column,true]}]
      end

      def matches?(subject)
        @error_columns = []

        indexes = subject.class.connection.indexes(subject.class.table_name)
        subject.class.columns.each do |column|
          column_name = column.name.to_s
          if column_name.end_with?("_id") && !@except_columns[column_name.to_sym]
            unless indexes.any?{|index| index.columns == [column_name]}
              @error_columns << column_name
            end
          end
        end

        @error_columns.blank?
      end

      def description
        "have association db index"
      end
      def negative_failure_message
        description
      end
      def failure_message
        message = "association db index not exist"
        message << "\ncolumn:"
        (@error_columns || []).each{|column_name| message << "\n  #{column_name}"}
        message
      end
    end
  end
end
