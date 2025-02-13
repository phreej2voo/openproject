import { Controller } from '@hotwired/stimulus';
import {
  ICKEditorInstance,
} from 'core-app/shared/components/editor/components/ckeditor/ckeditor.types';
import { TurboRequestsService } from 'core-app/core/turbo/turbo-requests.service';
import { ApiV3Service } from 'core-app/core/apiv3/api-v3.service';

enum AnchorType {
  Comment = 'comment',
  Activity = 'activity',
}

interface CustomEventWithIdParam extends Event {
  params:{
    id:string;
    anchorName:AnchorType;
  };
}

export default class IndexController extends Controller {
  static values = {
    updateStreamsPath: String,
    sorting: String,
    pollingIntervalInMs: Number,
    filter: String,
    userId: Number,
    workPackageId: Number,
    notificationCenterPathName: String,
    lastServerTimestamp: String,
    showConflictFlashMessageUrl: String,
  };

  static targets = ['journalsContainer', 'buttonRow', 'formRow', 'form', 'formSubmitButton', 'reactionButton'];

  declare readonly journalsContainerTarget:HTMLElement;
  declare readonly buttonRowTarget:HTMLInputElement;
  declare readonly formRowTarget:HTMLElement;
  declare readonly formTarget:HTMLFormElement;
  declare readonly formSubmitButtonTarget:HTMLButtonElement;
  declare readonly reactionButtonTargets:HTMLElement[];

  declare readonly hasFormSubmitButtonTarget:boolean;

  declare updateStreamsPathValue:string;
  declare sortingValue:string;
  declare lastServerTimestampValue:string;
  declare intervallId:number;
  declare pollingIntervalInMsValue:number;
  declare notificationCenterPathNameValue:string;
  declare filterValue:string;
  declare userIdValue:number;
  declare workPackageIdValue:number;
  declare rescuedEditorDataKey:string;
  declare latestKnownChangesetUpdatedAtKey:string;
  declare showConflictFlashMessageUrlValue:string;
  private handleWorkPackageUpdateBound:EventListener;
  private handleVisibilityChangeBound:EventListener;
  private rescueEditorContentBound:EventListener;

  private onSubmitBound:EventListener;
  private adjustMarginBound:EventListener;
  private onBlurEditorBound:EventListener;
  private onFocusEditorBound:EventListener;

  private saveInProgress:boolean;
  private updateInProgress:boolean;
  private turboRequests:TurboRequestsService;

  private apiV3Service:ApiV3Service;

  async connect() {
    const context = await window.OpenProject.getPluginContext();
    this.turboRequests = context.services.turboRequests;
    this.apiV3Service = context.services.apiV3Service;

    this.setLocalStorageKeys();
    this.handleStemVisibility();
    this.setupEventListeners();
    this.handleInitialScroll();
    this.populateRescuedEditorContent();
    this.markAsConnected();
    this.safeUpdateWorkPackageFormsWithStateChecks(); // required if switching back to the activities tab from another tab

    this.setLatestKnownChangesetUpdatedAt();
    this.startPolling();
    this.setCssClasses();
  }

  disconnect() {
    this.rescueEditorContent();
    this.removeEventListeners();
    this.stopPolling();
    this.markAsDisconnected();
  }

  private markAsConnected() {
    // used in specs for timing
    (this.element as HTMLElement).dataset.stimulusControllerConnected = 'true';
  }

  private markAsDisconnected() {
    // used in specs for timing
    (this.element as HTMLElement).dataset.stimulusControllerConnected = 'false';
  }

  private setLocalStorageKeys() {
    // scoped by user id in order to avoid data leakage when a user logs out and another user logs in on the same browser
    // TODO: when a user logs out, the data should be removed anyways in order to avoid data leakage
    this.rescuedEditorDataKey = `work-package-${this.workPackageIdValue}-rescued-editor-data-${this.userIdValue}`;
    this.latestKnownChangesetUpdatedAtKey = `work-package-${this.workPackageIdValue}-latest-known-changeset-updated-at-${this.userIdValue}`;
  }

