import { ApplicationController } from 'stimulus-use';
import { TurboRequestsService } from 'core-app/core/turbo/turbo-requests.service';
import { PathHelperService } from 'core-app/core/path-helper/path-helper.service';

export default class OpRecurringMeetingsFormController extends ApplicationController {
  private turboRequests:TurboRequestsService;
  private pathHelper:PathHelperService;

  async connect() {
    const context = await window.OpenProject.getPluginContext();
    this.turboRequests = context.services.turboRequests;
    this.pathHelper = context.services.pathHelperService;
  }

  updateFrequencyText():void {
    const data = new FormData(this.element as HTMLFormElement);
    const urlSearchParams = new URLSearchParams();
    ['start_date', 'start_time_hour', 'frequency', 'interval'].forEach((name) => {
      const key = `meeting[${name}]`;
      urlSearchParams.append(key, data.get(key) as string);
    });

    void this
      .turboRequests
      .request(
        `${this.pathHelper.staticBase}/recurring_meetings/humanize_schedule?${urlSearchParams.toString()}`,
        {
          headers: { Accept: 'text/vnd.turbo-stream.html' },
        },
      );
  }
}
