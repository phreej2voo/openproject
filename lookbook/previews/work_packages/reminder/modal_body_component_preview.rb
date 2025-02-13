module WorkPackages
  module Reminder
    # @logical_path OpenProject/WorkPackages/Reminder
    class ModalBodyComponentPreview < Lookbook::Preview
      def new
        remindable = FactoryBot.build_stubbed(:work_package)
        reminder = FactoryBot.build(:reminder, remindable:)
        errors = []

        render_with_template(locals: { remindable:, reminder:, errors: })
      end

      def edit
        remindable = FactoryBot.build_stubbed(:work_package)
        reminder = FactoryBot.build_stubbed(:reminder, remindable:)
        errors = []

        render_with_template(locals: { remindable:, reminder:, errors: })
      end
    end
  end
end
