RSpec::Matchers.define :have_association_db_index do |except: nil|
  except_columns = Hash[(except || []).map{|column| [column,true]}]

  description{"have association db index"}

  match do |actual|
    @error_columns = []

    indexes = actual.class.connection.indexes(actual.class.table_name)
    actual.class.columns.each do |column|
      column_name = column.name.to_s
      if column_name.end_with?("_id") && !except_columns[column_name.to_sym]
        unless indexes.any?{|index| index.columns == [column_name]}
          @error_columns << column_name
        end
      end
    end

    @error_columns.blank?
  end
  failure_message do |actual|
    message = "association db index not exist"
    message << "\ncolumn:"
    (@error_columns || []).each{|column_name| message << "\n  #{column_name}"}
    message
  end
end
