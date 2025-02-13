import { ApplicationController } from 'stimulus-use';

export default class OpShowWhenValueSelectedController extends ApplicationController {
  static targets = ['cause', 'effect'];

  declare readonly effectTargets:HTMLInputElement[];

  private boundListener = this.toggleDisabled.bind(this);

  causeTargetConnected(target:HTMLElement) {
    target.addEventListener('change', this.boundListener);
  }

  causeTargetDisconnected(target:HTMLElement) {
    target.removeEventListener('change', this.boundListener);
  }

  private toggleDisabled(evt:InputEvent):void {
    const input = evt.target as HTMLInputElement;
    const targetName = input.dataset.targetName;

    this
      .effectTargets
      .filter((el) => targetName === el.dataset.targetName)
      .forEach((el) => {
        const disabled = this.willDisable(el, input.value);
        el.disabled = disabled;

        if (el.dataset.setVisibility === 'true') {
          el.style.setProperty('visibility', disabled ? 'hidden' : 'visible');
        } else {
          el.hidden = disabled;
        }
    });
  }

  private willDisable(el:HTMLElement, value:string):boolean {
    if (el.dataset.notValue) {
      return el.dataset.notValue === value;
    }

    return !(el.dataset.value === value);
  }
}
