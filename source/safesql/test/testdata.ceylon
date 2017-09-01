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

import safesql.core {
    Key,
    Row,
    defaultWhen,
    inserting,
    fromRow,
    primaryKey,
    table,
    column,
    Table
}
import safesql.helpers {
    reflectionEquals,
    compositeHash,
    reflectionString
}

table
class Employee extends Object {
    
    shared static String schemaSql =
         """CREATE TABLE "Employee"(
                "id" INTEGER NOT NULL AUTO_INCREMENT,
                "name" VARCHAR(255),
                "salary" DOUBLE,
                PRIMARY KEY ("id")
            );
            """;

    // note the alphabetical order of attributes
    column
    primaryKey
    defaultWhen { inserting }
    shared Key<Employee> id;

    column
    shared String? name;

    column
    shared Float? salary;
    
    shared new(Key<Employee> id, String? name, Float? salary)
            extends Object() {
        this.id = id;
        this.name = name;
        this.salary = salary;
    }
    
    suppressWarnings("unusedDeclaration")
    fromRow
    new fromRow(Row<Employee> row) extends Object() {
        id = row.get(`id`);
        name = row.get(`name`);
        salary = row.get(`salary`);
    }

    equals(Object that) => reflectionEquals(this, that, `id`, `name`, `salary`);
    
    hash => compositeHash(id, name, salary);
    
    string => reflectionString(this, `id`, `name`, `salary`);
}

Table<Employee> employees = Table("employees", `Employee`);