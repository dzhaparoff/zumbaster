module Admin::AdminHelper
  def airs show
    "<br> #{show.airs['day']}<br>#{show.airs['time']}" if show.status != 'airs'
  end

  def humanize_columns model
    humanize_columns = {}
    model.columns_list.each do |column|
      humanize_columns[:"#{column}"] = model.human_attribute_name column
    end
    humanize_columns
  end
end