  private setupEventListeners() {
    this.handleWorkPackageUpdateBound = () => { void this.handleWorkPackageUpdate(); };
    this.handleVisibilityChangeBound = () => { void this.handleVisibilityChange(); };
    this.rescueEditorContentBound = () => { void this.rescueEditorContent(); };

    document.addEventListener('work-package-updated', this.handleWorkPackageUpdateBound);
    document.addEventListener('work-package-notifications-updated', this.handleWorkPackageUpdateBound);
    document.addEventListener('visibilitychange', this.handleVisibilityChangeBound);
    document.addEventListener('beforeunload', this.rescueEditorContentBound);
  }

  private removeEventListeners() {
    document.removeEventListener('work-package-updated', this.handleWorkPackageUpdateBound);
    document.removeEventListener('work-package-notifications-updated', this.handleWorkPackageUpdateBound);
    document.removeEventListener('visibilitychange', this.handleVisibilityChangeBound);
    document.removeEventListener('beforeunload', this.rescueEditorContentBound);
  }

  private handleVisibilityChange() {
    if (document.hidden) {
      this.stopPolling();
    } else {
      void this.updateActivitiesList();
      this.startPolling();
    }
  }

  private safeUpdateWorkPackageFormsWithStateChecks() {
    const latestKnownChangesetIsOutdated = this.latestKnownChangesetOutdated();
    const latestChangesetIsFromOtherUser = this.latestChangesetFromOtherUser();

    if (latestKnownChangesetIsOutdated && latestChangesetIsFromOtherUser) {
      this.safeUpdateWorkPackageForms();
    }
  }

  private latestKnownChangesetOutdated():boolean {
    const latestKnownChangesetUpdatedAt = this.getLatestKnownChangesetUpdatedAt();
    const latestChangesetUpdatedAt = this.parseLatestChangesetUpdatedAtFromDom();

    return !!(latestKnownChangesetUpdatedAt && latestChangesetUpdatedAt && (latestKnownChangesetUpdatedAt < latestChangesetUpdatedAt));
  }

  private latestChangesetFromOtherUser():boolean {
    const latestChangesetUserId = this.parseLatestChangesetUserIdFromDom();

    return !!(latestChangesetUserId && (latestChangesetUserId !== this.userIdValue));
  }

  private startPolling() {
    if (this.intervallId) window.clearInterval(this.intervallId);
    this.intervallId = this.pollForUpdates();
  }

  private stopPolling() {
    window.clearInterval(this.intervallId);
  }

  private pollForUpdates() {
    return window.setInterval(() => this.updateActivitiesList(), this.pollingIntervalInMsValue);
  }

  handleWorkPackageUpdate(_event?:Event):void {
    // wait statically as the events triggering this, fire when an async request was started, not ended
    // I don't see a way to detect the end of the async requests reliably, thus the static wait
    setTimeout(() => this.updateActivitiesList(), 2000);
  }

  async updateActivitiesList() {
    if (this.updateInProgress) return;

    this.updateInProgress = true;

    // Unfocus any reaction buttons that may have been focused
    // otherwise the browser will perform an auto scroll to the before focused button after the stream update was applied
    this.unfocusReactionButtons();

    const journalsContainerAtBottom = this.isJournalsContainerScrolledToBottom();

    void this.performUpdateStreamsRequest(this.prepareUpdateStreamsUrl())
    .then(({ html, headers }) => {
      this.handleUpdateStreamsResponse(html, headers, journalsContainerAtBottom);
    }).catch((error) => {
      console.error('Error updating activities list:', error);
    }).finally(() => {
      this.updateInProgress = false;
    });
  }

  private unfocusReactionButtons() {
    this.reactionButtonTargets.forEach((button) => button.blur());
  }

