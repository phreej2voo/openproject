module OpenProject
  module Projects
    # @logical_path OpenProject/Projects
    class LifeCycleTypeComponentPreview < Lookbook::Preview
      def gate
        render_with_template(locals: { model: Project::GateDefinition.new(id: 1, name: "The first gate") })
      end

      def stage
        render_with_template(locals: { model: Project::StageDefinition.new(id: 1, name: "The first stage") })
      end
    end
  end
end
