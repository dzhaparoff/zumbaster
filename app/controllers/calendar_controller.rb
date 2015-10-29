class CalendarController < ApplicationController
  def show
    shows = Show.joins(:seasons).where.not("seasons.aired_episodes = seasons.episode_count AND shows.status LIKE 'ended'").select("DISTINCT ON (shows.id) shows.*")

    @days = Hash.new

    shows.each do |show|
      season = show.seasons.where("aired_episodes > 0").order(:number).last
      episodes = season.episodes.where("first_aired > ?", Chronic.parse('this week Mon')).order(:number)
      episodes.each do |episode|
        next if episode.first_aired.nil?
        date = "#{episode.first_aired.year}-#{ "%02d" % episode.first_aired.month}-#{episode.first_aired.day}"
        @days[date] = Array.new if @days[date].nil?
        @days[date] << episode
      end
    end

  end
end

# Chronic.parse("next #{show.airs['day']} #{show.airs['time']}")
# Time.zone = show.airs[:timezone]
# Chronic.time_class = Time.zone