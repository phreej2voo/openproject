import { ChangeDetectionStrategy, Component, ElementRef, Input, OnInit, HostListener } from '@angular/core';
import { combineLatest, merge, Observable, timer } from 'rxjs';
import { filter, map, shareReplay, switchMap, throttleTime } from 'rxjs/operators';
import { ActiveWindowService } from 'core-app/core/active-window/active-window.service';
import { PathHelperService } from 'core-app/core/path-helper/path-helper.service';
import { ApiV3Service } from 'core-app/core/apiv3/api-v3.service';
import { IanBellService } from 'core-app/features/in-app-notifications/bell/state/ian-bell.service';
import { populateInputsFromDataset } from 'core-app/shared/components/dataset-inputs';


@Component({
  selector: 'opce-in-app-notification-bell',
  templateUrl: './in-app-notification-bell.component.html',
  styleUrls: ['./in-app-notification-bell.component.sass'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class InAppNotificationBellComponent implements OnInit {
  @Input() interval = 50000;

  polling$:Observable<number>;

  unreadCount$:Observable<number>;

  unreadCountText$:Observable<number|string>;

  constructor(
    readonly elementRef:ElementRef,
    readonly storeService:IanBellService,
    readonly apiV3Service:ApiV3Service,
    readonly activeWindow:ActiveWindowService,
    readonly pathHelper:PathHelperService,
  ) {
    populateInputsFromDataset(this);
  }

  // enable other parts of the application to trigger an immediate update
  // e.g. a stimulus controller
  // currently used by the new activities tab which does it's own polling
  // and receives updates from the backend earlier than the polling in the bell component
  @HostListener('document:ian-update-immediate')
  triggerImmediateUpdate() {
    this.storeService.fetchUnread().subscribe();
  }

  ngOnInit() {
    this.polling$ = merge(
      timer(10, this.interval).pipe(filter(() => this.activeWindow.isActive)),
      timer(10, this.interval * 10).pipe(filter(() => !this.activeWindow.isActive)),
    )
      .pipe(
        throttleTime(this.interval),
        switchMap(() => this.storeService.fetchUnread()),
      );

    this.unreadCount$ = combineLatest([
      this.storeService.unread$,
      this.polling$,
    ]).pipe(
      map(([count]) => count),
      shareReplay(1),
    );

    this.unreadCountText$ = this
      .unreadCount$
      .pipe(
        map((count) => {
          if (count > 99) {
            return '99+';
          }

          if (count <= 0) {
            return '';
          }

          return count;
        }),
      );
  }

  notificationsPath():string {
    return this.pathHelper.notificationsPath();
  }
}
