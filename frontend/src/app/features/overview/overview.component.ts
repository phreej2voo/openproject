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

import { ChangeDetectionStrategy, Component } from '@angular/core';
import { GridPageComponent } from 'core-app/shared/components/grids/grid/page/grid-page.component';
import { GRID_PROVIDERS } from 'core-app/shared/components/grids/grid/grid.component';

@Component({
  selector: 'overview',
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: '../../shared/components/grids/grid/page/grid-page.component.html',
  styleUrls: ['../../shared/components/grids/grid/page/grid-page.component.sass'],
  providers: GRID_PROVIDERS,
})
export class OverviewComponent extends GridPageComponent {
  showToolbar = false;

  protected i18nNamespace():string {
    return 'overviews';
  }

  protected isTurboFrameSidebarEnabled():boolean {
    return this.isCustomFieldsSidebarEnabled() || this.isLifeCyclesSidebarEnabled();
  }

  protected isCustomFieldsSidebarEnabled():boolean {
    const customFieldsSidebarEnabledTag:HTMLMetaElement|null = document.querySelector('meta[name="custom_fields_sidebar_enabled"]');

    return customFieldsSidebarEnabledTag?.dataset.enabled === 'true';
  }

  protected isLifeCyclesSidebarEnabled():boolean {
    const lifeCyclesSidebarEnabledTag:HTMLMetaElement|null = document.querySelector('meta[name="life_cycles_sidebar_enabled"]');

    return lifeCyclesSidebarEnabledTag?.dataset.enabled === 'true';
  }

  protected lifeCyclesSidebarSrc():string {
    return `${this.pathHelper.staticBase}/projects/${this.currentProject.identifier ?? ''}/project_life_cycles_sidebar`;
  }

  protected lifeCyclesSidebarId():string {
    return 'project-life-cycles-sidebar';
  }

  protected projectCustomFieldsSidebarSrc():string {
    return `${this.pathHelper.staticBase}/projects/${this.currentProject.identifier ?? ''}/project_custom_fields_sidebar`;
  }

  protected projectCustomFieldsSidebarId():string {
    return 'project-custom-fields-sidebar';
  }

  protected gridScopePath():string {
    return this.pathHelper.projectPath(this.currentProject.identifier ?? '');
  }
}
