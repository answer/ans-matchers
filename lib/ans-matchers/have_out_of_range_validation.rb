RSpec::Matchers.define :have_out_of_range_validation do |columns: {},except: []|
  except_columns = Hash[(except || []).map{|column| [column,true]}]

  description{"have out of range validation"}

  match do |actual|
    @error_columns = []
    @exceptions = []

    actual.class.columns.each do |column|
      column_name = column.name.to_sym
      unless except_columns[column_name]
        if over = over_value(column,columns)
          sub = actual.dup
          sub[column_name] = over
          begin
            sub.save
          rescue => e
            @error_columns.push column_name
            @exceptions.push e
          end
        end
      end
    end

    @error_columns.blank?
  end
  failure_message do |actual|
    message = "out of range validation not exist"
    message << "\ncolumn:"
    (@error_columns || []).each{|column_name| message << "\n  #{column_name}"}
    message << "\nexception:"
    (@exceptions || []).each{|e| message << "\n  #{e}"}
    message
  end

  def over_value(column,columns)
    return if column.primary
    columns[column.name] || columns[column.name.to_sym] || case column.type
    when :integer
      (2**8)**column.limit/2
    when :string
      "a"*(column.limit+1)
    end
  end
end
