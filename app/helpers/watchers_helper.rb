#-- copyright
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
#++

module WatchersHelper
  # Create a link to watch/unwatch object
  #
  # * :replace - a string or array of strings with css selectors that will be updated, whenever the watcher status is changed
  def watcher_link(object, user, options = {})
    options = { replace: ".watcher_link", class: "watcher_link" }.merge(options)

    return "" unless valid_watcher_conditions?(object, user, options)

    watched = object.watched_by?(user)

    path = watcher_path(object, watched, options)

    html_options = prepare_html_options(watched, options)

    link_to_watcher_button(watched, path, html_options)
  end

  def watcher_action_button(container, object)
    watcher_button_args = watcher_button_arguments(object, User.current)
    return if watcher_button_args.nil?

    container.with_action_button(**watcher_button_args) do |button|
      button.with_leading_visual_icon(icon: watcher_button_args[:mobile_icon])
      watcher_button_args[:mobile_label]
    end
  end

  def watcher_button_arguments(object, user)
    return nil unless user&.logged? && object.respond_to?(:watched_by?)

    watched = object.watched_by?(user)

    path = send(:"#{(watched ? 'unwatch' : 'watch')}_path",
                object_type: object.class.to_s.underscore.pluralize,
                object_id: object.id)

    method = watched ? :delete : :post

    label = watched ? I18n.t(:button_unwatch) : I18n.t(:button_watch)

    {
      tag: :a,
      href: path,
      scheme: :default,
      aria: { label: label },
      data: {
        method:
      },
      mobile_icon: watched ? "eye-closed" : "eye",
      mobile_label: label
    }
  end

  private

  def valid_watcher_conditions?(object, user, options)
    raise ArgumentError, "Missing :replace option in options hash" if options[:replace].blank?

    user&.logged? && object.respond_to?(:watched_by?)
  end

  def watcher_path(object, watched, options)
    action = watched ? "unwatch" : "watch"
    send(:"#{action}_path", object_type: object.class.to_s.underscore.pluralize, object_id: object.id, replace: options[:replace])
  end

  def prepare_html_options(watched, options)
    options.merge(
      class: "#{options[:class]} button",
      method: watched ? :delete : :post
    )
  end

  def link_to_watcher_button(watched, path, html_options)
    label = watched ? I18n.t(:button_unwatch) : I18n.t(:button_watch)
    icon_class = watched ? "icon-watched" : "icon-unwatched"

    link_to(
      content_tag(:i, "", class: "button--icon #{icon_class}") +
        content_tag(:span, label, class: "button--text"),
      path,
      html_options
    )
  end
end
