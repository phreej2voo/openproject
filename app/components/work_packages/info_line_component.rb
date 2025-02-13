# frozen_string_literal: true

class WorkPackages::InfoLineComponent < ApplicationComponent
  include OpPrimer::ComponentHelpers

  def initialize(work_package:, font_size: :small)
    super

    @work_package = work_package
    @font_size = font_size
  end
end
