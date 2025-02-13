import { fakeAsync } from '@angular/core/testing';
import {
  createDynamicInputFixture,
  testDynamicInputControValueAccessor,
} from 'core-app/shared/components/dynamic-forms/spec/helpers';
import { IOPFormlyFieldSettings } from 'core-app/shared/components/dynamic-forms/typings';

describe('BooleanInputComponent', () => {
  it('should load the field', fakeAsync(() => {
    const fieldsConfig:IOPFormlyFieldSettings[] = [
      {
        type: 'booleanInput',
        key: 'testControl',
        templateOptions: {
          required: true,
          label: 'testControl',
        },
      },
    ];
    const formModel:IOPFormModel = {
      testControl: true,
    };
    const testModel = {
      initialValue: true,
      changedValue: false,
    };

    const fixture = createDynamicInputFixture(fieldsConfig, formModel);

    testDynamicInputControValueAccessor(fixture, testModel, 'op-boolean-input input');
  }));
});
