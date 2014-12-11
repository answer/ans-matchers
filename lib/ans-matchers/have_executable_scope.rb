RSpec::Matchers.define :have_executable_scope do |scope_name|
  scope_name = scope_name.to_s

  description{"have and executable named_scope #{scope_name}"}

  chain(:params){|*args| @args = args}
  chain(:by_sql){|sql| @sql = sql}
  chain(:strict!){@is_strict = true}
  chain(:fazzy!){@is_strict = false}

  match do |actual|
    scoped = actual.send scope_name, *(@args || [])
    scope_sql = scoped.to_sql
    expect_sql = @sql

    unless @is_strict
      scope_sql = scope_sql.gsub(/\s+/, " ").strip
      expect_sql = expect_sql.gsub(/\s+/, " ").strip
    end

    scoped.each{break}
    scope_sql == expect_sql
  end
  failure_message_when_negated do |actual|
    scope_sql = scoped.to_sql
    expect_sql = @sql
    "have named_scope #{scope_name}"
  end
  failure_message do |actual|
    scoped = actual.send scope_name, *(@args || [])
    scope_sql = scoped.to_sql
    expect_sql = @sql

    unless @is_strict
      scope_sql = scope_sql.gsub(/\s+/, " ").strip
      expect_sql = expect_sql.gsub(/\s+/, " ").strip
    end

    "have named_scope #{scope_name}
expected:
  #{expect_sql}
got:
  #{scope_sql}"
  end
end
