module Ans::Matchers::HaveOutOfRangeValidation
  include ActiveSupport::Configurable
end

Ans::Matchers.configure do |config|
  config.have_out_of_range_validation = Ans::Matchers::HaveOutOfRangeValidation.config
end

Ans::Matchers::HaveOutOfRangeValidation.configure do |config|
  config.except_columns = [
    :id,
    %r{_id$},
    %r{_type$},
    %r{_status$},
    %r{_fla?g$},
  ]
end

RSpec::Matchers.define :have_out_of_range_validation do
  description{"have out of range validation"}

  chain(:except) do |*columns|
    columns.each do |column|
      except_columns[column] = true
    end
  end
  chain(:force) do |*columns|
    columns.each do |column|
      force_columns[column] = true
    end
  end
  chain(:as) do |values|
    values.each do |column,over_value|
      over_values[column.to_sym] = over_value
    end
  end
  match do |actual|
    @error_columns = []
    @exceptions = []

    actual.class.columns.each do |column|
      column_name = column.name.to_sym
      if check_column?(column_name)
        if over = over_value(column)
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

  def force_columns
    @force_columns ||= {}
  end
  def except_columns
    @except_columns ||= {}
  end
  def over_values
    @over_values ||= {}
  end

  def check_column?(column)
    return true if force_columns[column]
    return false if except_columns[column]

    case column
    when *Ans::Matchers::HaveOutOfRangeValidation.config.except_columns
      false
    else
      true
    end
  end

  def over_value(column)
    over_values[column.name.to_sym] || case column.type
    when :integer
      (2**8)**column.limit/2
    when :string
      "a"*(column.limit+1)
    end
  end
end
