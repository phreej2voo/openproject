class SetVersionsNameCollation < ActiveRecord::Migration[7.1]
  def up
    begin
      execute <<-SQL.squish
        CREATE COLLATION IF NOT EXISTS versions_name (provider = icu, locale = 'und-u-kn-true');
      SQL
    rescue StandardError => e
      raise unless e.message.include?("encoding")

      abort <<~MESSAGE
        \e[31mERROR:\e[0m Failed to create an ICU collation with current database encoding.
        You need to change the database encoding before proceeding.

        Please check the instructions on how to do it:
        https://www.openproject.org/docs/installation-and-operations/misc/changing-database-encoding/

        Original error:
          #{e.message}
      MESSAGE
    end

    change_column :versions, :name, :string, collation: "versions_name"
  end

  def down
    change_column :versions, :name, :string
  end
end
