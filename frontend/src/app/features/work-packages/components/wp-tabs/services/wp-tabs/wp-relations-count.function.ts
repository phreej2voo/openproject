import { Injector } from '@angular/core';
import { Observable, combineLatest, from, Subject } from 'rxjs';
import { switchMap, startWith } from 'rxjs/operators';
import { WorkPackageResource } from 'core-app/features/hal/resources/work-package-resource';
import { PathHelperService } from 'core-app/core/path-helper/path-helper.service';
import { WorkPackageRelationsService } from 'core-app/features/work-packages/components/wp-relations/wp-relations.service';

export function workPackageRelationsCount(
  workPackage:WorkPackageResource,
  injector:Injector,
):Observable<number> {
  const pathHelper = injector.get(PathHelperService);
  const wpRelations = injector.get(WorkPackageRelationsService);
  const wpId = workPackage.id!.toString();
  // It is an intermediate solution, until the API can return all relations
  // in the long term, the tabs are going to be the same as in the notifications
  const url = pathHelper.workPackageGetRelationsCounterPath(wpId.toString());
  const updateTrigger$ = new Subject<void>();

  // Listen for relation state changes
  const relationsState$ = wpRelations.state(wpId).values$().pipe(startWith(null));

  return combineLatest([relationsState$, updateTrigger$.pipe(startWith(null))]).pipe(
    switchMap(() =>
      from(
        fetch(url)
          .then((res):Promise<{ count:number }> => res.json())
          .then((data) => data.count),
      )),
  );
}