  private prepareUpdateStreamsUrl():string {
    const baseUrl = window.location.origin;
    const url = new URL(this.updateStreamsPathValue, baseUrl);
    url.searchParams.set('sortBy', this.sortingValue);
    url.searchParams.set('filter', this.filterValue);
    url.searchParams.set('last_update_timestamp', this.lastServerTimestampValue);
    return url.toString();
  }

  private performUpdateStreamsRequest(url:string):Promise<{ html:string, headers:Headers }> {
    return this.turboRequests.request(url, {
      method: 'GET',
      headers: {
        'X-CSRF-Token': (document.querySelector('meta[name="csrf-token"]') as HTMLMetaElement).content,
      },
    }, true); // suppress error toast in polling to avoid spamming the user when having e.g. network issues
  }

  private handleUpdateStreamsResponse(html:string, headers:Headers, journalsContainerAtBottom:boolean) {
    // the timeout is require in order to give the Turb.renderStream method enough time to render the new journals
    // the methods below partially rely on the DOM to be updated
    // a specific signal would be way better than a static timeout, but I couldn't find a suitable one
    setTimeout(() => {
      this.handleStemVisibility();
      this.setLastServerTimestampViaHeaders(headers);
      this.checkForAndHandleWorkPackageUpdate(html);
      this.checkForNewNotifications(html);
      this.performAutoScrolling(html, journalsContainerAtBottom);
      this.setLatestKnownChangesetUpdatedAt();
    }, 100);
  }

  private getLatestKnownChangesetUpdatedAt():Date | null {
    const latestKnownChangesetUpdatedAt = localStorage.getItem(this.latestKnownChangesetUpdatedAtKey);
    return latestKnownChangesetUpdatedAt ? new Date(latestKnownChangesetUpdatedAt) : null;
  }

  private setLatestKnownChangesetUpdatedAt() {
    const latestChangesetUpdatedAt = this.parseLatestChangesetUpdatedAtFromDom();

    if (latestChangesetUpdatedAt) {
      localStorage.setItem(this.latestKnownChangesetUpdatedAtKey, latestChangesetUpdatedAt.toString());
    }
  }

  private parseLatestChangesetUpdatedAtFromDom():Date | null {
    const elements = this.element.querySelectorAll('[data-journal-with-changeset-updated-at]');

    const dates = Array.from(elements)
      .map((element) => element.getAttribute('data-journal-with-changeset-updated-at'))
      .filter((dateStr):dateStr is string => dateStr !== null)
      .map((dateStr) => new Date(parseInt(dateStr, 10) * 1000))
      .filter((date) => !Number.isNaN(date.getTime())); // filter out invalid dates

    if (dates.length === 0) return null;

    // find the latest date
    return new Date(Math.max(...dates.map((date) => date.getTime())));
  }

  private parseLatestChangesetUserIdFromDom():number | null {
    const latestChangesetUpdatedAt = this.parseLatestChangesetUpdatedAtFromDom();
    if (!latestChangesetUpdatedAt) return null;

    const railsTimestamp = latestChangesetUpdatedAt.getTime() / 1000;
    const userId = this.element
      .querySelector(`[data-journal-with-changeset-updated-at="${railsTimestamp}"]`)
      ?.getAttribute('data-journal-with-changeset-user-id');

    return userId ? parseInt(userId, 10) : null;
  }

  private checkForAndHandleWorkPackageUpdate(html:string) {
    if (html.includes('work-packages-activities-tab-journals-item-component-details--journal-detail-container')) {
      if (this.latestChangesetFromOtherUser()) {
        this.safeUpdateWorkPackageForms();
      }
    }
  }

  private safeUpdateWorkPackageForms() {
    if (this.anyInlineEditActiveInWpSingleView()) {
      this.showConflictFlashMessage();
    } else {
      this.updateWorkPackageForms();
    }
  }

