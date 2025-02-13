import { FormlyFieldConfig, FormlyFieldProps } from '@ngx-formly/core';
import { FormGroup } from '@angular/forms';
import { ICKEditorType } from '../editor/components/ckeditor/ckeditor-setup.service';

export interface IOPDynamicFormSettings {
  fields:IOPFormlyFieldSettings[];
  model:IOPFormModel;
  form:FormGroup;
}

export interface IOPFormlyFieldSettings extends FormlyFieldConfig {
  key?:string;
  type?:OPInputType;
  fieldGroup?:IOPFormlyFieldSettings[];
  templateOptions?:IOPFormlyTemplateOptions;
  [key:string]:any;
}

export interface IOPFormlyTemplateOptions extends FormlyFieldProps {
  type?:'checkbox' | 'number' | 'password' | 'selectInput' | 'text';
  name?:string;
  property?:string;
  hasDefault?:boolean;
  fieldGroup?:string;
  isFieldGroup?:boolean;
  collapsibleFieldGroups?:boolean;
  collapsibleFieldGroupsCollapsed?:boolean;
  helpTextAttributeScope?:string;
  showValidationErrorOn?:'change' | 'blur' | 'submit' | 'never';
  payloadValue?:{ href?:string|null };
  rtl?:boolean;
  locale?:string;
  bindLabel?:string;
  bindValue?:string;
  searchable?:boolean;
  editorType?:ICKEditorType;
  noWrapLabel?:boolean;
  virtualScroll?:boolean;
  clearOnBackspace?:boolean;
  clearSearchOnAdd?:boolean;
  hideSelected?:boolean;
  text?:Record<string, string>;
  typeahead?:boolean;
  inlineLabel?:boolean;
  clearable?:boolean;
  multiple?:boolean;
}

type OPInputType = 'formattableInput'|'selectInput'|'textInput'|'integerInput'|
'booleanInput'|'dateInput'|'formly-group'|'projectInput'|'selectProjectStatusInput'|'userInput';

export interface IOPDynamicInputTypeSettings {
  config:IOPFormlyFieldSettings,
  useForFields:OPFieldType[];
}

export interface IDynamicFieldGroupConfig {
  name:string;
  fieldsFilter?:(fieldProperty:IOPFormlyFieldSettings) => boolean;
  settings?:IOPFormlyFieldSettings;
}
