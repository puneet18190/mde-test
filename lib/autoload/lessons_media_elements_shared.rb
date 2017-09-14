# List of common translation methods that call I18n
module LessonsMediaElementsShared
  
  # Translation of the status of a lesson or of an element (see Statuses). For an example of usage see Lesson#status
  def status(s)
    I18n.t("statuses.#{table_name}.#{s}")
  end
  
  # Translation of the filter of a lesson or of an element (see Filters). Example of usage:
  #   <% Filters::LESSONS_SET.each do |f| %>
  #     <%= Lesson.filter(f) %>
  #   <% end %>
  def filter(f)
    I18n.t("filters.#{f}")
  end
  
  # Translation of the search order of a lesson or of an element (see SearchOrders). Example of usage:
  #   <% SearchOrders::LESSONS_SET.each do |so| %>
  #     <%= Lesson.search_order(so) %>
  #   <% end %>
  def search_order(so)
    I18n.t("orders.#{so}")
  end
  
end
