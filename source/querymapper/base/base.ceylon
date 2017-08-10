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
import ceylon.language.meta.model {
    Class,
    Attribute
}

"An aliased database table to be used in queries.
 
 All table names are aliased. The aliases are not generated or checked in
 compile time, so keeping them unique is the responsibility of the developer.
 Each table is mapped to one or more classes. If you want multiple projections
 for a table, you can create multiple classes that map to the same table name.
 
 Typical usage:
 
     value employees = Table(\"employees\", `Employee`);
     
     return select<Employee>{
         employees,
         from = employees,
         where = /* query involving employees.column() */
     };
 
 "
shared final class Table<out Source=Anything>(name, cls) {
    "The name of the alias. **Not** statically checked for collisions."
    shared String name;
    "The mapped class. **Must** be annotated with [[querymapper.base::table]]."
    shared Class<Source> cls;
    
    "Create a [[Column]] object attached to this table, based on an attribute
     of the mapped class."
    shared Column<Source, Field> column<Field>(
        "The attribute the column maps to. **Must** be annotated with
         [[querymapper.base::column]]."
        Attribute<Source, Field> attribute
    ) {
        return Column(this, attribute);
    }
}

"An aliased database column to be used in queries.
 
 All column names are based on [[Table]] aliases - there is no bare columns.
 The class is [[sealed]], so names can only be created using the
 [[Table.column]] method.
 
 Typical usage:
 
     value employees = Table(\"employees\", `Employee`);
     value name = employees.column(`Employee.name`);
     
 "
shared class Column<out Source=Anything, out Field = Anything>(table, attribute) {
    "The table this column belongs to."
    shared Table<Source> table;
    "The attribute that this column is mapped to."
    shared Attribute<Nothing, Field> attribute;
}

"An ordering to be used in `ORDER BY` clauses."
shared interface Ordering<out Source=Anything> of Asc<Source> | Desc<Source> {
    "The database column to order by."
    shared formal Column<Source> column;
}

"Ascending ordering, maps to SQL `ASC` keyword."
shared sealed class Asc<out Source=Anything>(column) satisfies Ordering<Source> {
    shared actual Column<Source> column;
}

shared Asc<Source> asc<Source>(Column<Source> column) => Asc(column);

"Descending ordering, maps to SQL `DESC` keyword."
shared sealed class Desc<out Source=Anything>(column) satisfies Ordering<Source> {
    shared actual Column<Source> column;
}

shared Desc<Source> desc<Source>(Column<Source> column) => Desc(column);

shared class SelectQuery(query, params) {
    shared String query;
    shared {Anything*} params;
    
    string => "SelectQuery(query=``query``, params=``params``)";
}

void extractConditionParams<Source>(MutableList<Anything> result, Condition<Source> where) {
    switch (where) 
    case (is Compare<Source>) {
        value lit = where.rhs;
        result.add(lit);
    }
    case (is BinaryCondition<Source>) {
        for (condition in where.conditions) {
            extractConditionParams(result, condition);
        }
    }
    case (is UnaryCondition<Source>) {
        extractConditionParams(result, where.inner);
    }
}

shared SelectQuery select<Result, Source>(
    columns,
    from,
    where = null,
    orderBy = {}
) given Result satisfies Source {
    Table<Result> columns;
    Table<Source> from;
    Condition<Source>? where;
    {Ordering<Source>*} orderBy;
    
    value queryBuilder = StringBuilder();
    value queryParams = ArrayList<Anything>();
    value emitter = SqlEmitter(queryBuilder.append);

    emitter.select(columns);
    emitter.from(from);
    if (exists where) {
        emitter.where(where);
        extractConditionParams(queryParams, where);
    }
    if (is {Ordering<Source>+} orderBy) {
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

table
shared class Organization(name) {
    shared column String name;
}

shared void run() {
    value devs = Table("devs", `Employee`);
    value company = Table("company", `Company`);
    print(
        select<Employee, Employee|Company> {
            devs;
            from = devs;
            where = and {
                greaterThan(devs.column(`Employee.salary`))(50.0),
                atMost(devs.column(`Employee.age`))(33),
                equal(company.column(`Company.name`))("ACME")
            };
            orderBy = {
                asc(devs.column(`Employee.salary`)),
                desc(devs.column(`Employee.age`))
            };
        }
    );
}