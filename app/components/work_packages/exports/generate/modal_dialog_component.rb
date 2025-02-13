# frozen_string_literal: true

# -- copyright
# OpenProject is an open source project management software.
# Copyright (C) the OpenProject GmbH
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
# ++
require "text/hyphen"

module WorkPackages
  module Exports
    module Generate
      class ModalDialogComponent < ApplicationComponent
        MODAL_ID = "op-work-package-generate-pdf-dialog"
        GENERATE_PDF_FORM_ID = "op-work-packages-generate-pdf-dialog-form"
        include OpTurbo::Streamable
        include OpPrimer::ComponentHelpers

        attr_reader :work_package, :params

        def initialize(work_package:, params:)
          super

          @work_package = work_package
          @params = params
        end

        def default_header_text_right
          "#{work_package.type} ##{work_package.id}"
        end

        def default_footer_text_center
          work_package.subject
        end

        def generate_selects
          [
            {
              name: "hyphenation",
              label: I18n.t("pdf_generator.dialog.hyphenation.label"),
              caption: I18n.t("pdf_generator.dialog.hyphenation.caption"),
              options: hyphenation_options
            },
            {
              name: "paper_size",
              label: I18n.t("pdf_generator.dialog.paper_size.label"),
              caption: I18n.t("pdf_generator.dialog.paper_size.caption"),
              options: paper_size_options
            }
          ]
        end

        def hyphenation_options
          # This is a list of languages that are supported by the hyphenation library
          # https://rubygems.org/gems/text-hyphen
          # The labels are the language names in the language itself (NOT to be put I18n)
          supported_languages = [
            { label: "Català", value: "ca" },
            { label: "Dansk", value: "da" },
            { label: "Deutsch", value: "de" },
            { label: "Eesti", value: "et" },
            { label: "English (UK)", value: "en_uk" },
            { label: "English (USA)", value: "en_us" },
            { label: "Español", value: "es" },
            { label: "Euskara", value: "eu" },
            { label: "Français", value: "fr" },
            { label: "Gaeilge", value: "ga" },
            { label: "Hrvatski", value: "hr" },
            { label: "Indonesia", value: "id" },
            { label: "Interlingua", value: "ia" },
            { label: "Italiano", value: "it" },
            { label: "Magyar", value: "hu" },
            { label: "Melayu", value: "ms" },
            { label: "Nederlands", value: "nl" },
            { label: "Norsk", value: "no" },
            { label: "Polski", value: "pl" },
            { label: "Português", value: "pt" },
            { label: "Slovenčina", value: "sk" },
            { label: "Suomi", value: "fi" },
            { label: "Svenska", value: "sv" },
            { label: "Ísland", value: "is" },
            { label: "Čeština", value: "cs" },
            { label: "Монгол", value: "mn" },
            { label: "Русский", value: "ru" }
          ]

          [{ value: "", label: "Off", default: true }].concat(supported_languages)
        end

        def paper_size_options
          [
            { label: "A4", value: "A4", default: true },
            { label: "A3", value: "A3" },
            { label: "A2", value: "A2" },
            { label: "A1", value: "A1" },
            { label: "A0", value: "A0" },
            { label: "Executive", value: "EXECUTIVE" },
            { label: "Folio", value: "FOLIO" },
            { label: "Letter", value: "LETTER" },
            { label: "Tabloid", value: "TABLOID" }
          ]
        end
      end
    end
  end
end
