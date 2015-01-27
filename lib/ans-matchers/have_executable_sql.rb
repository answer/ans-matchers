RSpec::Matchers.define :have_executable_sql do |expect_sql|
  description{"have executable sql"}

  match do |actual|
    actual_sql = actual.to_sql

    actual_sql = actual_sql.gsub(/\s+/, " ").strip
    expect_sql = expect_sql.gsub(/\s+/, " ").strip

    if expect_sql == actual_sql
      begin
        actual.each{break}
        true
      rescue
        false
      end
    end
  end

  failure_message do |actual|
    actual_sql = actual.to_sql

    actual_sql = format_sql actual_sql.gsub(/\s+/, " ").strip
    expect_sql = format_sql expect_sql.gsub(/\s+/, " ").strip

    message = "\n-- EXPECTED\n\n#{expect_sql}\n\n-- GOT\n\n#{actual_sql}\n\n(compared using ==)\n"
    if diff = ::RSpec::Expectations.differ.diff(actual_sql, expect_sql)
      message << "\nDiff:#{diff}"
    end

    message
  end

  def format_sql(sql)
    sql
    .gsub("SELECT"){"SELECT\n   "}
    .gsub(/\bAS .*?,/i){|m| "#{m}\n   "}
    .gsub(/\b(FROM|LIMIT|OFFSET)\b/){|m| "\n#{m}"}
    .gsub(/\b(INNER|LEFT) JOIN (.*?) ON\b/){|m| "\n#{$1} JOIN #{$2}\n    ON"}
    .gsub(/\b(WHERE|HAVING|(ORDER|GROUP) BY)\b/){|m| "\n#{m}\n   "}
    .gsub(/\) AND\b/i){|m| "#{m}\n   "}
    .gsub(/\b(ASC|DESC),/i){|m| "#{m}\n   "}
  end
end
