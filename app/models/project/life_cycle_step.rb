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

class Project::LifeCycleStep < ApplicationRecord
  belongs_to :project, optional: false, inverse_of: :available_life_cycle_steps
  belongs_to :definition,
             optional: false,
             class_name: "Project::LifeCycleStepDefinition"
  has_many :work_packages, inverse_of: :project_life_cycle_step, dependent: :nullify

  delegate :name, :position, to: :definition

  attr_readonly :definition_id, :type

  validates :type, inclusion: { in: %w[Project::Stage Project::Gate], message: :must_be_a_stage_or_gate }
  validate :validate_type_and_class_name_are_identical

  scope :active, -> { where(active: true) }

  class << self
    def visible(user = User.current)
      allowed_projects = Project.allowed_to(user, :view_project_stages_and_gates)
      active.where(project: allowed_projects)
    end
  end

  def validate_type_and_class_name_are_identical
    if type != self.class.name
      errors.add(:type, :type_and_class_name_mismatch)
    end
  end

  def column_name
    # The id of the associated definition is relevant for displaying the correct column headers
    "lcsd_#{definition_id}"
  end
end
