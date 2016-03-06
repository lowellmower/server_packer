require_relative 'runner_helper'
# Get game data
game = init_game
# make scheduler and first machine
scheduler = Scheduler.new(game)
machine = Machine.new(scheduler.new_machine_data)
# add machine to scheduler
scheduler.add_machine_to_schedule(machine)
# get first turn data
turn = scheduler.get_turn_data
# update current_turn counter
$current_turn = turn[:current_turn]
# create jobs and put on sched
scheduler.add_jobs_to_schedule(Job.job_list(turn))
# assign jobs
scheduler.distribute_jobs
# notify user of turn status
turn_status(turn)

until turn[:status] == 'completed'
  # get turn data
  turn = scheduler.get_turn_data
  # update current_turn counter
  $current_turn = turn[:current_turn]
  # create jobs and put on sched
  scheduler.add_jobs_to_schedule(Job.job_list(turn))
  # assign as many jobs to machines
  scheduler.distribute_jobs
  # assign left over jobs to a machine which can queue jobs
  until scheduler.jobs.empty?
    # make a new machine
    machine = Machine.new(scheduler.new_machine_data)
    # get the machine which will shut down fastest
    machine_for_shut_down = scheduler.machines.pop
    # add new machine to schedule
    scheduler.add_machine_to_schedule(machine)
    # distribute all jobs to the new machine and allow queue
    scheduler.distribute_remaining_jobs(machine)
    # begin shut down of machine
    scheduler.terminate_machine(machine_for_shut_down)
  end
  turn_status(turn)
end

summarize_game(game)