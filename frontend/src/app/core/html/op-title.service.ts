import { Title } from '@angular/platform-browser';
import { Injectable } from '@angular/core';

const titlePartsSeparator = ' | ';

@Injectable({ providedIn: 'root' })
export class OpTitleService {
  constructor(private titleService:Title) {
  }

  public get current():string {
    return this.titleService.getTitle();
  }

  public get base():string {
    const appTitle = document.querySelector('meta[name=app_title]') as HTMLMetaElement;
    return appTitle.content;
  }

  public get titleParts():string[] {
    return this.current.split(titlePartsSeparator);
  }

  public setFirstPart(value:string) {
    if (this.current.includes(this.base) && this.current.includes(titlePartsSeparator)) {
      const parts = this.titleParts;
      parts[0] = value;
      this.titleService.setTitle(parts.join(titlePartsSeparator));
    } else {
      const newTitle = [value, this.base].join(titlePartsSeparator);
      this.titleService.setTitle(newTitle);
    }
  }
}
