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
shared interface Condition<out Subject = Anything>
        of Compare<Subject>
        | BinaryCondition<Subject>
        | UnaryCondition<Subject> {
    
}

shared final class Literal<out Subject = Object>(literal)
        given Subject satisfies Object {
    shared Subject literal;
}

shared interface Compare<out Subject = Anything>
        of Equal<Subject>
        | AtMost<Subject>
        | LessThan<Subject>
        | AtLeast<Subject>
        | GreaterThan<Subject>
        satisfies Condition<Subject> {
    shared formal Column<Subject> lhs;
    shared formal Literal<Subject> rhs;
}

shared class Equal<out Subject = Anything>(lhs, rhs) satisfies Compare<Subject> {
    shared actual Column<Subject> lhs;
    shared actual Literal<Subject> rhs;
}

shared class AtMost<out Subject = Anything>(lhs, rhs) satisfies Compare<Subject> {
    shared actual Column<Subject> lhs;
    shared actual Literal<Subject> rhs;
}

shared class LessThan<out Subject = Anything>(lhs, rhs) satisfies Compare<Subject> {
    shared actual Column<Subject> lhs;
    shared actual Literal<Subject> rhs;
}

shared class AtLeast<out Subject = Anything>(lhs, rhs) satisfies Compare<Subject> {
    shared actual Column<Subject> lhs;
    shared actual Literal<Subject> rhs;
}

shared class GreaterThan<out Subject = Anything> (lhs, rhs) satisfies Compare<Subject>  {
    shared actual Column<Subject> lhs;
    shared actual Literal<Subject> rhs;
}

shared interface BinaryCondition<out Subject = Anything>
        of And<Subject>
        | Or<Subject>
        satisfies Condition<Subject> {
    shared formal {Condition<>+} conditions;
}

shared class And<out Subject = Anything>(conditions) satisfies BinaryCondition<Subject> {
    shared actual {Condition<>+} conditions;
}

shared class Or<out Subject = Anything>(conditions) satisfies BinaryCondition<Subject> {
    shared actual {Condition<>+} conditions;
}

shared interface UnaryCondition<out Subject = Anything>
        of Not<Subject>
        satisfies Condition<Subject> {
    shared formal Condition<Subject> inner;
}

shared class Not<out Subject = Anything>(inner) satisfies UnaryCondition<Subject> {
    shared actual Condition<Subject> inner;
}