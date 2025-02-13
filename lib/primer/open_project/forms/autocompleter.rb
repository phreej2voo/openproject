# frozen_string_literal: true

module Primer
  module OpenProject
    module Forms
      # :nodoc:
      class Autocompleter < Primer::Forms::BaseComponent
        include AngularHelper
        prepend WrappedInput

        delegate :builder, :form, to: :@input

        def initialize(input:, autocomplete_options:, wrapper_data_attributes: {})
          super()
          @input = input
          @with_search_icon = autocomplete_options.delete(:with_search_icon) { false }
          @autocomplete_component = autocomplete_options.delete(:component) { "opce-autocompleter" }
          @autocomplete_data = autocomplete_options.delete(:data) { {} }
          @autocomplete_inputs = extend_autocomplete_inputs(autocomplete_options)
          @wrapper_data_attributes = wrapper_data_attributes
        end

        def extend_autocomplete_inputs(inputs) # rubocop:disable Metrics/AbcSize,Metrics/PerceivedComplexity
          inputs[:classes] = "ng-select--primerized #{@input.invalid? ? '-error' : ''}"
          inputs[:inputName] ||= builder.field_name(@input.name)
          inputs[:labelForId] ||= builder.field_id(@input.name)
          inputs[:defaultData] = true unless inputs.key?(:defaultData)

          if inputs.delete(:decorated)
            inputs[:items] = @input.select_options.map(&:to_h)
            selected = @input.select_options.filter_map { |option| option.to_h if option.selected }
            inputs[:model] = inputs[:multiple] ? selected : selected.first
            inputs[:defaultData] = false
            inputs[:additionalClassProperty] = "classes"
            inputs[:bindLabel] = "name"
          elsif builder.object
            inputs[:inputValue] ||= builder.object.send(@input.name)
          end

          inputs
        end
      end
    end
  end
end
