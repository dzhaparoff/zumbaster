# Change this to your host. See the readme at https://github.com/lassebunk/dynamic_sitemaps
host "hd-serials.tv"
protocol "https"

sitemap :site do
  url root_url, last_mod: Time.now, change_freq: "daily", priority: 1.0
  # url fresh_photos_page_url, last_mod: Time.now, change_freq: "daily", priority: 1.0
  # url photos_of_the_day_page_url, last_mod: Time.now, change_freq: "daily", priority: 1.0
end

sitemap_for Show.all, name: :shows do |show|
  url show_url(show.slug_ru), last_mod: show.updated_at, change_freq: "daily", priority: 0.9
end

sitemap_for Season.all, name: :seasons do |season|
  show = season.show
  return false if show.nil?
  url show_season_url(show.slug_ru, "%02d" % season.number), last_mod: season.updated_at, change_freq: "daily", priority: 0.8
end

sitemap_for Episode.includes(:translations).where.not(translations: {id: nil}, screenshot_updated_at: nil).all, name: :episodes do |episode|
  show = episode.show
  season = episode.season
  return false if show.nil? || season.nil?
  url show_episode_url(show.slug_ru, "%02d" % season.number, "%02d" % episode.number), last_mod: episode.updated_at, change_freq: "daily", priority: 0.8
end

ping_with "https://hd-serials.tv/sitemap.xml"