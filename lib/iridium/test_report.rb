module Iridium
  class TestReport
    class Collector < Array
      def initialize(report)
        super 0
        @report = report
      end

      def <<(result)
        @report.print_result result
        super result
      end
    end

    attr_reader :io

    def initialize(io = $stdout)
      @io = io
    end

    def collector
      @collector ||= Collector.new self
    end

    def print_result(result)
      if result.passed?
        io.print "."
      elsif result.error?
        io.print "E"
      elsif result.failed?
        io.print "F"
      end
    end

    def print_results(results)
      total_passed = results.select(&:passed?).size
      total_failed = results.select(&:failed?).size
      total_errors = results.select(&:error?).size

      total_assertions = results.inject(0) do |sum, result|
        sum += result.assertions || 0
      end

      total_time = results.inject(0) do |sum, result|
        sum += result.time || 0
      end

      summary = "%d Test(s), %d Assertion(s), %d Passed, %d Error(s), %d Failure(s)"

      io.puts(summary % [
        results.size, 
        total_assertions,
        total_passed,
        total_errors,
        total_failed,
      ])
    end
  end
end
