module Ans::Matchers::HaveAssociationDbIndex
  include ActiveSupport::Configurable
end

Ans::Matchers.configure do |config|
  config.have_association_db_index = Ans::Matchers::HaveAssociationDbIndex.config
end

Ans::Matchers::HaveAssociationDbIndex.configure do |config|
  config.validate_columns = [
    %r{_id$},
  ]
end

RSpec::Matchers.define :have_association_db_index do
  description{"have association db index"}

  chain(:except) do |*columns|
    columns.each do |column|
      except_columns[column] = true
    end
  end
  match do |actual|
    @error_columns = []

    indexes = actual.class.connection.indexes(actual.class.table_name)
    actual.class.columns.each do |column|
      column_name = column.name.to_s
      if check_column?(column_name.to_sym)
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

  def except_columns
    @except_columns ||= {}
  end

  def check_column?(column)
    return false if except_columns[column]

    case column
    when *Ans::Matchers::HaveAssociationDbIndex.config.validate_columns
      true
    else
      false
    end
  end
end
