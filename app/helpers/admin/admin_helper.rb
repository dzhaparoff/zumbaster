module Admin::AdminHelper
  def airs show
    "<br> #{show.airs['day']}<br>#{show.airs['time']}" if show.status != 'airs'
  end
end
