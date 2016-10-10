module ShowsHelper
  def genres_inline_list genres
    g = genres.map do |genre|
      return '' if genre.name_ru.nil?
      "<a href=\"/genres/#{genre.slug_ru}\">#{genre.name_ru}</a>"
    end
    g * ", "
  end

  def genres_array genres
    genres.map do |genre|
      return genre.name_ru unless genre.name_ru.nil?
    end
  end

end
