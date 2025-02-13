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

module WorkPackages
  module Types
    class SubjectConfigurationComponent < ApplicationComponent
      include OpPrimer::ComponentHelpers
      include OpTurbo::Streamable

      def form_options
        form_model = subject_form_object

        {
          url: subject_configuration_type_path(id: model.id),
          method: :put,
          model: form_model,
          data: {
            application_target: "dynamic",
            controller: "admin--subject-configuration",
            admin__subject_configuration_hide_pattern_input_value: form_model.subject_configuration == :manual
          }
        }
      end

      private

      def subject_form_object
        subject_pattern = model.patterns.subject || ::Types::Pattern.new(blueprint: "", enabled: false)

        ::Types::Forms::SubjectConfigurationFormModel.new(
          subject_configuration: subject_pattern.enabled ? :generated : :manual,
          pattern: subject_pattern.blueprint,
          suggestions: ::Types::Patterns::TokenPropertyMapper.new.tokens_for_type(model),
          validation_errors: model.errors
        )
      end
    end
  end
end
