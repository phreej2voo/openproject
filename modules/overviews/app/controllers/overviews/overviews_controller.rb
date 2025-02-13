# -- copyright
# OpenProject is an open source project management software.
# Copyright (C) the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See COPYRIGHT and LICENSE files for more details.
# ++

module ::Overviews
  class OverviewsController < ::Grids::BaseInProjectController
    include OpTurbo::ComponentStream
    include OpTurbo::DialogStreamHelper

    before_action :jump_to_project_menu_item
    before_action :set_sidebar_enabled

    menu_item :overview

    def show
      render
    end

    def project_custom_fields_sidebar
      render :project_custom_fields_sidebar, layout: false
    end

    def project_custom_field_section_dialog
      respond_with_dialog(
        ProjectCustomFields::Sections::EditDialogComponent.new(
          project: @project,
          project_custom_field_section: find_project_custom_field_section
        )
      )
    end

    def update_project_custom_values
      section = find_project_custom_field_section
      service_call = ::Projects::UpdateService
                      .new(
                        user: current_user,
                        model: @project,
                        contract_options: { project_attributes_only: true }
                      )
                      .call(
                        permitted_params.project.merge(
                          _limit_custom_fields_validation_to_section_id: section.id
                        )
                      )

      if service_call.success?
        update_sidebar_component
      else
        handle_errors(service_call.result, section)
      end

      respond_to_with_turbo_streams(status: service_call.success? ? :ok : :unprocessable_entity)
    end

    def project_life_cycles_sidebar
      render :project_life_cycles_sidebar, layout: false
    end

    def project_life_cycles_dialog
      respond_with_dialog(
        ProjectLifeCycles::Sections::EditDialogComponent.new(@project)
      )
    end

    def project_life_cycles_form
      service_call = ::ProjectLifeCycleSteps::PreviewAttributesService
                .new(user: current_user,
                     model: @project,
                     contract_class: ProjectLifeCycleSteps::UpdateContract)
                .call(permitted_params.project_life_cycles)

      update_via_turbo_stream(
        component: ProjectLifeCycles::Sections::EditComponent.new(service_call.result),
        method: "morph"
      )
      # TODO: :unprocessable_entity is not nice, change the dialog logic to accept :ok
      # without dismissing the dialog, alternatively use turbo frames instead of streams.
      respond_to_with_turbo_streams(status: :unprocessable_entity)
    end

    def update_project_life_cycles
      service_call = ::ProjectLifeCycleSteps::UpdateService
                      .new(user: current_user, model: @project)
                      .call(permitted_params.project_life_cycles)

      if service_call.success?
        update_via_turbo_stream(
          component: ProjectLifeCycles::SidePanelComponent.new(project: @project)
        )
      else
        update_via_turbo_stream(
          component: ProjectLifeCycles::Sections::EditComponent.new(service_call.result)
        )
      end

      respond_to_with_turbo_streams(status: service_call.success? ? :ok : :unprocessable_entity)
    end

    def jump_to_project_menu_item
      if params[:jump]
        # try to redirect to the requested menu item
        redirect_to_project_menu_item(@project, params[:jump]) && return
      end
    end

    private

    def find_project_custom_field_section
      ProjectCustomFieldSection.find(params[:section_id])
    end

    def set_sidebar_enabled
      @custom_fields_sidebar_enabled =
        User.current.allowed_in_project?(:view_project_attributes, @project) &&
        @project.project_custom_fields.visible.any?
      @life_cycles_sidebar_enabled =
        OpenProject::FeatureDecisions.stages_and_gates_active? &&
        User.current.allowed_in_project?(:view_project_stages_and_gates, @project) &&
        @project.life_cycle_steps.active.any?
    end

    def handle_errors(project_with_errors, section)
      update_via_turbo_stream(
        component: ProjectCustomFields::Sections::EditComponent.new(
          project: project_with_errors,
          project_custom_field_section: section
        )
      )
    end

    def update_sidebar_component
      update_via_turbo_stream(
        component: ProjectCustomFields::SidePanelComponent.new(project: @project)
      )
    end
  end
end
