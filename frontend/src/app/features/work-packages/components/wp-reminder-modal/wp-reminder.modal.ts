import {
  ChangeDetectionStrategy,
  ChangeDetectorRef,
  Component,
  ElementRef,
  Inject,
  OnInit,
  ViewChild, AfterViewInit, OnDestroy,
} from '@angular/core';
import { OpModalLocalsMap } from 'core-app/shared/components/modal/modal.types';
import { OpModalComponent } from 'core-app/shared/components/modal/modal.component';
import { OpModalLocalsToken } from 'core-app/shared/components/modal/modal.service';
import { I18nService } from 'core-app/core/i18n/i18n.service';
import { WorkPackageResource } from 'core-app/features/hal/resources/work-package-resource';
import { PathHelperService } from 'core-app/core/path-helper/path-helper.service';
import { ActionsService } from 'core-app/core/state/actions/actions.service';
import { reminderModalUpdated } from 'core-app/features/work-packages/components/wp-reminder-modal/reminder.actions';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { ApiV3Service } from 'core-app/core/apiv3/api-v3.service';
import { CollectionResource } from 'core-app/features/hal/resources/collection-resource';

@Component({
  templateUrl: './wp-reminder.modal.html',
  styleUrls: ['./wp-reminder.modal.sass'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class WorkPackageReminderModalComponent extends OpModalComponent implements OnInit, AfterViewInit, OnDestroy {
  @ViewChild('frameElement') frameElement:ElementRef<HTMLIFrameElement>;

  // Hide close button so it's not duplicated in primer (WP#51699)
  showCloseButton = false;

  private workPackage:WorkPackageResource;
  public frameSrc:string;

  text = {
    new_title: this.I18n.t('js.work_packages.reminders.title.new'),
    edit_title: this.I18n.t('js.work_packages.reminders.title.edit'),
    subtitle: this.I18n.t('js.work_packages.reminders.subtitle'),
    button_close: this.I18n.t('js.button_close'),
  };

  public title$:Observable<string>;

  private boundListener = this.turboSubmitEndListener.bind(this);

  constructor(
    @Inject(OpModalLocalsToken) public locals:OpModalLocalsMap,
    readonly cdRef:ChangeDetectorRef,
    readonly I18n:I18nService,
    readonly elementRef:ElementRef<HTMLElement>,
    readonly pathHelper:PathHelperService,
    readonly actions$:ActionsService,
    readonly apiV3Service:ApiV3Service,
  ) {
    super(locals, cdRef, elementRef);

    this.workPackage = this.locals.workPackage as WorkPackageResource;
    this.title$ = this
      .isEditMode()
      .pipe(
        map((isEditMode) => (isEditMode ? this.text.edit_title : this.text.new_title)),
      );
    this.frameSrc = this.pathHelper.workPackageReminderModalBodyPath(this.workPackage.id as string);
  }

  ngOnInit() {
    super.ngOnInit();
  }

  ngAfterViewInit() {
    // Use event delegation on a parent element that won't be re-rendered
    this.elementRef.nativeElement.addEventListener('turbo:submit-end', this.boundListener);
  }

  ngOnDestroy() {
    super.ngOnDestroy();

    this.elementRef.nativeElement.removeEventListener('turbo:submit-end', this.boundListener);
  }

  onClose():boolean {
    this.actions$.dispatch(reminderModalUpdated({ workPackageId: this.workPackage.id as string }));

    return super.onClose();
  }

  private turboSubmitEndListener(event:CustomEvent) {
    // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment
    const { fetchResponse } = event.detail;

    // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access
    if (fetchResponse.succeeded) {
      this.closeMe();
      this.onClose();
    }
  }

  /**
   * Check if there is already a reminder for the work package
   * so we can determine if we are in edit or new mode
   */
  private isEditMode():Observable<boolean> {
    return this
      .apiV3Service
      .work_packages
      .id(this.workPackage.id as string)
      .reminders
      .get()
      .pipe(
        map((collection:CollectionResource) => { return collection.total > 0; }),
      );
  }
}
