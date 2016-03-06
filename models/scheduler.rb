class Scheduler

attr_accessor   :machines_running,
                :jobs_running,:jobs,
                :machines,:game_id

  def initialize(args = {})
    @jobs_running = args[:jobs_running]
    @machines_running = args[:machines_running]
    @machines = [] || args[:machines]
    @jobs = [] || args[:jobs]
    @game_id = args[:id]
  end

  def add_jobs_to_schedule(jobs)
    @jobs = jobs
    order_jobs
  end

  def add_machine_to_schedule(machine)
    @machines << machine
    order_machines
  end

  def distribute_jobs
    @machines.each do |m|
      assignment_hash = {}
      m.clear_completed_jobs
      @jobs.each do |j|
        if j.memory_required <= m.memory_left && !m.shutting_down
          assignment_hash[j.id] = m.id
          m.working_jobs << j
          j.assigned = true
        end
      end
      m.assign_jobs(assignment_hash)
    end
    clear_jobs_from_schedule
  end

  def distribute_remaining_jobs(machine)
    assignment_hash = {}
    @jobs.each do |j|
      assignment_hash[j.id] = machine.id
      machine.working_jobs << j
      j.assigned = true
    end
    machine.assign_jobs(assignment_hash)
    @jobs.delete_if{|j| j.assigned == true}
  end

  def terminate_machine(m)
    RestClient.delete("#{$host}/games/#{@game_id}/machines/#{m.id}")
    m.shutting_down = true
  end

  def new_machine_data
    JSON.parse(
      RestClient.post("#{$host}/games/#{@game_id}/machines", {}).body,
      symbolize_names: true)
  end

  def get_turn_data
    JSON.parse(
      RestClient.get("#{$host}/games/#{@game_id}/next_turn").body,
      symbolize_names: true)
  end

  private

    def clear_jobs_from_schedule
      @jobs.delete_if{|j| j.assigned == true}
    end

    def order_jobs
      @jobs = @jobs.sort_by!{ |j| j.memory_required }.reverse!
    end

    def order_machines
      @machines = @machines.sort_by!{ |m| m.memory_left }
    end

end