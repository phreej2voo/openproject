import { fakeAsync } from '@angular/core/testing';
import {
  createDynamicInputFixture,
  testDynamicInputControValueAccessor,
} from 'core-app/shared/components/dynamic-forms/spec/helpers';
import { IOPFormlyFieldSettings } from 'core-app/shared/components/dynamic-forms/typings';

describe('IntegerInputComponent', () => {
  it('should load the field', fakeAsync(() => {
    const fieldsConfig:IOPFormlyFieldSettings[] = [
      {
        type: 'integerInput',
        key: 'testControl',
        templateOptions: {
          required: true,
          label: 'testControl',
        },
      },
    ];
    const formModel:IOPFormModel = {
      testControl: 'testValue',
    };
    const testModel = {
      initialValue: formModel.testControl,
      changedValue: 'testValue2',
    };

    const fixture = createDynamicInputFixture(fieldsConfig, formModel);

    testDynamicInputControValueAccessor(fixture, testModel, 'op-integer-input input');
  }));
});