  private checkForNewNotifications(html:string) {
    if (html.includes('data-op-ian-center-update-immediate')) {
      this.updateNotificationCenter();
    }
  }

  private anyInlineEditActiveInWpSingleView():boolean {
    const wpSingleViewElement = document.querySelector('wp-single-view');
    if (wpSingleViewElement) {
      return wpSingleViewElement.querySelector('.inline-edit--active-field') !== null;
    }
    return false;
  }

  private showConflictFlashMessage() {
    // currently we do not have a programmatic way to show the primer flash messages
    // so we just do a request to the server to show it
    // should be refactored once we have a programmatic way to show the primer flash messages!
    void this.turboRequests.request(`${this.showConflictFlashMessageUrlValue}?scheme=warning`, {
      method: 'GET',
    });
  }

  private updateWorkPackageForms() {
    const wp = this.apiV3Service.work_packages.id(this.workPackageIdValue);
    void wp.refresh();
  }

  private updateNotificationCenter() {
    document.dispatchEvent(new Event('ian-update-immediate'));
  }

  private performAutoScrolling(html:string, journalsContainerAtBottom:boolean) {
    // only process append, prepend and update actions
    if (!(html.includes('action="append"') || html.includes('action="prepend"') || html.includes('action="update"'))) {
      return;
    }

    if (this.sortingValue === 'asc' && journalsContainerAtBottom) {
      // scroll to (new) bottom if sorting is ascending and journals container was already at bottom before a new activity was added
      if (this.isMobile()) {
        this.scrollInputContainerIntoView(300);
      } else {
        this.scrollJournalContainer(true, true);
      }
    }
  }

  private rescueEditorContent() {
    const ckEditorInstance = this.getCkEditorInstance();
    if (ckEditorInstance) {
      const data = ckEditorInstance.getData({ trim: false });
      if (data.length > 0) {
        localStorage.setItem(this.rescuedEditorDataKey, data);
      }
    }
  }

  private populateRescuedEditorContent() {
    const rescuedEditorContent = localStorage.getItem(this.rescuedEditorDataKey);
    if (rescuedEditorContent) {
      this.openEditorWithInitialData(rescuedEditorContent);
      localStorage.removeItem(this.rescuedEditorDataKey);
    }
  }

  private handleInitialScroll() {
    const anchorTypeRegex = new RegExp(`#(${AnchorType.Comment}|${AnchorType.Activity})-(\\d+)`, 'i');
    const activityIdMatch = window.location.hash.match(anchorTypeRegex); // Ex. [ "#comment-80", "comment", "80" ]

    if (activityIdMatch && activityIdMatch.length === 3) {
      this.scrollToActivity(activityIdMatch[1] as AnchorType, activityIdMatch[2]);
    } else if (this.sortingValue === 'asc' && (!this.isMobile() || this.isWithinNotificationCenter())) {
      this.scrollToBottom();
    }
  }

  private tryScroll(activityAnchorName:AnchorType, activityId:string, attempts:number, maxAttempts:number) {
    const scrollableContainer = this.getScrollableContainer();
    const activityElement = this.getActivityAnchorElement(activityAnchorName, activityId);
    const topPadding = 70;

    if (activityElement && scrollableContainer) {
      scrollableContainer.scrollTop = 0;

      setTimeout(() => {
        const containerRect = scrollableContainer.getBoundingClientRect();
        const elementRect = activityElement.getBoundingClientRect();
        const relativeTop = elementRect.top - containerRect.top;

        scrollableContainer.scrollTop = relativeTop - topPadding;
      }, 50);
    } else if (attempts < maxAttempts) {
      setTimeout(() => this.tryScroll(activityAnchorName, activityId, attempts + 1, maxAttempts), 1000);
    }
  }

  private scrollToActivity(activityAnchorName:AnchorType, activityId:string) {
    const maxAttempts = 20; // wait max 20 seconds for the activity to be rendered
    this.tryScroll(activityAnchorName, activityId, 0, maxAttempts);
  }

