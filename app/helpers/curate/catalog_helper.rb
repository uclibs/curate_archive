module Curate::CatalogHelper 
  def type_tab(label, key=label)
    if params[:f] && params[:f][type_field] == [key]
      content_tag(:li, link_to(label, "#"), class: "active")
    else
      local_params = params.dup
      local_facet_params = local_params[:f] || {}.with_indifferent_access
      local_params[:f] = local_facet_params.select{|k,_| k != type_field }
      content_tag(:li, link_to(label, add_facet_params(type_field, key, local_params)))
    end
  end

  def all_type_tab(label = "All")
    if params[:f] && params[:f][type_field]
      local_params = params.dup
      local_params[:f] = local_params[:f].select{|k,_| k != type_field }
      local_params.delete(:f) if local_params[:f].empty?
      content_tag(:li, link_to(label, local_params))
    else
      content_tag(:li, link_to(label, '#'), class: "active")
    end
  end

  def catalog_type
    if params[:f] && params[:f][type_field]
      if params[:f][type_field].first == "All"
        "Content"
      elsif params[:f][type_field].first == "Person"
        "Profile"
      else
        params[:f][type_field].first.pluralize
      end
    else
      "Content"
    end
  end

  def catalog_thumbnail_alt_text(document)
    if document.human_readable_type == 'Person'
      return "Thumbnail for #{document.name}"
    else
      return "Thumbnail for #{document.title}"
    end 
  end

  private

    def type_field
      Solrizer.solr_name("generic_type", :facetable)
    end

end
