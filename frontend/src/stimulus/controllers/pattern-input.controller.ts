/*
 * -- copyright
 * OpenProject is an open source project management software.
 * Copyright (C) the OpenProject GmbH
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License version 3.
 *
 * OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
 * Copyright (C) 2006-2013 Jean-Philippe Lang
 * Copyright (C) 2010-2013 the ChiliProject Team
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 *
 * See COPYRIGHT and LICENSE files for more details.
 * ++
 */

import { Controller } from '@hotwired/stimulus';

// internal type used to filter suggestions
type FilteredSuggestions = Array<{
  key:string;
  values:Array<{ prop:string; value:string; }>;
}>;

export default class PatternInputController extends Controller {
  static targets = [
    'tokenTemplate',
    'content',
    'formInput',

    'suggestions',
    'suggestionsHeadingTemplate',
    'suggestionsDividerTemplate',
    'suggestionsItemTemplate',
  ];

  declare readonly tokenTemplateTarget:HTMLTemplateElement;
  declare readonly contentTarget:HTMLElement;
  declare readonly formInputTarget:HTMLInputElement;

  declare readonly suggestionsTarget:HTMLElement;
  declare readonly suggestionsHeadingTemplateTarget:HTMLTemplateElement;
  declare readonly suggestionsDividerTemplateTarget:HTMLTemplateElement;
  declare readonly suggestionsItemTemplateTarget:HTMLTemplateElement;

  static values = {
    patternInitial: String,
    suggestionsInitial: Object,
  };

  declare patternInitialValue:string;
  declare suggestionsInitialValue:Record<string, Record<string, string>>;

  validTokens:string[];
  currentRange:Range|undefined = undefined;

  connect() {
    this.contentTarget.innerHTML = this.toHtml(this.patternInitialValue) || ' ';
    this.extractValidTokens();
    this.tagInvalidTokens();
  }

  // Input field events
  input_keydown(event:KeyboardEvent) {
    if (event.key === 'Enter') {
      event.preventDefault();
    }

    if (event.key === 'ArrowDown') {
      const firstSuggestion = this.suggestionsTarget.querySelector('[role="menuitem"]') as HTMLElement;
      firstSuggestion?.focus();
      event.preventDefault();
    }
    if (event.key === 'ArrowLeft') {
      if (this.contentTarget.innerHTML.startsWith('<')) {
        this.insertSpaceIfFirstCharacter();
      }
    }
    if (event.key === 'ArrowRight') {
      if (this.contentTarget.innerHTML.endsWith('>')) {
        this.insertSpaceIfLastCharacter();
      }
    }

    // close the suggestions
    if (event.key === 'Escape' || event.key === 'ArrowLeft' || event.key === 'ArrowRight') {
      this.clearSuggestionsFilter();
    }

    // update cursor
    this.setRange();
  }

  input_change() {
    // clean up empty tags from the input
    this.contentTarget.querySelectorAll('span').forEach((element) => element.textContent?.trim() === '' && element.remove());
    this.contentTarget.querySelectorAll('br').forEach((element) => element.remove());

    // show suggestions for the current word
    const word = this.currentWord();
    if (word && word.length > 0) {
      this.filterSuggestions(word);
    } else {
      this.clearSuggestionsFilter();
    }

    this.tagInvalidTokens();

    // this resets the cursor position without changing it
    // it is necessary because chromium based browsers try to
    // retain styling and adds a unwanted <font> tag,
    // breaking the behaviour of this component
    const selection = document.getSelection();
    if (selection && selection.rangeCount) {
      const range = selection.getRangeAt(0);
      selection.removeAllRanges();
      selection.addRange(range);
    }
    this.setRange();
  }

  input_mouseup() {
    this.setRange();
  }

  input_focus() {
    this.setRange();
  }

  input_blur() {
    this.updateFormInputValue();
  }

  // Autocomplete events
  suggestions_select(event:PointerEvent) {
    const target = event.currentTarget as HTMLElement;

    if (target) {
      this.insertToken(this.createToken(target.dataset.prop!));
      this.clearSuggestionsFilter();
    }
  }

  // internal methods
  extractValidTokens() {
    const res = Object.values(this.suggestionsInitialValue).map((group) => (Object.keys(group)));
    this.validTokens = ([] as string[]).concat(...res);
  }

  private updateFormInputValue():void {
    this.formInputTarget.value = this.toBlueprint();
  }

  /**
    * Sets an internal representation of the cursor position by persisting the current `Range`
    */
  private setRange():void {
    const selection = document.getSelection();
    if (selection?.rangeCount) {
      const range = selection.getRangeAt(0);
      if (range.startContainer.parentNode === this.contentTarget) {
        this.currentRange = range;
      }
    }
  }

  insertSpaceIfFirstCharacter() {
    const selection = document.getSelection();
    if (selection && selection.rangeCount) {
      const range = selection.getRangeAt(0);
      // create a test range
      // select the whole content of the input
      // then set the "end" position to the current actual selection position (the caret)
      const testRange = document.createRange();
      testRange.selectNodeContents(this.contentTarget);
      testRange.setEnd(range.startContainer, range.startOffset);

      // if the resulting range is empty it is at the end of the input
      if (testRange.toString() === '') {
        // add a space
        const beforeToken = document.createTextNode(' ');
        const firstContent = this.contentTarget.firstChild as HTMLElement;
        this.contentTarget.insertBefore(beforeToken, firstContent);

        this.setRealCaretPositionAtNode(beforeToken, 'before');
      }
    }
  }

