import { Controller } from '@hotwired/stimulus';

export default class ScrollController extends Controller {
  static targets = ['scrollToRow'];

  declare readonly scrollToRowTarget:HTMLElement;
  declare readonly hasScrollToRowTarget:boolean;

  scrollToRowTargetConnected() {
    if (this.hasScrollToRowTarget) {
      setTimeout(() => {
        this.scrollToRowTarget.scrollIntoView({ behavior: 'smooth', block: 'center' });
      });
    }
  }
}
