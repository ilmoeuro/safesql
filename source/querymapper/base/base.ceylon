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

shared alias Table => Class<> | AliasedTable;

shared alias Column => Attribute<> | AliasedColumn;

shared final class AliasedTable(name, cls) {
    shared String name;
    shared Class<> cls;
    
    shared AliasedColumn column(Attribute<> attribute) {
        return AliasedColumn(this, attribute);
    }
}

shared sealed class AliasedColumn(table, attribute) {
    shared AliasedTable table;
    shared Attribute<> attribute;
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

shared interface Condition of Compare | BinaryCondition | UnaryCondition {
    
}

shared final class Literal(literal) {
    shared Object literal;
}

shared interface Compare of Equal
                            | AtMost
                            | LessThan
                            | AtLeast
                            | GreaterThan
        satisfies Condition {
    shared formal Column lhs;
    shared formal Literal rhs;
}

shared class Equal(lhs, rhs) satisfies Compare {
    shared actual Column lhs;
    shared actual Literal rhs;
}

shared class AtMost(lhs, rhs) satisfies Compare {
    shared actual Column lhs;
    shared actual Literal rhs;
}

shared class LessThan(lhs, rhs) satisfies Compare {
    shared actual Column lhs;
    shared actual Literal rhs;
}

shared class AtLeast(lhs, rhs) satisfies Compare {
    shared actual Column lhs;
    shared actual Literal rhs;
}

shared class GreaterThan(lhs, rhs) satisfies Compare {
    shared actual Column lhs;
    shared actual Literal rhs;
}

shared interface BinaryCondition of And | Or satisfies Condition {
    shared formal Condition left;
    shared formal Condition right;
}

shared class And(left, right) satisfies BinaryCondition {
    shared actual Condition left;
    shared actual Condition right;
}

shared class Or(left, right) satisfies BinaryCondition {
    shared actual Condition left;
    shared actual Condition right;
}

shared interface UnaryCondition of Not satisfies Condition {
    shared formal Condition inner;
}

shared class Not(inner) satisfies UnaryCondition {
    shared actual Condition inner;
}

shared interface Ordering of Asc | Desc {
    shared formal Column column;
}

shared class Asc(column) satisfies Ordering {
    shared actual Column column;
}

shared class Desc(column) satisfies Ordering {
    shared actual Column column;
}

shared class SelectQuery(query, params) {
    shared String query;
    shared {Object*} params;
    
    string => "SelectQuery(query=``query``, params=``params``)";
}

void extractConditionParams(MutableList<Object> result, Condition where) {
    switch (where) 
    case (is Equal | LessThan | AtMost | GreaterThan | AtLeast) {
        result.add(where.rhs.literal);
    }
    case (is And | Or) {
        extractConditionParams(result, where.left);
        extractConditionParams(result, where.right);
    }
    case (is Not) {
        extractConditionParams(result, where.inner);
    }
}

shared SelectQuery select(
    columns,
    from,
    where = null,
    orderBy = {}
) {
    Table columns;
    Table from;
    Condition? where;
    {Ordering*} orderBy;
    
    value queryBuilder = StringBuilder();
    value queryParams = ArrayList<Object>();
    value emitter = SqlEmitter(queryBuilder.append);

    emitter.select(columns);
    emitter.from(from);
    if (exists where) {
        emitter.where(where);
        extractConditionParams(queryParams, where);
    }
    if (is {Ordering+} orderBy) {
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

shared void run() {
    value devs = AliasedTable("devs", `Employee`);
    print(
        select {
            columns = devs;
            from = devs;
            where = And (
                GreaterThan(devs.column(`Employee.salary`), Literal(50)),
                AtMost(devs.column(`Employee.age`), Literal(33))
            );
            orderBy = {
                Asc(devs.column(`Employee.salary`)),
                Desc(devs.column(`Employee.age`))
            };
        }
    );
}