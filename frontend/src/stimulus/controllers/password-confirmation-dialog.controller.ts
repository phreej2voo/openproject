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
 */

import { ApplicationController } from 'stimulus-use';
import {
  PasswordConfirmationModalComponent,
} from 'core-app/shared/components/modals/request-for-confirmation/password-confirmation.modal';

export default class PasswordConfirmationDialogController extends ApplicationController {
  private formListener:(evt:SubmitEvent) => unknown = this.onFormSubmit.bind(this);

  private activeDialog = false;

  connect() {
    super.connect();

    this.element.addEventListener('submit', this.formListener);
  }

  disconnect() {
    super.disconnect();

    this.element.removeEventListener('submit', this.formListener);
  }

  private async onFormSubmit(event:SubmitEvent) {
    const form = this.element as HTMLFormElement;
    const passwordConfirm = this.element.querySelector('#hidden_password_confirmation');

    if (passwordConfirm !== null) {
      return true;
    }

    event.preventDefault();
    const pluginContext = await window.OpenProject.getPluginContext();
    const opModalService = pluginContext.services.opModalService;

    // If already opened, do not open another dialog
    if (this.activeDialog) {
      return false;
    }

    this.activeDialog = true;
    opModalService
      .show(PasswordConfirmationModalComponent, 'global')
      .subscribe((modal) => modal.closingEvent.subscribe(() => {
        this.activeDialog = false;

        if (!modal.confirmed) {
          return;
        }

        const input = document.createElement('input');
        input.type = 'hidden';
        input.id = 'hidden_password_confirmation';
        input.name = '_password_confirmation';
        input.value = modal.password_confirmation as string;

        form.append(input);
        form.requestSubmit(event?.submitter);
      }));

    return false;
  }
}
