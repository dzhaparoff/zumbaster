module ShowsHelper
  def genres_inline_list genres
    g = genres.map do |genre|
      return '' if genre.name_ru.nil?
      "<a href=\"/genres/#{genre.slug_ru}\">#{genre.name_ru}</a>"
    end
    g * ", "
  end

end