  private tryScrollToBottom(attempts:number = 0, maxAttempts:number = 20, behavior:ScrollBehavior = 'smooth') {
    const scrollableContainer = this.getScrollableContainer();

    if (!scrollableContainer) {
      if (attempts < maxAttempts) {
        setTimeout(() => this.tryScrollToBottom(attempts + 1, maxAttempts), 1000);
      }
      return;
    }

    scrollableContainer.scrollTop = 0;

    let timeoutId:ReturnType<typeof setTimeout>;

    const observer = new MutationObserver(() => {
      // eslint-disable-next-line @typescript-eslint/no-unsafe-argument
      clearTimeout(timeoutId);

      timeoutId = setTimeout(() => {
        observer.disconnect();
        scrollableContainer.scrollTo({
          top: scrollableContainer.scrollHeight,
          behavior,
        });
      }, 100);
    });

    observer.observe(scrollableContainer, {
      childList: true,
      subtree: true,
      attributes: true,
    });
  }

  private scrollToBottom() {
    this.tryScrollToBottom(0, 20, 'auto');
  }

  setFilterToOnlyComments() { this.filterValue = 'only_comments'; }
  setFilterToOnlyChanges() { this.filterValue = 'only_changes'; }
  unsetFilter() { this.filterValue = ''; }

  setAnchor(event:CustomEventWithIdParam) {
    // native anchor scroll is causing positioning issues
    event.preventDefault();

    const activityId = event.params.id;
    const anchorName = event.params.anchorName;

    // not using the scrollToActivity method here as it is causing flickering issues
    // in case of a setAnchor click, we can go for a direct scroll approach
    const scrollableContainer = this.getScrollableContainer();
    const activityElement = this.getActivityAnchorElement(anchorName, activityId);

    if (scrollableContainer && activityElement) {
      scrollableContainer.scrollTo({
        top: activityElement.offsetTop - 90,
        behavior: 'smooth',
      });
    }

    window.location.hash = `#${anchorName}-${activityId}`;
  }

  private getCkEditorElement():HTMLElement | null {
    return this.element.querySelector('opce-ckeditor-augmented-textarea');
  }

  private getCkEditorInstance():ICKEditorInstance | null {
    const AngularCkEditorElement = this.getCkEditorElement();
    return AngularCkEditorElement ? jQuery(AngularCkEditorElement).data('editor') as ICKEditorInstance : null;
  }

  private getInputContainer():HTMLElement | null {
    return this.element.querySelector('.work-packages-activities-tab-journals-new-component');
  }

  private getScrollableContainer():HTMLElement | null {
    if (this.isWithinNotificationCenter() || this.isWithinSplitScreen()) {
      // valid for both mobile and desktop
      return document.querySelector('.work-package-details-tab') as HTMLElement;
    }
    if (this.isMobile()) {
      return document.querySelector('#content-body') as HTMLElement;
    }

    // valid for desktop
    return document.querySelector('.tabcontent') as HTMLElement;
  }

  private getActivityAnchorElement(activityAnchorName:AnchorType, activityId:string):HTMLElement | null {
    return document.querySelector(`[data-anchor-${activityAnchorName}-id="${activityId}"]`);
  }

  // Code Maintenance: Get rid of this JS based view port checks when activities are rendered in fully primierized activity tab in all contexts
  private isMobile():boolean {
    if (this.isWithinNotificationCenter() || this.isWithinSplitScreen()) {
      return window.innerWidth < 1013;
    }
    return window.innerWidth < 1279;
  }

  private isWithinNotificationCenter():boolean {
    return window.location.pathname.includes(this.notificationCenterPathNameValue);
  }

  private isWithinSplitScreen():boolean {
    return window.location.pathname.includes('work_packages/details');
  }

