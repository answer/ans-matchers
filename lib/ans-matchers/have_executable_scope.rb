module Ans
  module Matchers
    def have_executable_scope(scope_name)
      HaveExecutableScope.new scope_name
    end

    class HaveExecutableScope
      attr_reader :failure_message, :negative_failure_message

      def initialize(scope_name)
        @scope_name = scope_name.to_s
        @options = {}
      end

      def params(*args)
        @options[:args] = args
        self
      end
      def by_sql(sql)
        @options[:sql] = sql
        self
      end
      def strict!
        @options[:is_strict] = true
        self
      end
      def fazzy!
        @options[:is_strict] = false
        self
      end

      def matches?(subject)
        @subject = subject
        scoped = @subject.send @scope_name, *args
        scope_sql = scoped.to_sql
        expect_sql = sql

        if fazzy?
          scope_sql = scope_sql.gsub(/\s+/, " ").strip
          expect_sql = expect_sql.gsub(/\s+/, " ").strip
        end

        scope_sql.should == expect_sql
        scoped.each{break}

        @negative_failure_message = "have named_scope #{@scope_name}"
        true
      end

      def description
        "have and execute-able named_scope #{@scope_name}"
      end

      private

      def args
        @options[:args] || []
      end
      def sql
        @options[:sql] || ""
      end
      def fazzy?
        !@options[:is_strict]
      end
    end
  end
end
