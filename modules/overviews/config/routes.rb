Rails.application.routes.draw do
  constraints(project_id: Regexp.new("(?!(#{Project::RESERVED_IDENTIFIERS.join('|')})$)(\\w|-)+"), format: :html) do
    get "projects/:project_id",
        to: "overviews/overviews#show",
        as: :project_overview
    get "projects/:project_id/project_custom_fields_sidebar", to: "overviews/overviews#project_custom_fields_sidebar",
                                                              as: :project_custom_fields_sidebar
    get "projects/:project_id/project_custom_field_section_dialog/:section_id", to: "overviews/overviews#project_custom_field_section_dialog",
                                                                                as: :project_custom_field_section_dialog
    put "projects/:project_id/update_project_custom_values/:section_id", to: "overviews/overviews#update_project_custom_values",
                                                                         as: :update_project_custom_values

    get "projects/:project_id/project_life_cycles_sidebar", to: "overviews/overviews#project_life_cycles_sidebar",
                                                            as: :project_life_cycles_sidebar
    get "projects/:project_id/project_life_cycles_dialog", to: "overviews/overviews#project_life_cycles_dialog",
                                                           as: :project_life_cycles_dialog
    put "projects/:project_id/project_life_cycles_form",   to: "overviews/overviews#project_life_cycles_form",
                                                           as: :project_life_cycles_form
    put "projects/:project_id/update_project_life_cycles", to: "overviews/overviews#update_project_life_cycles",
                                                           as: :update_project_life_cycles
  end
end
