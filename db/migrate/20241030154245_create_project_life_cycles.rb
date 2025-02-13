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

class CreateProjectLifeCycles < ActiveRecord::Migration[7.1]
  def change
    create_table :project_life_cycle_step_definitions do |t|
      t.string :type
      t.string :name
      t.integer :position, null: true
      t.references :color, foreign_key: true

      t.timestamps
    end

    create_table :project_life_cycle_steps do |t|
      t.string :type
      t.date :start_date
      t.date :end_date
      t.boolean :active, default: false, null: false
      t.references :project, foreign_key: true
      t.references :definition, foreign_key: { to_table: :project_life_cycle_step_definitions }

      t.timestamps
    end

    add_reference :work_packages, :project_life_cycle_step, null: true
  end
end
