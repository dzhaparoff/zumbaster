json.(@item, 'id', 'img', 'slug_ru', 'slug_en', 'title_ru', 'title_en', 'description_ru', 'description_en', 'slogan_ru', 'slogan_en', 'year', 'first_aired', 'updated', 'ids', 'airs', 'runtime', 'certification', 'network', 'country', 'homepage', 'status', 'aired_episodes', 'created_at', 'updated_at', 'fanart_file_name', 'fanart_content_type', 'fanart_file_size', 'fanart_updated_at', 'poster_file_name', 'poster_content_type', 'poster_file_size', 'poster_updated_at', 'logo_file_name', 'logo_content_type', 'logo_file_size', 'logo_updated_at', 'clearart_file_name', 'clearart_content_type', 'clearart_file_size', 'clearart_updated_at', 'banner_file_name', 'banner_content_type', 'banner_file_size', 'banner_updated_at', 'thumb_file_name', 'thumb_content_type', 'thumb_file_size', 'thumb_updated_at', 'poster_ru_file_name', 'poster_ru_content_type', 'poster_ru_file_size', 'poster_ru_updated_at', 'poster_meta', 'poster_ru_meta', 'fanart_meta', 'logo_meta', 'clearart_meta', 'banner_meta', 'thumb_meta')

json.id @item.id.to_s
json.season @item.seasons do |season|
  json.id season.id
  json.number season.number
  json.img season.poster.url :thumb
end
json.episode_id @item.episodes.to_a.map {|e| e.id }

json.set! "$config" do
  json.columns_list Show.fields
  json.humanize humanize_columns Show
  json.names do
    json.model_slug "pshows"
    json.model_name Show.model_name.human(count: 1)
  end
  json.system_columns do
    json.array! ["id"]
  end
end
