module CalendarHelper

  def generate_calendar(offset = 0, &block)
    this_monday = Chronic.parse('this week Mon').to_date

    # e = Proc.new do |k|
    #   (1..4).map do |z|
    #     k
    #   end
    # end

    (0...7).each do |k|
      date = this_monday + k.day + offset.day
      # block.call(k, e.call(date))
      block.call(date)
    end
  end

  def today_content_tag day
    Time.zone = 'Moscow'
    if day.day == Time.zone.now.day
      %|<div class="current-day-label">сегодня</div>|.html_safe
    else
      ""
    end
  end

  def episodes_for_date date, &block
    episode = Episode.for_date(date).all
    episode.each do |e|
      block.call(e)
    end
  end

  def day_class_for day

    Time.zone = 'Moscow'
    today = Time.zone.now.to_date

    day_class = %w|row day|
    day_class << "day-#{"%02d" % day.strftime('%u')}"
    day_class << "today"         if today == day
    day_class << "past"          if today > day
    day_class << "future"        if today < day
    day_class << "prev-month"    if day.month != today.month && day < today
    day_class << "next-month"    if day.month != today.month && day > today
    day_class << "current-month" if day.month == today.month
    day_class << "prev-week"     if day.cweek != today.cweek && day < today
    day_class << "next-week"     if day.cweek != today.cweek && day > today
    day_class << "current-week"  if day.cweek == today.cweek

    day_class
  end

end
