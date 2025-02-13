import { ApplicationController } from 'stimulus-use';

export const SUCCESS_AUTOHIDE_TIMEOUT = 5000;

export default class FlashController extends ApplicationController {
  static values = {
    autohide: Boolean,
  };

  declare autohideValue:boolean;

  static targets = [
    'item',
    'flash', // only to detect removal
  ];

  declare readonly itemTargets:HTMLElement[];

  reloadPage() {
    window.location.reload();
  }

  itemTargetConnected(element:HTMLElement) {
    const autohide = element.dataset.autohide === 'true';
    if (this.autohideValue && autohide) {
      setTimeout(() => element.remove(), SUCCESS_AUTOHIDE_TIMEOUT);
    }
  }

  flashTargetDisconnected() {
    this.itemTargets.forEach((target:HTMLElement) => {
      if (target.innerHTML === '') {
        target.remove();
      }
    });
  }
}
