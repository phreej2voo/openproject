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

require "support/components/common/modal"
require "support/components/autocompleter/ng_select_autocomplete_helpers"
module Components
  module Projects
    module ProjectLifeCycles
      class EditDialog < Components::Common::Modal
        def dialog_css_selector
          "dialog#edit-project-life-cycles-dialog"
        end

        def async_content_container_css_selector
          "#{dialog_css_selector} [data-test-selector='async-dialog-content']"
        end

        def within_dialog(&)
          within(dialog_css_selector, &)
        end

        def within_async_content(close_after_yield: false, &)
          within(async_content_container_css_selector, &)
          close if close_after_yield
        end

        def set_date_for(step, value:)
          dialog_selector = "##{::ProjectLifeCycles::Sections::EditDialogComponent::DIALOG_ID}"

          datepicker = if value.is_a?(Array)
                         Components::RangeDatepicker.new(dialog_selector)
                       else
                         Components::BasicDatepicker.new(dialog_selector)
                       end

          datepicker.open(
            "input[id^='project_available_life_cycle_steps_attributes_#{step.position - 1}']"
          )

          Array(value).each do |date|
            datepicker.set_date(date.strftime("%Y-%m-%d"))
          end
        end

        def close
          within_dialog do
            page.find(".close-button").click
          end
        end
        alias_method :close_via_icon, :close

        def close_via_button
          within(dialog_css_selector) do
            click_link_or_button "Cancel"
          end
        end

        def submit
          within(dialog_css_selector) do
            page.find("[data-test-selector='save-project-life-cycles-button']").click
          end
        end

        def expect_open
          expect(page).to have_css(dialog_css_selector)
        end

        def expect_closed
          expect(page).to have_no_css(dialog_css_selector)
        end

        def expect_async_content_loaded
          expect(page).to have_css(async_content_container_css_selector)
        end

        def expect_input(label, value:, type:, position:)
          field = type == :stage ? :date_range : :date
          within_async_content do
            expect(page).to have_field(
              label,
              with: value,
              name: "project[available_life_cycle_steps_attributes][#{position - 1}][#{field}]"
            )
          end
        end

        def expect_input_for(step)
          options = if step.is_a?(Project::Stage)
                      value = "#{step.start_date.strftime('%Y-%m-%d')} - #{step.end_date.strftime('%Y-%m-%d')}"
                      { type: :stage, value: }
                    else
                      value = step.date.strftime("%Y-%m-%d")
                      { type: :gate, value: }
                    end

          expect_input(step.name, position: step.position, **options)
        end

        def expect_caption(step, text: nil, present: true)
          selector = 'span[id^="caption"]'
          expect_selector_for(step, selector:, text:, present:)
        end

        def expect_no_caption(step)
          expect_caption(step, present: false)
        end

        def expect_validation_message(step, text: nil, present: true)
          selector = 'div[id^="validation"]'
          expect_selector_for(step, selector:, text:, present:)
        end

        def expect_no_validation_message(step)
          expect_validation_message(step, present: false)
        end

        private

        def expect_selector_for(step, selector:, text: nil, present: true)
          within_async_content do
            field = step.is_a?(Project::Stage) ? :date_range : :date
            input_id = "#project_available_life_cycle_steps_attributes_#{step.position - 1}_#{field}"
            parent = find(input_id).ancestor("primer-datepicker-field")

            if present
              expect(parent).to have_selector(selector, text:)
            else
              expect(parent).to have_no_selector(selector)
            end
          end
        end
      end
    end
  end
end
