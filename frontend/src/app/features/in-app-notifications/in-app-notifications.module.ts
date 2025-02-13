import { ScrollingModule } from '@angular/cdk/scrolling';
import { CommonModule } from '@angular/common';
import { NgModule } from '@angular/core';
import {
  InAppNotificationBellComponent,
} from 'core-app/features/in-app-notifications/bell/in-app-notification-bell.component';
import { IanBellService } from 'core-app/features/in-app-notifications/bell/state/ian-bell.service';
import {
  InAppNotificationCenterComponent,
} from 'core-app/features/in-app-notifications/center/in-app-notification-center.component';
import { IanCenterService } from 'core-app/features/in-app-notifications/center/state/ian-center.service';
import {
  InAppNotificationsDateAlertsUpsaleComponent,
} from 'core-app/features/in-app-notifications/date-alerts-upsale/ian-date-alerts-upsale.component';
import {
  InAppNotificationEntryComponent,
} from 'core-app/features/in-app-notifications/entry/in-app-notification-entry.component';
import { OpenprojectWorkPackagesModule } from 'core-app/features/work-packages/openproject-work-packages.module';
import { IconModule } from 'core-app/shared/components/icon/icon.module';
import {
  OpenprojectContentLoaderModule,
} from 'core-app/shared/components/op-content-loader/openproject-content-loader.module';
import { OpenprojectPrincipalRenderingModule } from 'core-app/shared/components/principal/principal-rendering.module';
import { OpSharedModule } from 'core-app/shared/shared.module';
import { DynamicModule } from 'ng-dynamic-component';
import { InAppNotificationActorsLineComponent } from './entry/actors-line/in-app-notification-actors-line.component';
import { InAppNotificationDateAlertComponent } from './entry/date-alert/in-app-notification-date-alert.component';
import { InAppNotificationRelativeTimeComponent } from './entry/relative-time/in-app-notification-relative-time.component';
import { InAppNotificationReminderAlertComponent } from './entry/reminder-alert/in-app-notification-reminder-alert.component';
import { InAppNotificationStatusComponent } from './entry/status/in-app-notification-status.component';

@NgModule({
  declarations: [
    InAppNotificationBellComponent,
    InAppNotificationCenterComponent,
    InAppNotificationEntryComponent,
    InAppNotificationStatusComponent,
    InAppNotificationActorsLineComponent,
    InAppNotificationDateAlertComponent,
    InAppNotificationsDateAlertsUpsaleComponent,
    InAppNotificationRelativeTimeComponent,
    InAppNotificationReminderAlertComponent,
  ],
  imports: [
    OpSharedModule,
    DynamicModule,
    CommonModule,
    IconModule,
    OpenprojectPrincipalRenderingModule,
    OpenprojectWorkPackagesModule,
    OpenprojectContentLoaderModule,
    ScrollingModule,
  ],
  providers: [
    IanBellService,
    IanCenterService,
  ],
})
export class OpenProjectInAppNotificationsModule {
}
