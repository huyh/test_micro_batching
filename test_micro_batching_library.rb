require 'securerandom'
require 'micro_batching'

class BatchProcessor
  def process(jobs)
    jobs.each do |job|
      puts "Processing job #{job.id} with data #{job.data}"
    end
    jobs
  end
end

class EventBroadcaster
  def broadcast(event, data)
    puts "Broadcasting event #{event} with data: #{data}"
  end
end

class ResultConverter
  def convert(results)
    results.map.with_index do |_result, index|
      index % 2 == 0 ? true : { error: 'Failed to process job' }
    end
  end
end

batch_processor = BatchProcessor.new
event_broadcaster = EventBroadcaster.new
result_converter = ResultConverter.new

batcher = MicroBatching::Batcher.new(
  batch_size: 10,
  max_queue_size: 50,
  frequency: 10,
  batch_processor: batch_processor,
  event_broadcaster: event_broadcaster,
  result_converter: result_converter
)

@stop_submitting_job = false

job_submitter_one = Thread.new do
  while !@stop_submitting_job
    sleep(1)
    job = MicroBatching::Job.new("job-submitter-one-#{SecureRandom.uuid}")
    batcher.submit(job)
  end
end

job_submitter_two = Thread.new do
  while !@stop_submitting_job
    sleep(2)
    job = MicroBatching::Job.new("job-submitter-two-#{SecureRandom.uuid}")
    batcher.submit(job)
  end
end

sleep(50)

@stop_submitting_job = true
job_submitter_one.join
job_submitter_two.join

shutdown = batcher.shutdown
puts "Batcher shutdown: #{shutdown}"
