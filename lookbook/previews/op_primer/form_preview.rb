# frozen_string_literal: true

module OpPrimer
  # @logical_path OpenProject/Primer
  # @display min_height 300px
  class FormPreview < Lookbook::Preview
    # @label Preview
    # @param answer
    def default(answer: nil)
      preview_path =
        Lookbook::Engine
          .routes
          .url_helpers
          .lookbook_preview_path(path: "OpenProject/Primer/form/default")
      render_with_template(locals: { answer:, preview_path: })
    end
  end
end
