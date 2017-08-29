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
    inserting,
    Key,
    _and,
    _equal,
    InsertQuery,
    insertOne,
    primaryKey,
    UpdateQuery,
    updateOne,
    InsertQueryParameter,
    SelectQueryParameter,
    Dialect {
        h2
    },
    UpdateQueryParameter
}

table
class Employee {
    // note the alphabetical order of attributes
    column
    primaryKey
    defaultWhen { inserting }
    shared Key<Employee> id;

    column
    shared String? name;

    column
    shared Float? salary;
    
    shared new(Key<Employee> id, String name, Float salary) {
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

{[String, {SelectQueryParameter*}, SelectQuery<Employee>]*} selectValues = {
    [   "SELECT \
         \"devs\".\"id\" AS \"devs.id\",\
         \"devs\".\"name\" AS \"devs.name\",\
         \"devs\".\"salary\" AS \"devs.salary\" \
         FROM \
         \"Employee\" AS \"devs\""
    ,   {}
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
    ,   {   [`Employee.salary`, 10_000.0]
        }
    ,   from(devs)
        .where (
            greaterThan(devs.column(`Employee.salary`), 10_000.0)
        )
        .select(devs)
    ]
,   [   "SELECT \
         \"devs\".\"id\" AS \"devs.id\",\
         \"devs\".\"name\" AS \"devs.name\",\
         \"devs\".\"salary\" AS \"devs.salary\" \
         FROM \
         \"Employee\" AS \"devs\" \
         WHERE \
         (\"devs\".\"id\"=?) AND (\"devs\".\"name\"=?)"
    ,   {    [`Employee.id`, Key<Employee>(0)]
        ,    [`Employee.name`, "example"]
        }
    ,   from(devs)
        .where (
            _and {
                _equal(devs.column(`Employee.id`), Key<Employee>(0)),
                _equal(devs.column(`Employee.name`), "example")
            }
        )
        .select(devs)
    ]
};

test
parameters(`value selectValues`)
void testSelect(query, params, actual) {
    String query;
    {SelectQueryParameter*} params;
    SelectQuery<Employee> actual;
    assert ([*params] == [*actual.params]);
    assert (query == actual.query(h2));
}

{[String, {InsertQueryParameter*}, InsertQuery<Employee>]*} insertOneValues = {
    [   "INSERT INTO \"Employee\"(\"id\",\"name\",\"salary\") \
         VALUES (DEFAULT,?,?)"
    ,   {   [`Employee.name`, "John Doe"]
        ,   [`Employee.salary`, 50_000.0]
        }
    ,   insertOne (
            Employee {
                id = Key<Employee>(0);
                name = "John Doe";
                salary = 50_000.0;
            }
        )
    ]
};

test
parameters(`value insertOneValues`)
void testInsertOne(query, params, actual) {
    String query;
    {InsertQueryParameter*} params;
    InsertQuery<Employee> actual;
    assert ([*params] == [*actual.params]);
    assert (query == actual.query(h2));
}

{[String, {UpdateQueryParameter*}, UpdateQuery<Employee>]*} updateOneValues = {
    [   "UPDATE \"Employee\" \
         SET \"name\"=?,\"salary\"=? \
         WHERE \"id\"=?"
    ,   {   [`Employee.name`, "John Doe"]
        ,   [`Employee.salary`, 50_000.0]
        ,   [`Employee.id`, Key<Employee>(0)]
        }
    ,   updateOne (
            Employee {
                id = Key<Employee>(0);
                name = "John Doe";
                salary = 50_000.0;
            }
        )
    ]
,   [   "UPDATE \"Employee\" \
         SET \"name\"=? \
         WHERE \"id\"=?"
    ,   {   [`Employee.name`, "John Doe"]
        ,   [`Employee.id`, Key<Employee>(0)]
        }
    ,   updateOne (
            Employee {
                id = Key<Employee>(0);
                name = "John Doe";
                salary = 50_000.0;
            },
            `Employee.name`
        )
    ]
};

test
parameters(`value updateOneValues`)
void testUpdateOne(query, params, actual) {
    String query;
    {UpdateQueryParameter*} params;
    UpdateQuery<Employee> actual;
    assert ([*params] == [*actual.params]);
    assert (query == actual.query(h2));
}