  private setCssClasses() {
    if (this.isWithinNotificationCenter()) {
      this.element.classList.add('work-packages-activities-tab-index-component--within-notification-center');
    }
    if (this.isWithinSplitScreen()) {
      this.element.classList.add('work-packages-activities-tab-index-component--within-split-screen');
    }
  }

  private addEventListenersToCkEditorInstance() {
    this.onSubmitBound = () => { void this.onSubmit(); };
    this.adjustMarginBound = () => { void this.adjustJournalContainerMargin(); };
    this.onBlurEditorBound = () => { void this.onBlurEditor(); };
    this.onFocusEditorBound = () => { void this.onFocusEditor(); };

    const editorElement = this.getCkEditorElement();
    if (editorElement) {
      editorElement.addEventListener('saveRequested', this.onSubmitBound);
      editorElement.addEventListener('editorKeyup', this.adjustMarginBound);
      editorElement.addEventListener('editorBlur', this.onBlurEditorBound);
      editorElement.addEventListener('editorFocus', this.onFocusEditorBound);
    }
  }

  private removeEventListenersFromCkEditorInstance() {
    const editorElement = this.getCkEditorElement();
    if (editorElement) {
      editorElement.removeEventListener('saveRequested', this.onSubmitBound);
      editorElement.removeEventListener('editorKeyup', this.adjustMarginBound);
      editorElement.removeEventListener('editorBlur', this.onBlurEditorBound);
      editorElement.removeEventListener('editorFocus', this.onFocusEditorBound);
    }
  }

  private adjustJournalContainerMargin() {
    // don't do this on mobile screens
    if (this.isMobile()) { return; }
    this.journalsContainerTarget.style.marginBottom = `${this.formRowTarget.clientHeight + 29}px`;
  }

  private isJournalsContainerScrolledToBottom() {
    let atBottom = false;
    // we have to handle different scrollable containers for different viewports/pages in order to idenfity if the user is at the bottom of the journals
    // DOM structure different for notification center and workpackage detail view as well
    const scrollableContainer = this.getScrollableContainer();
    if (scrollableContainer) {
      atBottom = (scrollableContainer.scrollTop + scrollableContainer.clientHeight + 10) >= scrollableContainer.scrollHeight;
    }

    return atBottom;
  }

  private scrollJournalContainer(toBottom:boolean, smooth:boolean = false) {
    const scrollableContainer = this.getScrollableContainer();
    if (scrollableContainer) {
      if (smooth) {
        scrollableContainer.scrollTo({
          top: toBottom ? scrollableContainer.scrollHeight : 0,
          behavior: 'smooth',
        });
      } else {
        scrollableContainer.scrollTop = toBottom ? scrollableContainer.scrollHeight : 0;
      }
    }
  }

  private scrollInputContainerIntoView(timeout:number = 0) {
    const inputContainer = this.getInputContainer() as HTMLElement;
    setTimeout(() => {
      if (inputContainer) {
        if (this.sortingValue === 'desc') {
          inputContainer.scrollIntoView({
            behavior: 'smooth',
            block: 'nearest',
          });
        } else {
          inputContainer.scrollIntoView({
            behavior: 'smooth',
            block: 'start',
          });
        }
      }
    }, timeout);
  }

  showForm() {
    const journalsContainerAtBottom = this.isJournalsContainerScrolledToBottom();

    this.buttonRowTarget.classList.add('d-none');
    this.formRowTarget.classList.remove('d-none');
    this.journalsContainerTarget?.classList.add('work-packages-activities-tab-index-component--journals-container_with-input-compensation');

    this.addEventListenersToCkEditorInstance();

    if (this.isMobile()) {
      // timeout amount tested on mobile devices for best possible user experience
      this.scrollInputContainerIntoView(100); // first bring the input container fully into view (before focusing!)
      this.focusEditor(400); // wait before focusing to avoid interference with the auto scroll
    } else if (this.sortingValue === 'asc' && journalsContainerAtBottom) {
      // scroll to (new) bottom if sorting is ascending and journals container was already at bottom before showing the form
      this.scrollJournalContainer(true);
      this.focusEditor();
    } else {
      this.focusEditor();
    }
  }

