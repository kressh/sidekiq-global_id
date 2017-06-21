module Sidekiq
  module GlobalId
    # Sidekiq client middleware serializes arguments before
    # pushing job to Redis.
    #
    class ClientMiddleware
      # @param _worker_class [Class<Sidekiq::Worker>]
      # @param job [Hash] sidekiq job
      # @param _queue [String]
      # @param _redis_pool [ConnectionPool]
      # @return [Hash] sidekiq job
      def call(_worker_class, job, _queue, _redis_pool)
        job = serialize_job(job)
        yield
      end

      def serialize_job(job)
        if job.is_a?(Array)
          return ActiveJob::Arguments.serialize(job)
        elsif job.is_a?(Hash)
          job['args'] = ActiveJob::Arguments.serialize(job['args']) if job['retry']
        end
        job
      rescue
        job
      end
    end
  end
end
