class Job

  attr_accessor :memory_required,
                :turn_started,
                :turns_required,
                :assigned

  attr_reader :id

  def initialize(args = {})
    @id = args[:id]
    @memory_required = args[:memory_required]
    @turns_required = args[:turns_required]
    @turn_started = args[:turn]
    @assigned = false
  end

  def time_left
    (@turns_required + @turn_started) - $current_turn
  end

  def self.job_list(turn)
    turn[:jobs].map {|j| Job.new(j)}
  end

end