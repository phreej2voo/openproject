# frozen_string_literal: true

module OpenProject::Users
  # @logical_path OpenProject/Users
  class AvatarComponentPreview < Lookbook::Preview
    # Renders a user avatar using the OpenProject opce-principal web component.
    # Please note that hover cards will not be displayed in the preview, since the necessary Javascript controller
    # is not loaded.
    # @param size select { choices: [default, medium, mini] }
    # @param link toggle
    # @param show_name toggle
    # @param hover_card toggle
    def default(size: :default, link: true, show_name: true, hover_card: true)
      user = FactoryBot.build_stubbed(:user)
      render(Users::AvatarComponent.new(user:, size:, link:, show_name:,
                                        hover_card: { active: hover_card }))
    end

    def sizes
      user = FactoryBot.build_stubbed(:user)
      render_with_template(locals: { user: })
    end
  end
end
