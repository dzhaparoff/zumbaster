# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
set :output, "../log/cron_log.log"

every 3.hours do
  runner "UpdateEpisodesJob.perform_later"
end

# every 4.days do
# command "/usr/bin/some_great_command"
#   runner "AnotherModel.prune_old_records"
# rake "some:great:rake:task"
# end

# Learn more: http://github.com/javan/whenever