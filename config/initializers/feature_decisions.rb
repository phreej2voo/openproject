# --copyright
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

require_relative "../../lib_static/open_project/feature_decisions"

# Add feature flags here via e.g.
#
#   OpenProject::FeatureDecisions.add :some_flag
#
# If the feature to be flag-guarded stems from a module, add an initializer
# to that module's engine:
#
#   initializer 'the_engine.feature_decisions' do
#     OpenProject::FeatureDecisions.add :some_flag
#   end

OpenProject::FeatureDecisions.add :built_in_oauth_applications,
                                  description: "Allows the display and use of built-in OAuth applications."

OpenProject::FeatureDecisions.add :generate_pdf_from_work_package,
                                  description: "Allows to generate a PDF document from a work package description. " \
                                               "See #45896 for details."

OpenProject::FeatureDecisions.add :generate_work_package_subjects,
                                  description: "Allows the configuration for work package types to have " \
                                               "automatically generated work package subjects."

OpenProject::FeatureDecisions.add :stages_and_gates,
                                  description: "Enables the under construction feature of stages and gates."

OpenProject::FeatureDecisions.add :oidc_token_exchange,
                                  description: "Enables the under construction OAuth2 token exchange, allowing " \
                                               "users to interact with storage providers without consenting " \
                                               "in OAuth screens before first use."

OpenProject::FeatureDecisions.add :work_package_comment_id_url,
                                  description: "Introduced a new WP comment URL identifier structure " \
                                               "`#comment-<journal-id>` replacing the old " \
                                               "`#activity-<journal-sequence_number>`."
