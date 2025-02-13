#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) 2012-2024 the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See COPYRIGHT and LICENSE files for more details.
#++

module Saml
  module Providers
    class MappingForm < BaseForm
      form do |f|
        f.text_area(
          name: :mapping_login,
          label: I18n.t("label_mapping_for", attribute: User.human_attribute_name(:login)),
          caption: I18n.t("saml.instructions.mapping_login"),
          required: true,
          disabled: provider.seeded_from_env?,
          rows: 8,
          input_width: :large
        )
        f.text_area(
          name: :mapping_mail,
          label: I18n.t("label_mapping_for", attribute: User.human_attribute_name(:mail)),
          caption: I18n.t("saml.instructions.mapping_mail"),
          required: true,
          disabled: provider.seeded_from_env?,
          rows: 8,
          input_width: :large
        )
        f.text_area(
          name: :mapping_firstname,
          label: I18n.t("label_mapping_for", attribute: User.human_attribute_name(:first_name)),
          caption: I18n.t("saml.instructions.mapping_firstname"),
          required: true,
          disabled: provider.seeded_from_env?,
          rows: 8,
          input_width: :large
        )
        f.text_area(
          name: :mapping_lastname,
          label: I18n.t("label_mapping_for", attribute: User.human_attribute_name(:last_name)),
          caption: I18n.t("saml.instructions.mapping_lastname"),
          required: true,
          disabled: provider.seeded_from_env?,
          rows: 8,
          input_width: :large
        )
        f.text_field(
          name: :mapping_uid,
          label: I18n.t("label_mapping_for", attribute: I18n.t("saml.providers.label_uid")),
          caption: I18n.t("saml.instructions.mapping_uid"),
          disabled: provider.seeded_from_env?,
          rows: 8,
          required: false,
          input_width: :large
        )
      end
    end
  end
end
