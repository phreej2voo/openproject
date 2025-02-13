/*
 * -- copyright
 * OpenProject is an open source project management software.
 * Copyright (C) the OpenProject GmbH
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License version 3.
 *
 * OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
 * Copyright (C) 2006-2013 Jean-Philippe Lang
 * Copyright (C) 2010-2013 the ChiliProject Team
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 *
 * See COPYRIGHT and LICENSE files for more details.
 * ++
 *
 */

import { Controller } from '@hotwired/stimulus';
import { outputChronicDuration, parseChronicDuration } from 'core-app/shared/helpers/chronic_duration';

export default class ChronicDurationController extends Controller<HTMLInputElement> {
  private processChangeFn = () => this.onBlur();
  private keyPressedFn = (evt:KeyboardEvent) => this.onKeyPress(evt);

  connect() {
    this.element.addEventListener('blur', this.processChangeFn);
    this.element.addEventListener('keypress', this.keyPressedFn);
  }

  disconnect() {
    super.disconnect();

    this.element.removeEventListener('blur', this.processChangeFn);
    this.element.removeEventListener('keypress', this.keyPressedFn);
  }

  private onBlur() {
    const value = this.element.value;
    const hours = parseChronicDuration(
      value,
      {
        defaultUnit: 'hours', ignoreSecondsWhenColonSeperated: true,
      },
    );

    this.element.value = outputChronicDuration(hours, { format: 'hours_only' }) || '';
  }

  private onKeyPress(evt:KeyboardEvent) {
    if (evt.key === 'Enter' && evt.currentTarget === this.element) {
      this.element.blur();
    }
  }
}
