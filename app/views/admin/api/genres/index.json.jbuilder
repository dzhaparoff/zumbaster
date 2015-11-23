json.items do
  json.array! @genres do |genre|
    json.id genre.id
    json.shows genre.shows.count
    json.name_ru genre.name_ru
    json.name_en genre.name_en
    json.slug_ru genre.slug_ru
    json.slug_en genre.slug_en
    json.seo_id genre.seo.id unless genre.seo.nil?
  end
end
json.set! "$config" do
  json.names do
    json.model_slug "genres"
    json.model_name "Жанры"
  end
  json.columns_list Genre.columns_hash
  json.system_columns do
    json.array! [Genre.primary_key, "created_at", "updated_at", "shows", "seo_id"]
  end
end