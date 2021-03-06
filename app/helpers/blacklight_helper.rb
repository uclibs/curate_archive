require Blacklight::Engine.root.join('app/helpers/blacklight/hash_as_hidden_fields_helper_behavior')
require Blacklight::Engine.root.join('app/helpers/blacklight/render_constraints_helper_behavior')
require Blacklight::Engine.root.join('app/helpers/blacklight/html_head_helper_behavior')
require Blacklight::Engine.root.join('app/helpers/blacklight/facets_helper_behavior')

require Blacklight::Engine.root.join('app/helpers/hash_as_hidden_fields_helper')
require Blacklight::Engine.root.join('app/helpers/render_constraints_helper')
require Blacklight::Engine.root.join('app/helpers/html_head_helper')
require Blacklight::Engine.root.join('app/helpers/facets_helper')

require Blacklight::Engine.root.join('app/helpers/blacklight/blacklight_helper_behavior')

module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior

  def application_name
    t('sufia.product_name')
  end

  ## Override the default seperator used to display multivalue fields on the index view
  def field_value_separator
    tag(:br)
  end
end
