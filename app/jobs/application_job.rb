class ApplicationJob < ActiveJob::Base
  self.queue_adapter = :sidekiq

  rescue_from StandardError do |exception|
    if self.queue_name.to_s == 'retry'
      raise exception
    else
      retry_job(wait: 30, queue: :retry)
    end
  end

  # This patch tries to fix "(ArgumentError) "wrong number of arguments (given 0, expected 2)".
  #
  # @see https://github.com/rails/rails/issues/22044
  # @see https://github.com/fiedl/your_platform/issues/23
  #
  # TODO: When migrating to rails 5, check if https://github.com/rails/rails/pull/26221 is
  # pulled already.
  #
  def serialize
    serialized = super

    # @see https://github.com/rails/rails/blob/v5.0.0.1/activejob/lib/active_job/core.rb#L116
    if defined?(@serialized_arguments) && @serialized_arguments.present?
      serialized["arguments"] = @serialized_arguments
    end

    serialized
  end
end
