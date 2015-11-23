json.(@genre, *Genre.column_names.to_a)
json.shows @genre.shows.count
json.seo_id @genre.seo.id unless @genre.seo.nil?

json.set! "$config" do
  json.raw @genre
  json.columns_list Genre.columns_hash
  json.system_columns do
    json.array! [Genre.primary_key, "created_at", "updated_at", "shows", "seo_id"]
  end
end