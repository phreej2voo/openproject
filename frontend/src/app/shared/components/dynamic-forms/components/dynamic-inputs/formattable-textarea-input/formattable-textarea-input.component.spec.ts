import { discardPeriodicTasks, fakeAsync, flush, tick } from '@angular/core/testing';
import { createDynamicInputFixture } from 'core-app/shared/components/dynamic-forms/spec/helpers';
import { By } from '@angular/platform-browser';
import { IOPFormlyFieldSettings } from 'core-app/shared/components/dynamic-forms/typings';

describe('FormattableTextareaInputComponent', () => {
  it('should load the field', fakeAsync(() => {
    const fieldsConfig:IOPFormlyFieldSettings[] = [
      {
        type: 'formattableInput',
        key: 'testControl',
        templateOptions: {
          required: true,
          label: 'testControl',
          type: 'text',
          placeholder: '',
          disabled: false,
          bindLabel: 'name',
          bindValue: 'value',
          noWrapLabel: true,
          editorType: 'full' 
        },
      },
    ];
    const formModel:IOPFormModel = {
      testControl: {
        html: '<p>tesValue</p>',
        raw: 'tesValue',
      },
    };
    const testModel = {
      initialValue: formModel.testControl,
      changedValue: 'testValue2',
    };
    const fixture = createDynamicInputFixture(fieldsConfig, formModel);
    const dynamicInput = fixture.debugElement.query(By.css('.document-editor__editable-container')).nativeElement;
    const dynamicForm = fixture.componentInstance.dynamicForm.field.formControl;
    const dynamicDebugElement = fixture.debugElement.query(By.css('op-formattable-control'));
    const dynamicElement = dynamicDebugElement.nativeElement;

    // Test ControlValueAccessor
    // Write Value
    expect(dynamicForm.value.testControl).toEqual(testModel.initialValue);
    expect(dynamicElement.classList.contains('ng-untouched')).toBeTrue();
    expect(dynamicElement.classList.contains('ng-valid')).toBeTrue();
    expect(dynamicElement.classList.contains('ng-pristine')).toBeTrue();

    fixture.detectChanges();
    tick(1000);
    flush();

    // Discard any editor intervals
    discardPeriodicTasks();
  }));
});
