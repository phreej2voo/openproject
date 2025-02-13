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

module OpPrimer
  class BorderBoxRowComponent < RowComponent # rubocop:disable OpenProject/AddPreviewForViewComponent
    include ComponentHelpers

    def mobile_label(column)
      return unless table.mobile_labels.include?(column)

      table.column_title(column)
    end

    def visible_on_mobile?(column)
      table.mobile_columns.include?(column)
    end

    def grid_column_classes(column)
      classes = ["op-border-box-grid--row-item"]
      classes << column_css_class(column)
      classes << "op-border-box-grid--main-column" if table.main_column?(column)
      classes << "ellipsis" unless table.main_column?(column)
      classes << "op-border-box-grid--no-mobile" unless visible_on_mobile?(column)

      classes.compact.join(" ")
    end

    def column_args(_column)
      {}
    end

    def checkmark(condition)
      if condition
        render(Primer::Beta::Octicon.new(icon: :check))
      end
    end
  end
end
