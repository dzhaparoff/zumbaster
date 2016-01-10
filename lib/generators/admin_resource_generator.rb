class AdminResourceGenerator < Rails::Generators::Base

  def init
    @model = Season

    @model_name = @model.to_s
    @resource_name = @model_name.underscore
    @resource_name_plural = @resource_name.pluralize
  end

  def create_api_controller
    controller_template =
%\class Admin::Api::#{@resource_name_plural.capitalize}Controller < Admin::Api::ApiController
  def index
    @items = #{@model_name}.order('id asc').all
  end

  def new
    @item = #{@model_name}.new
  end

  def create
    @item = #{@model_name}.create(model_params)
    render action: :show
  end

  def show
    @item = #{@model_name}.find(params[:id])
  rescue
    not_found
  end

  def edit
     @item = #{@model_name}.find(params[:id])
  rescue
    not_found
  end

  def update
    @item = #{@model_name}.find(params[:id])
    @item.update(model_params)
    render action: :show
  end

  def destroy
    @item = #{@model_name}.find(params[:id])
    @item.destroy
    render action: :show
  end

  private

  def model_params
    params
       .permit(
          :#{@model.columns_list[1..-1] * ', :'}
       )
   end
end
\
    create_file "app/controllers/admin/api/#{@resource_name_plural}_controller.rb", controller_template
  end

  def create_api_json_templates
    index_template =
%\json.items do
  json.array! @items do |item|
    json.id item.id.to_s
    #{generate_json_fields @model}
  end
end
json.set! "$config" do
  json.columns_list #{@model_name}.fields
  json.humanize humanize_columns #{@model_name}
  json.names do
    json.model_slug "#{@resource_name_plural}"
    json.model_name #{@model_name}.model_name.human(count: @items.count)
  end
  json.system_columns do
    json.array! ["_id", "id"]
  end
end
\

    show_template =

%\json.(@item, '#{@model.columns_list * "', '"}')

json.id @item.id.to_s

json.set! "$config" do
  json.columns_list #{@model_name}.fields
  json.humanize humanize_columns #{@model_name}
  json.names do
    json.model_slug "#{@resource_name_plural}"
    json.model_name #{@model_name}.model_name.human(count: 1)
  end
  json.system_columns do
    json.array! ["_id", "id"]
  end
end
\

    create_file "app/views/admin/api/#{@resource_name_plural}/index.json.jbuilder", index_template
    create_file "app/views/admin/api/#{@resource_name_plural}/new.json.jbuilder", show_template
    create_file "app/views/admin/api/#{@resource_name_plural}/show.json.jbuilder", show_template
  end


  def create_ng_partials
    create_file "app/views/admin/partials/ng/#{@resource_name_plural}/#{@resource_name_plural}.html.erb", ""
    create_file "app/views/admin/partials/ng/#{@resource_name_plural}/#{@resource_name}_new.html.erb", ""
    create_file "app/views/admin/partials/ng/#{@resource_name_plural}/#{@resource_name}_edit.html.erb", ""
  end


  private

  def generate_json_fields model
    jbuilder_part = []
    model.columns_list.each do |column|
      jbuilder_part << "json.#{column} item.#{column}"
    end
    jbuilder_part * "\r\n     "
  end
end