  focusEditor(timeout:number = 10) {
    const ckEditorInstance = this.getCkEditorInstance();
    if (ckEditorInstance) {
      setTimeout(() => ckEditorInstance.editing.view.focus(), timeout);
    }
  }

  quote(event:Event) {
    event.preventDefault();
    const target = event.currentTarget as HTMLElement;
    const userName = target.dataset.userNameParam as string;
    const content = target.dataset.contentParam as string;

    this.openEditorWithInitialData(this.quotedText(content, userName));
  }

  private quotedText(rawComment:string, userName:string) {
    const quoted = rawComment.split('\n')
      .map((line:string) => `\n> ${line}`)
      .join('');

    return `${userName}\n${quoted}`;
  }

  openEditorWithInitialData(quotedText:string) {
    this.showForm();
    const ckEditorInstance = this.getCkEditorInstance();
    if (ckEditorInstance && ckEditorInstance.getData({ trim: false }).length === 0) {
      ckEditorInstance.setData(quotedText);
    }
  }

  clearEditor() {
    this.getCkEditorInstance()?.setData('');
  }

  hideEditorIfEmpty() {
    const ckEditorInstance = this.getCkEditorInstance();

    if (ckEditorInstance && ckEditorInstance.getData({ trim: false }).length === 0) {
      this.hideEditor();
    }
  }

  hideEditor() {
    this.clearEditor(); // remove potentially empty lines
    this.removeEventListenersFromCkEditorInstance();
    this.buttonRowTarget.classList.remove('d-none');
    this.formRowTarget.classList.add('d-none');

    if (this.journalsContainerTarget) {
      this.journalsContainerTarget.style.marginBottom = '';
      this.journalsContainerTarget.classList.add('work-packages-activities-tab-index-component--journals-container_with-initial-input-compensation');
      this.journalsContainerTarget.classList.remove('work-packages-activities-tab-index-component--journals-container_with-input-compensation');
    }

    if (this.isMobile()) {
      // wait for the keyboard to be fully down before scrolling further
      // timeout amount tested on mobile devices for best possible user experience
      this.scrollInputContainerIntoView(500);
    }
  }

  onBlurEditor() {
    const ckEditorInstance = this.getCkEditorInstance();

    if (ckEditorInstance && ckEditorInstance.getData({ trim: false }).length === 0) {
      this.hideEditor();
    } else {
      this.adjustJournalContainerMargin();
    }
  }

  onFocusEditor() {
    this.adjustJournalContainerMargin();
  }

  async onSubmit(event:Event | null = null) {
    if (this.saveInProgress === true) return;

    this.setFormSubmitInProgress(true);

    event?.preventDefault();

    const formData = this.prepareFormData();
    void this.submitForm(formData)
      .then(({ html, headers }) => {
        this.handleSuccessfulSubmission(html, headers);
      })
      .catch((error) => {
        console.error('Error saving activity:', error);
      })
      .finally(() => {
        this.setFormSubmitInProgress(false);
      });
  }

  private setFormSubmitInProgress(inProgress:boolean) {
    this.saveInProgress = inProgress;

    if (this.hasFormSubmitButtonTarget) {
      this.formSubmitButtonTarget.disabled = inProgress;
    }

    this.setCKEditorReadonlyMode(inProgress);
  }

  private setCKEditorReadonlyMode(disabled:boolean) {
    const ckEditorInstance = this.getCkEditorInstance();
    const editorLockID = 'work-packages-activities-tab-index-component';

    if (ckEditorInstance) {
      if (disabled) {
        ckEditorInstance.enableReadOnlyMode(editorLockID);
      } else {
        ckEditorInstance.disableReadOnlyMode(editorLockID);
      }
    }
  }

