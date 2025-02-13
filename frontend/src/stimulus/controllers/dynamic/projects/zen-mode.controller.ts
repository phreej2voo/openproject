import { ApplicationController } from 'stimulus-use';

export default class OpProjectsZenModeController extends ApplicationController {
  static targets = ['button'];
  inZenMode = false;

  declare readonly buttonTarget:HTMLElement;

  private boundHandler = this.fullscreenChangeEventHandler.bind(this);

  connect() {
    document.addEventListener('fullscreenchange', this.boundHandler);
  }

  disconnect() {
    super.disconnect();
    document.removeEventListener('fullscreenchange', this.boundHandler);
  }

  fullscreenChangeEventHandler() {
    this.inZenMode = !this.inZenMode;
    this.dispatchZenModeStatus();
  }

  dispatchZenModeStatus() {
    // Create a new custom event
    const event = new CustomEvent('zenModeToggled', {
      detail: {
        active: this.inZenMode,
      },
    });
    // Dispatch the custom event
    window.dispatchEvent(event);
  }

  private deactivateZenMode() {
    if (document.exitFullscreen) {
      void document.exitFullscreen();
    }
  }

  private activateZenMode() {
    if (document.documentElement.requestFullscreen) {
      void document.documentElement.requestFullscreen();
    }
  }

  public performAction() {
    if (this.inZenMode) {
      this.deactivateZenMode();
    } else {
      this.activateZenMode();
    }
  }
}
