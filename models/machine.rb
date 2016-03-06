class Machine

  attr_accessor :queued_jobs,
                :working_jobs,
                :shutting_down

  attr_reader :id, :game_id

  MEMORY_LIMIT = 64

  def initialize(args = {})
    @id = args[:id]
    @queued_jobs = [] || args[:jobs_queued]
    @working_jobs = []
    @shutting_down = args[:terminated]
    @game_id = args[:game_id]
  end

  def memory_left
    return MEMORY_LIMIT unless @working_jobs.any?
    MEMORY_LIMIT - (@working_jobs.map(&:memory_required).inject(:+))
  end

  def clear_completed_jobs
    return if @working_jobs.empty?
    @working_jobs.delete_if{|j| j.time_left <= 0}
  end

  def turns_left
    return 0 if @working_jobs.count == 0
    @working_jobs.map(&:time_left).max
  end

  def assign_jobs(job_hash)
    JSON.parse(
      RestClient.post(
        "#{$host}/games/#{@game_id}/machines/#{self.id}/job_assignments",
        job_ids: JSON.dump([job_hash.keys])
        ).body, symbolize_names: true )
  end

end