  private prepareFormData():FormData {
    const ckEditorInstance = this.getCkEditorInstance();
    const data = ckEditorInstance ? ckEditorInstance.getData({ trim: false }) : '';

    const formData = new FormData(this.formTarget);
    formData.append('last_update_timestamp', this.lastServerTimestampValue);
    formData.append('filter', this.filterValue);
    formData.append('journal[notes]', data);

    return formData;
  }

  private async submitForm(formData:FormData):Promise<{ html:string, headers:Headers }> {
    return this.turboRequests.request(this.formTarget.action, {
      method: 'POST',
      body: formData,
      headers: {
        'X-CSRF-Token': (document.querySelector('meta[name="csrf-token"]') as HTMLMetaElement).content,
      },
    }, true);
  }

  private handleSuccessfulSubmission(html:string, headers:Headers) {
    // extract server timestamp from response headers in order to be in sync with the server
    this.setLastServerTimestampViaHeaders(headers);

    if (!this.journalsContainerTarget) return;

    this.clearEditor();
    this.hideEditor();
    this.resetJournalsContainerMargins();

    setTimeout(() => {
      if (this.isMobile() && !this.isWithinNotificationCenter()) {
        // wait for the keyboard to be fully down before scrolling further
        // timeout amount tested on mobile devices for best possible user experience
        this.scrollInputContainerIntoView(800);
      } else {
        this.scrollJournalContainer(
          this.sortingValue === 'asc',
          true,
        );
      }
      this.handleStemVisibility();
    }, 10);

    this.setFormSubmitInProgress(false);
  }

  private resetJournalsContainerMargins():void {
    if (!this.journalsContainerTarget) return;

    this.journalsContainerTarget.style.marginBottom = '';
    this.journalsContainerTarget.classList.add('work-packages-activities-tab-index-component--journals-container_with-initial-input-compensation');
  }

  private setLastServerTimestampViaHeaders(headers:Headers) {
    if (headers.has('X-Server-Timestamp')) {
      this.lastServerTimestampValue = headers.get('X-Server-Timestamp') as string;
    }
  }

  // Towards the code below:
  // Ideally the stem rendering would be correctly rendered for all UI states from the server
  // but as we push single elements into the DOM via turbo-streams, the server-side rendered collection state gets stale quickly
  // I've decided to go with a client-side rendering-correction approach for now
  // as I don't want to introduce more complexity and queries (n+1 for position checks etc.) to the server-side rendering
  private handleStemVisibility() {
    this.handleStemVisibilityForMobile();
    this.handleLastStemPartVisibility();
  }

  private handleStemVisibilityForMobile() {
    if (this.isMobile()) {
      if (this.sortingValue === 'asc') return;

      const initialJournalContainer = this.element.querySelector('.work-packages-activities-tab-journals-item-component-details--journal-details-container[data-initial="true"]') as HTMLElement;

      if (initialJournalContainer) {
        initialJournalContainer.classList.add('work-packages-activities-tab-journals-item-component-details--journal-details-container--border-removed');
      }
    }
  }

  private handleLastStemPartVisibility() {
    const emptyLines = this.element.querySelectorAll('.empty-line');

    // make sure all are visible first
    emptyLines.forEach((container) => {
      container.classList.remove('work-packages-activities-tab-journals-item-component-details--journal-details-container--hidden');
    });

    if (this.sortingValue === 'asc' || this.filterValue === 'only_changes') return;

    // then hide the last one again
    if (emptyLines.length > 0) {
      // take the parent container of the last empty line
      const lastEmptyLineContainer = emptyLines[emptyLines.length - 1].parentElement as HTMLElement;
      lastEmptyLineContainer.classList.add('work-packages-activities-tab-journals-item-component-details--journal-details-container--hidden');
    }
  }
}
