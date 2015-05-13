module ApplicationHelper
  def cp(path)
    " current" if current_page?(path)
  end

  def title(page_title)
    content_for :title, page_title.to_s
  end

  def genres_list
    Genre.order(name_ru: :asc).where.not(slug_ru: nil).all
  end
end