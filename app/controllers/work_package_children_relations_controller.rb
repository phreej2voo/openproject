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

class WorkPackageChildrenRelationsController < ApplicationController
  include OpTurbo::ComponentStream
  include OpTurbo::DialogStreamHelper

  before_action :set_work_package

  before_action :authorize # Short-circuit early if not authorized

  def new
    component = WorkPackageRelationsTab::AddWorkPackageChildDialogComponent
      .new(work_package: @work_package)
    respond_with_dialog(component)
  end

  def create
    child = WorkPackage.find(params[:work_package][:id])
    service_result = set_relation(child:, parent: @work_package)

    respond_with_relations_tab_update(service_result, relation_to_scroll_to: service_result.result)
  end

  def destroy
    child = WorkPackage.find(params[:id])
    service_result = set_relation(child:, parent: nil)

    respond_with_relations_tab_update(service_result)
  end

  private

  def set_relation(child:, parent:)
    WorkPackages::UpdateService.new(user: current_user, model: child)
                               .call(parent:)
  end

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
    @project = @work_package.project
  end
end
