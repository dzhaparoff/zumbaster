json.items do
  json.array! @items do |item|
    json.id item.id
     json.slug_ru item.slug_ru
     json.slug_en item.slug_en
     json.title_ru item.title_ru
     json.title_en item.title_en
     json.description_ru item.description_ru
     json.description_en item.description_en
     json.slogan_ru item.slogan_ru
     json.slogan_en item.slogan_en
     json.year item.year
     json.first_aired item.first_aired
     json.updated item.updated
     json.ids item.ids
     json.airs item.airs
     json.runtime item.runtime
     json.certification item.certification
     json.network item.network
     json.country item.country
     json.homepage item.homepage
     json.status item.status
     json.aired_episodes item.aired_episodes
     json.created_at item.created_at
     json.updated_at item.updated_at
    json.img item.img
  end
end
json.set! "$config" do
  json.columns_list Show.fields
  json.humanize humanize_columns Show
  json.names do
    json.model_slug "pshows"
    json.model_name Show.model_name.human(count: @items.count)
  end
  json.system_columns do
    json.array! ["id"]
  end
end
