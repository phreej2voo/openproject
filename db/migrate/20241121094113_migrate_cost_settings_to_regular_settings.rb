class MigrateCostSettingsToRegularSettings < ActiveRecord::Migration[7.1]
  def up
    costs_settings = Setting.plugin_costs || {}
    if costs_settings["costs_currency"]
      Setting.create(name: "costs_currency", value: costs_settings["costs_currency"])
    end

    if costs_settings["costs_currency_format"]
      Setting.create(name: "costs_currency_format", value: costs_settings["costs_currency_format"])
    end

    Setting.where(name: "plugin_costs").destroy_all
  end

  def down
    costs_settings = {
      "costs_currency" => Setting.costs_currency,
      "costs_currency_format" => Setting.costs_currency_format
    }

    Setting.create(name: "plugin_costs", value: costs_settings)
    Setting.where(name: ["costs_currency", "costs_currency_format"]).destroy_all
  end
end
