class ApplicationRecord < ActiveRecord::Base
  include ::OpenProject::Acts::Watchable
  include ::OpenProject::Acts::Favorable

  self.abstract_class = true

  ##
  # Determine whether this resource was just created ?
  def just_created?
    saved_change_to_attribute?(:id)
  end

  ##
  # Returns whether the given attribute is free of errors
  def valid_attribute?(attribute)
    valid? # Ensure validations have run

    errors[attribute].empty?
  end

  # We want to add a validation error whenever someone sets a property that we don't know.
  # However AR will cleverly try to resolve the value for erroneous properties. Thus we need
  # to hook into this method and return nil for unknown properties to avoid NoMethod errors...
  def read_attribute_for_validation(attribute)
    super if respond_to?(attribute)
  end

  ##
  # Get the newest recently changed resource for the given record classes
  #
  # e.g., +most_recently_changed(WorkPackage, Type, Status)+
  #
  # Returns the timestamp of the most recently updated value
  def self.most_recently_changed(*record_classes)
    queries = record_classes.map do |clz|
      column_name = clz.send(:timestamp_attributes_for_update_in_model)&.first || "updated_at"
      table = clz.arel_table
      table.project(table[column_name].maximum.as("max_updated_at")).to_sql
    end
      .join(" UNION ")

    union_query = <<~SQL.squish
      SELECT MAX(max_updated_at)
      FROM (#{queries})
      AS union_query
    SQL

    ActiveRecord::Base.connection.select_value(union_query)
  end

  def self.skip_optimistic_locking(&)
    original_lock_optimistically = ActiveRecord::Base.lock_optimistically
    ActiveRecord::Base.lock_optimistically = false
    yield
  ensure
    ActiveRecord::Base.lock_optimistically = original_lock_optimistically
  end
end
