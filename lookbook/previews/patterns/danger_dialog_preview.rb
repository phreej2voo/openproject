# frozen_string_literal: true

module Patterns
  # @hidden
  class DangerDialogPreview < ViewComponent::Preview
    # @display min_height 400px
    def default
      render_with_template
    end
  end
end
