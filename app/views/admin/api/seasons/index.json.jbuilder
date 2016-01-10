json.items do
  json.array! @items do |item|
    json.id item.id.to_s
    json.id item.id
     json.slug_ru item.slug_ru
     json.slug_en item.slug_en
     json.title_ru item.title_ru
     json.title_en item.title_en
     json.description_ru item.description_ru
     json.description_en item.description_en
     json.first_aired item.first_aired
     json.number item.number
     json.ids item.ids
     json.episode_count item.episode_count
     json.aired_episodes item.aired_episodes
     json.show_id item.show_id
     json.created_at item.created_at
     json.updated_at item.updated_at
     json.poster_file_name item.poster_file_name
     json.poster_content_type item.poster_content_type
     json.poster_file_size item.poster_file_size
     json.poster_updated_at item.poster_updated_at
     json.thumb_file_name item.thumb_file_name
     json.thumb_content_type item.thumb_content_type
     json.thumb_file_size item.thumb_file_size
     json.thumb_updated_at item.thumb_updated_at
     json.poster_meta item.poster_meta
     json.thumb_meta item.thumb_meta
  end
end
json.set! "$config" do
  json.columns_list Season.fields
  json.humanize humanize_columns Season
  json.names do
    json.model_slug "seasons"
    json.model_name Season.model_name.human(count: @items.count)
  end
  json.system_columns do
    json.array! ["_id", "id"]
  end
end
