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

import ceylon.test {
    test,
    parameters
}

import safesql.core {
    table,
    column,
    SelectQuery,
    fromRow,
    Row,
    Table,
    from,
    greaterThan,
    defaultWhen,
    inserting
}

table
class Employee {
    // note the alphabetical order of attributes
    column
    defaultWhen { inserting }
    shared Integer id;

    column
    shared String name;

    column
    shared Float salary;
    
    shared new(Integer id, String name, Float salary) {
        this.id = id;
        this.name = name;
        this.salary = salary;
    }
    
    suppressWarnings("unusedDeclaration")
    fromRow
    new fromRow(Row<Employee> row) {
        id = row.get(`id`);
        name = row.get(`name`);
        salary = row.get(`salary`);
    }
}

Table<Employee> devs = Table("devs", `Employee`);

{[String, SelectQuery<Employee>]*} selectValues = {
    [   "SELECT \
         \"devs\".\"id\" AS \"devs.id\",\
         \"devs\".\"name\" AS \"devs.name\",\
         \"devs\".\"salary\" AS \"devs.salary\" \
         FROM \
         \"Employee\" AS \"devs\""
    ,   from(devs).where(null).select(devs)
    ]
,   [   "SELECT \
         \"devs\".\"id\" AS \"devs.id\",\
         \"devs\".\"name\" AS \"devs.name\",\
         \"devs\".\"salary\" AS \"devs.salary\" \
         FROM \
         \"Employee\" AS \"devs\" \
         WHERE \
         \"devs\".\"salary\">?"
    ,   from(devs)
        .where (
            greaterThan(devs.column(`Employee.salary`), 10_000.0)
        )
        .select(devs)
    ]
};

test
parameters(`value selectValues`)
void testSelect(String expected, SelectQuery<Employee> actual) {
    assert (expected == actual.query);
}