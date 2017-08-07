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

import ceylon.collection {
    MutableList,
    ArrayList
}
import ceylon.language.meta.declaration {
    ValueDeclaration,
    ClassDeclaration
}
import ceylon.language.meta.model {
    Class,
    Attribute
}

"The annotation class for [[column]] annotation"
shared final annotation class ColumnAnnotation(name = "")
    satisfies OptionalAnnotation<
        ColumnAnnotation,
        ValueDeclaration
> {
    shared String name;
}

"The annotation to mark an attribute as a database column.
 
 All class attributes that are not annotated as columns are ignored. If you
 specify the `name` parameter, it will be used as the column name, otherwise
 the attribute name will be used as the column name."
shared annotation ColumnAnnotation column(
    "The name of the database column corresponding to the annotated attribute.
     If empty, the attribute name itself is used."
    String name = ""
)
        => ColumnAnnotation(name);

"The annotation class for [[table]] annotation."
shared final annotation class TableAnnotation(name = "")
    satisfies OptionalAnnotation<
        TableAnnotation,
        ClassDeclaration
> {
    shared String name;
}

"The annotation to mark a class as a database table.
 
 Classes can't be used in queries if not annotated `table`. If you specify
 the `name` parameter, it will be used as the table name, otherwise the
 name of the class itself is used."
shared annotation TableAnnotation table(
    "The name of the database table corresponding to the annotated class.
     If empty, the class name itself is used."
    String name = ""
)
        => TableAnnotation(name);

shared alias Table<out Subject = Anything> => Class<Subject> | AliasedTable<Subject>;

shared alias Column<out Subject = Anything> => BareColumn<Subject> | AliasedColumn<Subject>;

suppressWarnings("unusedDeclaration")
shared final sealed class BareColumn<out Subject = Anything>(attribute) {
    shared Attribute<> attribute;
}

shared BareColumn<Subject> col<Subject>(Attribute<Subject, Anything> attr) {
    return BareColumn<Subject>(attr);
}

shared final class AliasedTable<out Subject = Anything>(name, cls) {
    shared String name;
    shared Class<Subject> cls;
    
    shared AliasedColumn<Subject> column(
        Attribute<Subject, Anything> attribute
    ) {
        return AliasedColumn(this, attribute);
    }
}

shared sealed class AliasedColumn<out Subject = Anything>(table, attribute) {
    shared AliasedTable<Subject> table;
    shared Attribute<> attribute;
}

shared interface Condition<Subject>
        of Compare<Subject>
        | BinaryCondition<Subject>
        | UnaryCondition<Subject> {
    
}

shared final class Literal(literal) {
    shared Object literal;
}

shared interface Compare<Subject = Anything>
        of Equal<Subject>
        | AtMost<Subject>
        | LessThan<Subject>
        | AtLeast<Subject>
        | GreaterThan<Subject>
        satisfies Condition<Subject> {
    shared formal Column<Subject> lhs;
    shared formal Literal rhs;
}

shared class Equal<Subject>(lhs, rhs) satisfies Compare<Subject> {
    shared actual Column<Subject> lhs;
    shared actual Literal rhs;
}

shared class AtMost<Subject>(lhs, rhs) satisfies Compare<Subject> {
    shared actual Column<Subject> lhs;
    shared actual Literal rhs;
}

shared class LessThan<Subject>(lhs, rhs) satisfies Compare<Subject> {
    shared actual Column<Subject> lhs;
    shared actual Literal rhs;
}

shared class AtLeast<Subject>(lhs, rhs) satisfies Compare<Subject> {
    shared actual Column<Subject> lhs;
    shared actual Literal rhs;
}

shared class GreaterThan<Subject> (lhs, rhs) satisfies Compare<Subject>  {
    shared actual Column<Subject> lhs;
    shared actual Literal rhs;
}

shared interface BinaryCondition<Subject = Anything>
        of And<Subject>
        | Or<Subject>
        satisfies Condition<Subject> {
    shared formal Condition<Subject> left;
    shared formal Condition<Subject> right;
}

shared class And<Subject>(left, right) satisfies BinaryCondition<Subject> {
    shared actual Condition<Subject> left;
    shared actual Condition<Subject> right;
}

shared class Or<Subject>(left, right) satisfies BinaryCondition<Subject> {
    shared actual Condition<Subject> left;
    shared actual Condition<Subject> right;
}

shared interface UnaryCondition<Subject = Anything>
        of Not<Subject>
        satisfies Condition<Subject> {
    shared formal Condition<Subject> inner;
}

shared class Not<Subject>(inner) satisfies UnaryCondition<Subject> {
    shared actual Condition<Subject> inner;
}

shared interface Ordering<out Subject = Anything> of Asc<Subject> | Desc<Subject> {
    shared formal Column<Subject> column;
}

shared class Asc<out Subject = Anything>(column) satisfies Ordering<Subject> {
    shared actual Column<Subject> column;
}

shared class Desc<out Subject = Anything>(column) satisfies Ordering<Subject> {
    shared actual Column<Subject> column;
}

shared class SelectQuery(query, params) {
    shared String query;
    shared {Object*} params;
    
    string => "SelectQuery(query=``query``, params=``params``)";
}

void extractConditionParams<Subject>(MutableList<Object> result, Condition<Subject> where) {
    switch (where) 
    case (is Compare<Subject>) {
        result.add(where.rhs.literal);
    }
    case (is BinaryCondition<Subject>) {
        extractConditionParams(result, where.left);
        extractConditionParams(result, where.right);
    }
    case (is UnaryCondition<Subject>) {
        extractConditionParams(result, where.inner);
    }
}

shared SelectQuery select<Subject>(
    columns,
    from,
    where = null,
    orderBy = {}
) {
    Table<Subject> columns;
    Table<Subject> from;
    Condition<Subject>? where;
    {Ordering<Subject>*} orderBy;
    
    value queryBuilder = StringBuilder();
    value queryParams = ArrayList<Object>();
    value emitter = SqlEmitter<Subject>(queryBuilder.append);

    emitter.select(columns);
    emitter.from(from);
    if (exists where) {
        emitter.where(where);
        extractConditionParams(queryParams, where);
    }
    if (is {Ordering<Subject>+} orderBy) {
        emitter.orderBy(orderBy);
    }
    
    return SelectQuery(queryBuilder.string, queryParams);
}

table
shared class Employee(name, age, salary) {
    shared column String name;
    shared column Integer age;
    shared column Float salary;
}

table
shared class Company(name) {
    shared column String name;
}

shared class Organization(name) {
    shared column String name;
}

shared void run() {
    value devs = AliasedTable("devs", `Employee`);
    print(
        select<Employee|Company> {
            devs;
            from = `Company`;
            where = 
                And (
                    GreaterThan(devs.column(`Employee.salary`), Literal(50)),
                    AtMost(`Company.name`, Literal(33))
                );
            orderBy = {
                Asc(devs.column(`Employee.salary`)),
                Desc(devs.column(`Employee.age`))
            };
        }
    );
}