json.items do
  json.array! @items do |item|
    json.id item.id
     json.name_ru item.name_ru
     json.name_en item.name_en
     json.slug_ru item.slug_ru
     json.slug_en item.slug_en
     json.created_at item.created_at
     json.updated_at item.updated_at
  end
end
json.set! "$config" do
  json.columns_list Genre.fields
  json.humanize humanize_columns Genre
  json.names do
    json.model_slug "genres"
    json.model_name Genre.model_name.human(count: @items.count)
  end
  json.system_columns do
    json.array! ["_id", "id"]
  end
end
