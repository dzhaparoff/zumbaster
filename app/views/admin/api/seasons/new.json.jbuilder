json.(@item, 'id', 'slug_ru', 'slug_en', 'title_ru', 'title_en', 'description_ru', 'description_en', 'first_aired', 'number', 'ids', 'episode_count', 'aired_episodes', 'show_id', 'created_at', 'updated_at', 'poster_file_name', 'poster_content_type', 'poster_file_size', 'poster_updated_at', 'thumb_file_name', 'thumb_content_type', 'thumb_file_size', 'thumb_updated_at', 'poster_meta', 'thumb_meta')

json.id @item.id.to_s

json.set! "$config" do
  json.columns_list Season.fields
  json.humanize humanize_columns Season
  json.names do
    json.model_slug "seasons"
    json.model_name Season.model_name.human(count: 1)
  end
  json.system_columns do
    json.array! ["_id", "id"]
  end
end
