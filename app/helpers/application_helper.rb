module ApplicationHelper
  def cp(path)
    " current" if current_page?(path)
  end

  def lang_path lang
    if params['locale'].nil?
      "/" + lang + request.env['PATH_INFO']
    else
      "/" + lang + request.env['PATH_INFO'][3..-1]
    end
  end

  def genres_list
    Genre.joins(:shows).order(name_ru: :asc).where.not(shows: {id: nil}, slug_ru: nil).distinct
  end

  def random_bg_image
    show = Show.where("first_aired > ?", Date.today - 2.year).first
    return "" if show.nil?
    image = show.fanart
    "<img class=\"fullscreen-image\" data-canvas-image src=\"#{image.url}\" data-width=\"#{image.width}\" data-height=\"#{image.height}\"/>"\
    "<style>.wrapper {background-image: url(#{image.url});}</style>"
  end
end