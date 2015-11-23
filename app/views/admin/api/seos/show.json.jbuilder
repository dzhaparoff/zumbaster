json.(@seo, *Seo.column_names)
json.set! "$config" do
  json.columns_list Seo.columns_hash
  json.system_columns do
    json.array! [Seo.primary_key, "created_at", "updated_at", "meta_id", "meta_type"]
  end
end