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
shared final class Table<out Subject = Anything>(name, cls) {
    "The name of the alias. **Not** statically checked for collisions."
    shared String name;
    "The mapped class. **Must** be annotated with [[querymapper.base::table]]."
    shared Class<Subject> cls;
    
    "Create a [[Column]] object attached to this table, based on an attribute
     of the mapped class."
    shared Column<Subject> column(
        "The attribute the column maps to. **Must** be annotated with
         [[querymapper.base::column]]."
        Attribute<Subject, Anything> attribute
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
shared class Column<out Subject = Anything>(table, attribute) {
    "The table this column belongs to."
    shared Table<Subject> table;
    "The attribute that this column is mapped to."
    shared Attribute<> attribute;
}

"An ordering to be used in `ORDER BY` clauses."
shared interface Ordering<out Subject = Anything> of Asc<Subject> | Desc<Subject> {
    "The database column to order by."
    shared formal Column<Subject> column;
}

"Ascending ordering, maps to SQL `ASC` keyword."
shared class Asc<out Subject = Anything>(column) satisfies Ordering<Subject> {
    shared actual Column<Subject> column;
}

"Descending ordering, maps to SQL `DESC` keyword."
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
        value lit = where.rhs.literal;
        "Literal has Object lower bound for type parameter"
        assert(exists lit);
        result.add(lit);
    }
    case (is BinaryCondition<Subject>) {
        for (condition in where.conditions) {
            extractConditionParams(result, condition);
        }
    }
    case (is UnaryCondition<Subject>) {
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
    value queryParams = ArrayList<Object>();
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
            where = And {
                GreaterThan(devs.column(`Employee.salary`), Literal(50)),
                AtMost(devs.column(`Employee.age`), Literal(33)),
                Equal(company.column(`Company.name`), Literal("ACME"))
            };
            orderBy = {
                Asc(devs.column(`Employee.salary`)),
                Desc(devs.column(`Employee.age`))
            };
        }
    );
}