module Sidekiq
  class Clutch
    class JobsCollection
      def initialize(service)
        @service = service
        @jobs = []
        @result_key_prefix = SecureRandom.uuid
        @result_key_index = 0
      end

      def empty?
        @jobs.empty?
      end

      def raw
        @jobs
      end

      def raw=(jobs)
        @jobs = jobs
      end

      def <<((klass, *params))
        if @service.parallel?
          @jobs << { 'parallel' => [], 'result_key' => next_result_key } unless @jobs.last && @jobs.last['parallel']
          @jobs.last['parallel'] << [klass.name, params]
        else
          @jobs << { 'series' => [klass.name, params], 'result_key' => next_result_key }
        end
      end

      def next_result_key
        @result_key_index += 1
        "#{@result_key_prefix}-#{@result_key_index}"
      end
    end
  end
end
