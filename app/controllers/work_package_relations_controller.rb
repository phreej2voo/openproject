# frozen_string_literal: true

#-- copyright
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
#++

class WorkPackageRelationsController < ApplicationController
  include OpTurbo::ComponentStream
  include OpTurbo::DialogStreamHelper

  before_action :set_work_package
  before_action :set_relation, except: %i[new create]
  before_action :authorize

  def new
    @relation = @work_package.relations.build(
      from: @work_package,
      relation_type: params[:relation_type]
    )

    respond_with_dialog(
      WorkPackageRelationsTab::WorkPackageRelationDialogComponent
        .new(work_package: @work_package, relation: @relation)
    )
  end

  def edit
    respond_with_dialog(
      WorkPackageRelationsTab::WorkPackageRelationDialogComponent
        .new(work_package: @work_package, relation: @relation)
    )
  end

  def create
    service_result = Relations::CreateService.new(user: current_user)
                                             .call(create_relation_params)

    respond_with_relations_tab_update(service_result, relation_to_scroll_to: service_result.result)

    if service_result.failure?
      update_via_turbo_stream(
        component: WorkPackageRelationsTab::WorkPackageRelationFormComponent.new(work_package: @work_package,
                                                                                 relation: service_result.result,
                                                                                 base_errors: service_result.errors[:base]),
        status: :bad_request
      )
    end
  end

  def update
    service_result = Relations::UpdateService
      .new(user: current_user,
           model: @relation)
      .call(update_relation_params)

    respond_with_relations_tab_update(service_result)
    if service_result.failure?
      update_via_turbo_stream(
        component: WorkPackageRelationsTab::WorkPackageRelationFormComponent.new(work_package: @work_package,
                                                                                 relation: service_result.result,
                                                                                 base_errors: service_result.errors[:base]),
        status: :bad_request
      )
    end
  end

  def destroy
    service_result = Relations::DeleteService.new(user: current_user, model: @relation).call

    respond_with_relations_tab_update(service_result)
  end

  private

  def respond_with_relations_tab_update(service_result, **)
    if service_result.success?
      @work_package.reload
      component = WorkPackageRelationsTab::IndexComponent.new(work_package: @work_package, **)
      replace_via_turbo_stream(component:)
      render_success_flash_message_via_turbo_stream(message: I18n.t(:notice_successful_update))

      respond_with_turbo_streams
    else
      respond_with_turbo_streams(status: :unprocessable_entity)
    end
  end

  def set_work_package
    @work_package = WorkPackage.find(params[:work_package_id])
  end

  def set_relation
    @relation = @work_package.relations.find(params[:id])
  end

  def create_relation_params
    params.require(:relation)
          .permit(:relation_type, :to_id, :description, :lag)
          .merge(from_id: @work_package.id)
  end

  def update_relation_params
    params.require(:relation)
          .permit(:description, :lag)
  end
end