  insertSpaceIfLastCharacter():void {
    const selection = document.getSelection();
    if (selection && selection.rangeCount) {
      const range = selection.getRangeAt(0);
      // create a test range
      // select the whole content of the input
      // then set the "start" position to the current actual selection position (the caret)
      const testRange = document.createRange();
      testRange.selectNodeContents(this.contentTarget);
      testRange.setStart(range.endContainer, range.endOffset);

      // if the resulting range is empty it is at the end of the input
      if (testRange.toString() === '') {
        // add a space
        const afterToken = document.createTextNode(' ');
        this.contentTarget.appendChild(afterToken);

        this.setRealCaretPositionAtNode(afterToken);
      }
    }
  }

  setRealCaretPositionAtNode(target:Node, position:'before'|'after' = 'after'):void {
    const selection = document.getSelection();
    if (selection) {
      const postRange = document.createRange();
      if (position === 'after') {
        postRange.setStartAfter(target);
      } else {
        postRange.setStartBefore(target);
      }
      selection?.removeAllRanges();
      selection?.addRange(postRange);
    }
  }

  private insertToken(tokenElement:HTMLElement) {
    if (this.currentRange) {
      const targetNode = this.currentRange.startContainer;
      const targetOffset = this.currentRange.startOffset;

      if (!targetNode.textContent) { return; }

      let pos = targetOffset - 1;
      while (pos > -1 && !this.isWhitespace(targetNode.textContent.charAt(pos))) { pos-=1; }

      const wordRange = document.createRange();
      wordRange.setStart(targetNode, pos + 1);
      wordRange.setEnd(targetNode, targetOffset);

      wordRange.deleteContents();
      wordRange.insertNode(tokenElement);

      this.setRealCaretPositionAtNode(tokenElement);

      this.updateFormInputValue();
      this.setRange();

      // clear suggestions
      this.clearSuggestionsFilter();
    } else {
      this.contentTarget.appendChild(tokenElement);
    }
  }

  private currentWord():string|null {
    const selection = document.getSelection();
    if (selection) {
      return (selection.anchorNode?.textContent?.slice(0, selection.anchorOffset)
        .split(' ')
        .pop() as string)
        .toLowerCase();
    }

    return null;
  }

  private clearSuggestionsFilter():void {
    this.suggestionsTarget.innerHTML = '';
  }

  private filterSuggestions(word:string):void {
    this.clearSuggestionsFilter();

    const filtered = this.getFilteredSuggestionsData(word);

    // insert the HTML
    filtered.forEach((group) => {
      const groupHeader = this.suggestionsHeadingTemplateTarget.content?.cloneNode(true) as HTMLElement;
      if (groupHeader) {
        const headerElement = groupHeader.querySelector('h2');
        if (headerElement) {
          headerElement.innerText = group.key;
        }

        this.suggestionsTarget.appendChild(groupHeader);
      }

      group.values.forEach((suggestion) => {
        const suggestionTemplate = this.suggestionsItemTemplateTarget.content?.cloneNode(true) as HTMLElement;
        const suggestionItem = suggestionTemplate.firstElementChild as HTMLElement;
        if (suggestionTemplate && suggestionItem) {
          suggestionItem.dataset.prop = suggestion.prop;
          this.setSuggestionText(suggestionItem, suggestion.value);
          this.suggestionsTarget.appendChild(suggestionItem);
        }
      });

      const groupDivider = this.suggestionsDividerTemplateTarget.content?.cloneNode(true) as HTMLElement;
      this.suggestionsTarget.appendChild(groupDivider);
    });
  }

  setSuggestionText(suggestionItem:HTMLElement, value:string) {
    const textContainer = suggestionItem.querySelector('span');
    if (textContainer) {
      textContainer.innerText = value;
    } else {
      throw new Error('suggestion template does not have a span to hold the suggestion value');
    }
  }

  private getFilteredSuggestionsData(word:string):FilteredSuggestions {
    return Object.keys(this.suggestionsInitialValue).map((key) => {
      const group = this.suggestionsInitialValue[key];
      return {
        key,
        values: Object.entries(group).filter(([prop, value]) => {
          return value.toLowerCase().includes(word.toLowerCase()) || prop.toLowerCase().includes(word.toLowerCase()) || word === '*';
        }).map(([prop, value]) => ({ prop, value })),
      };
    }).filter((group) => group.values.length > 0);
  }

  private tagInvalidTokens():void {
    this.contentTarget.querySelectorAll('[data-role="token"]').forEach((element) => {
      const token = element.textContent?.trim();

      let exists = false;
      this.validTokens.forEach((prop) => { if (prop === token) { exists = true; } });

      if (exists) {
        element.classList.remove('Label--danger');
      } else {
        element.classList.add('Label--danger');
      }
    });
  }

  private createToken(value:string):HTMLElement {
    const templateTarget = this.tokenTemplateTarget.content?.cloneNode(true) as HTMLElement;
    const contentElement = templateTarget.firstElementChild as HTMLElement;
    contentElement.innerText = value;
    return contentElement;
  }

  private toHtml(blueprint:string):string {
    return blueprint.replace(/{{([0-9A-Za-z_]+)}}/g, (_, token:string) => this.createToken(token).outerHTML);
  }

  private toBlueprint():string {
    let result = '';
    this.contentTarget.childNodes.forEach((node:Element) => {
      if (node.nodeType === Node.TEXT_NODE) {
        // Plain text node
        result += node.textContent;
      } else if (node.nodeType === Node.ELEMENT_NODE && (node as HTMLElement).dataset.role === 'token') {
        // Token element
        result += `{{${node.textContent?.trim()}}}`;
      }
    });
    return result.trim();
  }

  private isWhitespace(value:string):boolean {
    return /\s/.test(value);
  }
}
