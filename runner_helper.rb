require 'byebug'
require 'rubygems'
require 'bundler/setup'
require 'json'
require 'rest-client'
Dir[File.dirname(__FILE__) + '/models/*.rb'].each {|file| require file }

# --- GLOBALS VARIABLES --- #
$current_turn = nil
$host = 'http://job-queue-dev.elasticbeanstalk.com'

# --- HELPER METHODS --- #
def init_game
  JSON.parse(
    RestClient.post("#{$host}/games",{}
    # { long: true }
    ).body, symbolize_names: true)
end

def turn_status(turn)
  puts "On turn #{turn[:current_turn]}, got #{turn[:jobs].count} jobs, having completed #{turn[:jobs_completed]} of #{turn[:jobs].count} with #{turn[:jobs_running]} jobs running, #{turn[:jobs_queued]} jobs queued, and #{turn[:machines_running]} machines running"
end

def summarize_game(game)
  puts "\n\n"
  game_json = RestClient.get("#{$host}/games/#{game[:id]}",).body
  puts game_json
  puts "\n\n"
  completed_game = JSON.parse(game_json, symbolize_names: true);
  puts "COMPLETED GAME WITH:"
  puts "Total delay: #{completed_game[:delay_turns]} turns"
  puts "Total cost: $#{completed_game[:cost]}"
end