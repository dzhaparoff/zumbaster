module ShowsHelper
  def genres_inline_list genres
    g = genres.map do |genre|
      "<a href=\"/genres/#{genre.slug_en}\">#{genre.name_en}</a>"
    end
    g * ", "
  end

end
