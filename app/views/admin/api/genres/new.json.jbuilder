json.(@item, 'id', 'name_ru', 'name_en', 'slug_ru', 'slug_en', 'created_at', 'updated_at')

json.id @item.id.to_s
json.seo_id @item.seo.id.to_s

json.set! "$config" do
  json.columns_list Genre.fields
  json.humanize humanize_columns Genre
  json.names do
    json.model_slug "genres"
    json.model_name Genre.model_name.human(count: 1)
  end
  json.system_columns do
    json.array! ["_id", "id"]
  end
end
