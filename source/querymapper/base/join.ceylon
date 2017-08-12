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

shared interface Join<out Source=Anything>
        of KeyedJoin<Source>
        |  CrossJoin<Source> {
    shared formal Table<Source> table;
}

shared Join<Source> innerJoin<Source, Field>(table, leftKey, rightKey) {
    Table<Source> table;
    Column<Source, Field> leftKey;
    Column<Source, Field> rightKey;
    return InnerJoin(table, CovariantColumn(leftKey), CovariantColumn(rightKey));
}

shared Join<Source> leftJoin<Source, Field>(table, leftKey, rightKey) {
    Table<Source> table;
    Column<Source, Field> leftKey;
    Column<Source, Field> rightKey;
    return LeftJoin(table, CovariantColumn(leftKey), CovariantColumn(rightKey));
}

shared Join<Source> rightJoin<Source, Field>(table, leftKey, rightKey) {
    Table<Source> table;
    Column<Source, Field> leftKey;
    Column<Source, Field> rightKey;
    return RightJoin(table, CovariantColumn(leftKey), CovariantColumn(rightKey));
}

shared Join<Source> crossJoin<Source>(Table<Source> table) =>
        CrossJoin(table);

interface KeyedJoin<out Source=Anything, out Field=Anything>
        of InnerJoin<Source, Field>
        | LeftJoin<Source, Field>
        | RightJoin<Source, Field>
        satisfies Join<Source> {
    shared formal CovariantColumn<Source, Field> leftKey;
    shared formal CovariantColumn<Source, Field> rightKey;
}

class InnerJoin<out Source=Anything, out Field=Anything>(
    table,
    leftKey,
    rightKey
) satisfies KeyedJoin<Source, Field> {
    shared actual Table<Source> table;
    shared actual CovariantColumn<Source, Field> leftKey;
    shared actual CovariantColumn<Source, Field> rightKey;
}

class LeftJoin<out Source=Anything, out Field=Anything>(
    table,
    leftKey,
    rightKey
) satisfies KeyedJoin<Source, Field> {
    shared actual Table<Source> table;
    shared actual CovariantColumn<Source, Field> leftKey;
    shared actual CovariantColumn<Source, Field> rightKey;
}

class RightJoin<out Source=Anything, out Field=Anything>(
    table,
    leftKey,
    rightKey
) satisfies KeyedJoin<Source, Field> {
    shared actual Table<Source> table;
    shared actual CovariantColumn<Source, Field> leftKey;
    shared actual CovariantColumn<Source, Field> rightKey;
}

class CrossJoin<out Source=Anything>(table)
        satisfies Join<Source> {
    shared actual Table<Source> table;
}