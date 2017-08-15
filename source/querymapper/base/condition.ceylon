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
see(`function _equal`
   ,`function atMost`
   ,`function lessThan`
   ,`function atLeast`
   ,`function greaterThan`
   ,`function _and`
   ,`function _or`
   ,`function _not`)
shared interface Condition<out Source = Anything>
        of Compare<Source, Anything>
        | BinaryCondition<Source>
        | UnaryCondition<Source> {
    
}

"The `=` SQL operator"
shared Condition<Source> _equal<Source, Field>(lhs, rhs) {
    "The database column to compare"
    Column<Source, Field> lhs;
    "The literal value to compare the database column to"
    Field rhs;
    return Equal(CovariantColumn(lhs), rhs);
}

"The `<=` SQL operator"
shared Condition<Source> atMost<Source, Field>(lhs, rhs) {
    "The database column to compare"
    Column<Source, Field> lhs;
    "The literal value to compare the database column to"
    Field rhs;
    return AtMost(CovariantColumn(lhs), rhs);
}

"The `<` SQL operator"
shared Condition<Source> lessThan<Source, Field>(lhs, rhs) {
    "The database column to compare"
    Column<Source, Field> lhs;
    "The literal value to compare the database column to"
    Field rhs;
    return LessThan(CovariantColumn(lhs), rhs);
}

"The `>=` SQL operator"
shared Condition<Source> atLeast<Source, Field>(lhs, rhs) {
    "The database column to compare"
    Column<Source, Field> lhs;
    "The literal value to compare the database column to"
    Field rhs;
    return AtLeast(CovariantColumn(lhs), rhs);
}

"The `>` SQL operator"
shared Condition<Source> greaterThan<Source, Field>(lhs, rhs) {
    "The database column to compare"
    Column<Source, Field> lhs;
    "The literal value to compare the database column to"
    Field rhs;
    return GreaterThan(CovariantColumn(lhs), rhs);
}

"The `AND` SQL operator"
shared Condition<Source> _and<Source>(conditions) {
    "The conditions that are joined with `AND`"
    {Condition<Source>+} conditions;
    return And(conditions);
}

"The `OR` SQL operator"
shared Condition<Source> _or<Source>(conditions) {
    "The conditions that are joined with `OR`"
    {Condition<Source>+} conditions;
    return Or(conditions);
}

"The `NOT` SQL operator"
shared Condition<Source> _not<Source>(inner) {
    "The inverted condition."
    Condition<Source> inner;
    return Not(inner);
}

interface Compare<out Source=Anything, out Field=Anything>
        of Equal<Source, Field>
        | AtMost<Source, Field>
        | LessThan<Source, Field>
        | AtLeast<Source, Field>
        | GreaterThan<Source, Field>
        satisfies Condition<Source> {
    shared formal CovariantColumn<Source> lhs;
    shared formal Field rhs;
}

class Equal<out Source=Anything, out Field=Anything>(lhs, rhs)
        satisfies Compare<Source,Field> {
    shared actual CovariantColumn<Source, Field> lhs;
    shared actual Field rhs;
}

class AtMost<out Source=Anything, out Field=Anything>(lhs, rhs)
        satisfies Compare<Source,Field> {
    shared actual CovariantColumn<Source, Field> lhs;
    shared actual Field rhs;
}

class LessThan<out Source=Anything, out Field=Anything>(lhs, rhs)
        satisfies Compare<Source,Field> {
    shared actual CovariantColumn<Source, Field> lhs;
    shared actual Field rhs;
}

class AtLeast<out Source=Anything, out Field=Anything>(lhs, rhs)
        satisfies Compare<Source,Field> {
    shared actual CovariantColumn<Source, Field> lhs;
    shared actual Field rhs;
}

class GreaterThan<out Source=Anything, out Field=Anything>(lhs, rhs)
        satisfies Compare<Source,Field> {
    shared actual CovariantColumn<Source, Field> lhs;
    shared actual Field rhs;
}

interface BinaryCondition<out Source = Anything>
        of And<Source>
        | Or<Source>
        satisfies Condition<Source> {
    shared formal {Condition<Source>+} conditions;
}

class And<out Source = Anything>(conditions) satisfies BinaryCondition<Source> {
    shared actual {Condition<Source>+} conditions;
}

class Or<out Source = Anything>(conditions) satisfies BinaryCondition<Source> {
    shared actual {Condition<Source>+} conditions;
}

interface UnaryCondition<out Source = Anything>
        of Not<Source>
        satisfies Condition<Source> {
    shared formal Condition<Source> inner;
}

class Not<out Source = Anything>(inner) satisfies UnaryCondition<Source> {
    shared actual Condition<Source> inner;
}