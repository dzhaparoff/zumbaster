json.(@seo, :'id', :'title', :'description', :'robots')
json.set! "$config" do
  json.columns_list Seo.fields
  json.system_columns do
    json.array! ["id"]
  end
end