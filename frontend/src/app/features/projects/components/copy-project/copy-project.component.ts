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

import {
  IDynamicFieldGroupConfig,
  IOPFormlyFieldSettings,
  IOPFormlyTemplateOptions,
} from 'core-app/shared/components/dynamic-forms/typings';
import { ApiV3Service } from 'core-app/core/apiv3/api-v3.service';
import { I18nService } from 'core-app/core/i18n/i18n.service';
import { PathHelperService } from 'core-app/core/path-helper/path-helper.service';
import { UntilDestroyedMixin } from 'core-app/shared/helpers/angular/until-destroyed.mixin';
import { CurrentProjectService } from 'core-app/core/current-project/current-project.service';
import { ChangeDetectionStrategy, Component, OnInit } from '@angular/core';
import { JobStatusModalService } from 'core-app/features/job-status/job-status-modal.service';

@Component({
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './copy-project.component.html',
})
export class CopyProjectComponent extends UntilDestroyedMixin implements OnInit {
  dynamicFieldsSettingsPipe = this.fieldSettingsPipe.bind(this);

  fieldGroups:IDynamicFieldGroupConfig[];

  formUrl:string;

  hiddenFields:string[] = [
    'createdAt',
    'identifier',
    'active',
  ];

  text = {
    advancedSettingsLabel: this.I18n.t('js.forms.advanced_settings'),
    copySettingsLabel: this.I18n.t('js.project.copy.copy_options'),
  };

  constructor(
    private apiV3Service:ApiV3Service,
    private currentProjectService:CurrentProjectService,
    private pathHelperService:PathHelperService,
    private jobStatusModalService:JobStatusModalService,
    private I18n:I18nService,
  ) {
    super();
  }

  ngOnInit():void {
    this.formUrl = this.apiV3Service.projects.id(this.currentProjectService.id!).copy.form.path;
    this.fieldGroups = [
      {
        name: this.text.advancedSettingsLabel,
        fieldsFilter: (field:IOPFormlyFieldSettings) => !this.isMeta(field.templateOptions?.property) && !this.isPrimaryAttribute(field.templateOptions),
      },
      {
        name: this.text.copySettingsLabel,
        fieldsFilter: (field:IOPFormlyFieldSettings) => this.isMeta(field.templateOptions?.property),
      },
    ];
  }

  onSubmitted(response:HalSource) {
    this.jobStatusModalService.show(response.jobId as string);
  }

  private isHiddenField(key:string|undefined):boolean {
    return !!key && this.hiddenFields.includes(key);
  }

  private fieldSettingsPipe(dynamicFieldsSettings:IOPFormlyFieldSettings[]):IOPFormlyFieldSettings[] {
    return this.sortedCopyFields(dynamicFieldsSettings)
      .map((field) => ({ ...field, hide: this.isHiddenField(field.key) }));
  }

  private isPrimaryAttribute(templateOptions?:IOPFormlyTemplateOptions):boolean {
    if (!templateOptions) {
      return false;
    }

    const nameOrParent = ['name', 'parent'].includes(templateOptions.property!);
    const noPayload = templateOptions.payloadValue == null
      || templateOptions.payloadValue?.href == null;

    return (templateOptions.required && !templateOptions.hasDefault && noPayload) || nameOrParent;
  }

  private isMeta(property:string|undefined):boolean {
    return !!property && (property.startsWith('copy') || property === 'sendNotifications');
  }

  // Sorts the copy options by their label.
  // The order of the rest of the fields is left unchanged but all copy options are returned first.
  private sortedCopyFields(dynamicFieldsSettings:IOPFormlyFieldSettings[]):IOPFormlyFieldSettings[] {
    const sortedCopyFields = dynamicFieldsSettings
      .filter((field) => field.key && field.key.startsWith('_meta.copy'))
      .sort((fieldA, fieldB) => {
        if (!fieldA.templateOptions
          || !fieldA.templateOptions.label
          || !fieldB.templateOptions
          || !fieldB.templateOptions.label) {
          return 0;
        }

        return fieldA.templateOptions.label.localeCompare(fieldB.templateOptions.label);
      });

    const nonCopyFields = dynamicFieldsSettings
      .filter((field) => !field.key || !field.key.startsWith('_meta.copy'));

    // Now all copy fields are before the non Copy fields.
    // That way, the "Sent notifications" is after the copy fields.
    // For the rest, it does not make a difference since the _meta
    // fields are rendered in a separate group.
    return sortedCopyFields.concat(nonCopyFields);
  }
}
