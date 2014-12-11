RSpec::Matchers.define :success_persistance_of do |attr|
  attribute = attribute.to_s

  description{"success persistance of #{attribute}"}

  chain(:values){|values| @values = values}

  match do |actual|
    ensure_values.each do |value|
      actual[attribute] = value
      unless actual.save
        @failure_message = %Q{failed persistance
value: [#{value}]}
        return false
      end
    end
    true
  end
  failure_message do |actual|
    @failure_message
  end
  failure_message_when_negated do |actual|
    "have named_scope #{attribute}"
  end

  def ensure_values
    v = @values
    v.present? ? v : [nil]
  end
end
