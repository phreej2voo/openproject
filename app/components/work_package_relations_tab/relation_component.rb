class WorkPackageRelationsTab::RelationComponent < ApplicationComponent
  include ApplicationHelper
  include OpPrimer::ComponentHelpers

  attr_reader :work_package, :relation, :child, :visibility

  def initialize(work_package:,
                 relation:,
                 visibility:,
                 child: nil)
    super()

    @work_package = work_package
    @relation = relation
    @visibility = visibility
    @child = child
  end

  def related_work_package
    @related_work_package ||= if parent_child_relationship?
                                @child
                              else
                                relation.from == work_package ? relation.to : relation.from
                              end
  end

  private

  def parent_child_relationship? = @child.present?

  def should_render_edit_option?
    # Children have nothing to edit as it's not a relation.
    !parent_child_relationship? && allowed_to_manage_relations?
  end

  def should_render_action_menu?
    if parent_child_relationship?
      allowed_to_manage_subtasks?
    else
      allowed_to_manage_relations?
    end
  end

  def allowed_to_manage_subtasks?
    helpers.current_user.allowed_in_project?(:manage_subtasks, @work_package.project)
  end

  def allowed_to_manage_relations?
    helpers.current_user.allowed_in_project?(:manage_work_package_relations, @work_package.project)
  end

  def visible?
    @visibility == :visible
  end

  def underlying_resource_id
    @underlying_resource_id ||= if parent_child_relationship?
                                  @child.id
                                else
                                  @relation.other_work_package(work_package).id
                                end
  end

  def should_display_description?
    return false if parent_child_relationship?

    relation.description.present?
  end

  def lag_present?
    relation.lag.present? && relation.lag != 0
  end

  def should_display_dates_row?
    parent_child_relationship? || relation.follows? || relation.precedes?
  end

  def follows?
    return false if parent_child_relationship?

    relation.relation_type_for(work_package) == Relation::TYPE_FOLLOWS
  end

  def precedes?
    return false if parent_child_relationship?

    relation.relation_type_for(work_package) == Relation::TYPE_PRECEDES
  end

  def edit_path
    if parent_child_relationship?
      raise NotImplementedError, "Children relationships are not editable"
    else
      edit_work_package_relation_path(@work_package, @relation)
    end
  end

  def destroy_path
    if parent_child_relationship?
      work_package_children_relation_path(@work_package, @child)
    else
      work_package_relation_path(@work_package, @relation)
    end
  end

  def lag_as_text(lag)
    "#{I18n.t('work_package_relations_tab.lag.subject')}: #{I18n.t('datetime.distance_in_words.x_days', count: lag)}"
  end

  def action_menu_test_selector
    "op-relation-row-#{underlying_resource_id}-action-menu"
  end

  def edit_button_test_selector
    "op-relation-row-#{underlying_resource_id}-edit-button"
  end

  def delete_button_test_selector
    "op-relation-row-#{underlying_resource_id}-delete-button"
  end
end
