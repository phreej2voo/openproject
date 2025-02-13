import { fakeAsync } from '@angular/core/testing';
import {
  createDynamicInputFixture,
  testDynamicInputControValueAccessor,
} from 'core-app/shared/components/dynamic-forms/spec/helpers';
import { IOPFormlyFieldSettings } from 'core-app/shared/components/dynamic-forms/typings';

describe('TextInputComponent', () => {
  it('should load the field', fakeAsync(() => {
    const fieldsConfig:IOPFormlyFieldSettings[] = [
      {
        type: 'textInput',
        key: 'testControl',
        templateOptions: {
          required: true,
          label: 'testControl',
          type: 'text',
          placeholder: '',
          disabled: false,
        },
      },
    ];
    const formModel:IOPFormModel = {
      testControl: 'testValue',
    };
    const testModel = {
      initialValue: 'testValue',
      changedValue: 'testValue2',
    };

    const fixture = createDynamicInputFixture(fieldsConfig, formModel);

    testDynamicInputControValueAccessor(fixture, testModel, 'op-text-input input');
  }));
});
