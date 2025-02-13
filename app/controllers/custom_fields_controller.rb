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

class CustomFieldsController < ApplicationController
  include CustomFields::SharedActions # share logic with ProjectCustomFieldsControlller
  layout "admin"

  # rubocop:disable Rails/LexicallyScopedActionFilter
  before_action :require_admin
  before_action :find_custom_field, only: %i(edit update destroy delete_option reorder_alphabetical)
  before_action :prepare_custom_option_position, only: %i(update create)
  before_action :find_custom_option, only: :delete_option
  before_action :validate_enterprise_token, only: %i(create)
  # rubocop:enable Rails/LexicallyScopedActionFilter

  def index
    # loading wp cfs exclicity to allow for eager loading
    @custom_fields_by_type = CustomField
      .where.not(type: ["WorkPackageCustomField", "ProjectCustomField"])
      .group_by { |f| f.class.name }

    @custom_fields_by_type["WorkPackageCustomField"] = WorkPackageCustomField.includes(:types).all

    @tab = params[:tab] || "WorkPackageCustomField"
  end

  def new
    @custom_field = new_custom_field

    check_custom_field
  end

  def edit
    check_custom_field
  end

  protected

  def default_breadcrumb; end

  def show_local_breadcrumb
    false
  end

  def validate_enterprise_token
    if params.dig(:custom_field, :field_format) == "hierarchy" && !EnterpriseToken.allows_to?(:custom_field_hierarchies)
      render_403
    end
  end

  def find_custom_field
    @custom_field = CustomField.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def check_custom_field
    # ProjectCustomFields now managed in a different UI
    if @custom_field.nil? || @custom_field.type == "ProjectCustomField"
      flash[:error] = "Invalid CF type"
      redirect_to action: :index
    end
  end
end
