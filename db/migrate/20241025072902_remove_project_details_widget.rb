class RemoveProjectDetailsWidget < ActiveRecord::Migration[7.1]
  def up
    # The joining of the overview grids is not strictly necessary
    # but it ensures that only widgets of overview grids are removed.
    execute <<~SQL.squish
      DELETE FROM grid_widgets
      USING grids
      WHERE grids.id = grid_widgets.grid_id
        AND grids.type = 'Grids::Overview'
        AND grid_widgets.identifier = 'project_details'
    SQL
  end
end
