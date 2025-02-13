module OpenProject
  module Common
    # @logical_path OpenProject/Common
    class DatepickerPreview < Lookbook::Preview
      ##
      # **Single date picker**
      # ---------------------
      # The basic date picker is a key element in OpenProject and is displayed
      # any time the user has to input a date.
      #
      # Basic date pickers are attached to existing date input fields
      # and is displayed as a drop-down when that date input field is in focus.
      # It consists of only the mini-calendar component.
      #
      # The basic date picker can also be placed inside modals
      # like the work package date drop modal and the Baseline drop modal.
      # All date picker are built on the [Flatpickr javascript library](https://flatpickr.js.org/).
      #
      # On mobile devices, the component will automatically degrade to the device's native date picker.
      #
      # For more complex implementations involving date pickers (the work package date field or the baseline modal),
      # please refer to documentation concerning those specific features for notes on mobile-specific rendering.
      #
      # The library gives us certain functionality out of the box with a fairly high degree of customisation,
      # but also introduces limits (which will be mentioned below when relevant).
      #
      # Please read the [Flatpickr documentation](https://flatpickr.js.org/instance-methods-properties-elements/)
      # before using or contributing to date pickers.
      #
      # @param value date
      # @param in_dialog toggle
      # @param icon [Symbol] octicon
      def single(value: Time.zone.today, in_dialog: false, icon: :calendar)
        render_with_template(locals: { value:, in_dialog:, icon: })
      end

      ##
      # **Range date picker**
      # ---------------------
      # Range datepicker allow inputing a range (2023-02-09 - 2023-02-14),
      # and shows the date picker with two months.
      #
      # All date picker are built on the [Flatpickr javascript library](https://flatpickr.js.org/).
      # On mobile devices, the component will automatically degrade to two inputs with the device's native date picker.
      #
      # The library gives us certain functionality out of the box with a fairly high degree of customisation,
      # but also introduces limits (which will be mentioned below when relevant).
      #
      # Please read the [Flatpickr documentation](https://flatpickr.js.org/instance-methods-properties-elements/)
      # before using or contributing to date pickers.
      #
      # @param value text
      # @param in_dialog toggle
      # @param icon [Symbol] octicon
      def range(value: "#{Time.zone.today.iso8601} - #{Time.zone.today.iso8601}", in_dialog: false, icon: :calendar)
        render_with_template(locals: { value:, in_dialog:, icon: })
      end
    end
  end
end
