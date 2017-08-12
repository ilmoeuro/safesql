/* Copyright 2017 Ilmo Euro

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License. */

"An ordering to be used in `ORDER BY` clauses."
shared interface Ordering<out Source=Anything> of ColumnOrdering<Source> {
}

"Ascending ordering, maps to SQL `ASC` keyword."
shared Ordering<Source> asc<Source, Field>(Column<Source, Field> column) =>
        Asc(CovariantColumn(column));

"Descending ordering, maps to SQL `DESC` keyword."
shared Ordering<Source> desc<Source, Field>(Column<Source, Field> column) =>
        Desc(CovariantColumn(column));

interface ColumnOrdering<out Source=Anything> of Asc<Source> | Desc<Source>
        satisfies Ordering<Source> {
    shared formal CovariantColumn<Source> column;
}

class Asc<out Source=Anything>(column) satisfies ColumnOrdering<Source> {
    shared actual CovariantColumn<Source> column;
}

class Desc<out Source=Anything>(column) satisfies ColumnOrdering<Source> {
    shared actual CovariantColumn<Source> column;
}