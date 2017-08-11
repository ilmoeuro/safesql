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

"A condition used in `WHERE` clauses."
shared interface Condition<out Source = Anything>
        of Compare<Source, Anything>
        | BinaryCondition<Source>
        | UnaryCondition<Source> {
    
}

shared interface Compare<out Source=Anything, out Field=Anything>
        of Equal<Source, Field>
        | AtMost<Source, Field>
        | LessThan<Source, Field>
        | AtLeast<Source, Field>
        | GreaterThan<Source, Field>
        satisfies Condition<Source> {
    shared formal CovariantColumn<Source> lhs;
    shared formal Field rhs;
}

shared sealed class Equal<out Source=Anything, out Field=Anything>(lhs, rhs)
        satisfies Compare<Source,Field> {
    shared actual CovariantColumn<Source, Field> lhs;
    shared actual Field rhs;
}

shared Equal<Source, Field> equal<Source, Field>(lhs, rhs) {
    Column<Source, Field> lhs;
    Field rhs;
    return Equal(CovariantColumn(lhs), rhs);
}

shared sealed class AtMost<out Source=Anything, out Field=Anything>(lhs, rhs)
        satisfies Compare<Source,Field> {
    shared actual CovariantColumn<Source, Field> lhs;
    shared actual Field rhs;
}

shared AtMost<Source, Field> atMost<Source, Field>(lhs, rhs) {
    Column<Source, Field> lhs;
    Field rhs;
    return AtMost(CovariantColumn(lhs), rhs);
}

shared class LessThan<out Source=Anything, out Field=Anything>(lhs, rhs)
        satisfies Compare<Source,Field> {
    shared actual CovariantColumn<Source, Field> lhs;
    shared actual Field rhs;
}

shared LessThan<Source, Field> lessThan<Source, Field>(lhs, rhs) {
    Column<Source, Field> lhs;
    Field rhs;
    return LessThan(CovariantColumn(lhs), rhs);
}

shared class AtLeast<out Source=Anything, out Field=Anything>(lhs, rhs)
        satisfies Compare<Source,Field> {
    shared actual CovariantColumn<Source, Field> lhs;
    shared actual Field rhs;
}

shared AtLeast<Source, Field> atLeast<Source, Field>(lhs, rhs) {
    Column<Source, Field> lhs;
    Field rhs;
    return AtLeast(CovariantColumn(lhs), rhs);
}

shared class GreaterThan<out Source=Anything, out Field=Anything>(lhs, rhs)
        satisfies Compare<Source,Field> {
    shared actual CovariantColumn<Source, Field> lhs;
    shared actual Field rhs;
}

shared GreaterThan<Source, Field> greaterThan<Source, Field>(lhs, rhs) {
    Column<Source, Field> lhs;
    Field rhs;
    return GreaterThan(CovariantColumn(lhs), rhs);
}

shared interface BinaryCondition<out Source = Anything>
        of And<Source>
        | Or<Source>
        satisfies Condition<Source> {
    shared formal {Condition<Source>+} conditions;
}

shared sealed class And<out Source = Anything>(conditions) satisfies BinaryCondition<Source> {
    shared actual {Condition<Source>+} conditions;
}

shared And<Source> and<Source>({Condition<Source>+} conditions) =>
        And(conditions);

shared sealed class Or<out Source = Anything>(conditions) satisfies BinaryCondition<Source> {
    shared actual {Condition<Source>+} conditions;
}

shared Or<Source> or<Source>({Condition<Source>+} conditions) =>
        Or(conditions);

shared interface UnaryCondition<out Source = Anything>
        of Not<Source>
        satisfies Condition<Source> {
    shared formal Condition<Source> inner;
}

shared class Not<out Source = Anything>(inner) satisfies UnaryCondition<Source> {
    shared actual Condition<Source> inner;
}

shared Not<Source> not<Source>(Condition<Source> inner) =>
        Not(inner);