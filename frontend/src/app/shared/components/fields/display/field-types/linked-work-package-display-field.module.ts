//-- copyright
// OpenProject is an open source project management software.
// Copyright (C) the OpenProject GmbH
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License version 3.
//
// OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
// Copyright (C) 2006-2013 Jean-Philippe Lang
// Copyright (C) 2010-2013 the ChiliProject Team
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
//
// See COPYRIGHT and LICENSE files for more details.
//++

import { StateService } from '@uirouter/core';
import { KeepTabService } from 'core-app/features/work-packages/components/wp-single-view-tabs/keep-tab/keep-tab.service';
import { UiStateLinkBuilder } from 'core-app/features/work-packages/components/wp-fast-table/builders/ui-state-link-builder';
import { WorkPackageDisplayField } from 'core-app/shared/components/fields/display/field-types/work-package-display-field.module';
import { InjectField } from 'core-app/shared/helpers/angular/inject-field.decorator';

export class LinkedWorkPackageDisplayField extends WorkPackageDisplayField {
  public text = {
    linkTitle: this.I18n.t('js.work_packages.message_successful_show_in_fullscreen'),
    none: this.I18n.t('js.filter.noneElement'),
  };

  @InjectField() $state!:StateService;

  @InjectField() keepTab!:KeepTabService;

  private uiStateBuilder:UiStateLinkBuilder = new UiStateLinkBuilder(this.$state, this.keepTab);

  public render(element:HTMLElement, displayText:string):void {
    if (this.isEmpty()) {
      element.innerText = this.placeholder;
      return;
    }

    const link = this.uiStateBuilder.linkToShow(
      this.wpId,
      this.text.linkTitle,
      this.valueString,
    );

    const title = document.createElement('span');
    title.textContent = ` ${_.truncate(this.title, { length: 40 })}`;

    element.innerHTML = '';
    element.appendChild(link);
    element.appendChild(title);
  }

  public get writable():boolean {
    return false;
  }

  public get valueString() {
    return `#${this.wpId}`;
  }
}
