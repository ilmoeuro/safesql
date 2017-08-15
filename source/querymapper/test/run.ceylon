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

import ceylon.dbc {
    Sql,
    newConnectionFromDataSource
}

import org.h2.jdbcx {
    JdbcDataSource
}

import querymapper.base {
    table,
    column,
    Table,
    from,
    leftJoin,
    _and,
    greaterThan,
    asc,
    _equal,
    Key,
    insert,
    fromRow,
    Row,
    desc
}
import querymapper.dbc {
    QueryMapper
}

table
shared class Employee {
    column
    shared Key<Employee> id;

    column
    shared String name;

    column
    shared Integer age;

    column
    shared Float salary;

    column
    shared Key<Company> company;
    
    shared new (id, name, age, salary, company) {
        Key<Employee> id;
        String name;
        Integer age;
        Float salary;
        Key<Company> company;
        this.id = id;
        this.name = name;
        this.age = age;
        this.salary = salary;
        this.company = company;
    }
    
    suppressWarnings("unusedDeclaration")
    fromRow
    new fromRow(Row<Employee> row) {
        id = row.get(`id`);
        name = row.get(`name`);
        age = row.get(`age`);
        salary = row.get(`salary`);
        company = row.get(`company`);
    }
    
    string => "`` `class`.qualifiedName `` {
                 id = ``id``,
                 name = ``name``,
                 age = ``age``,
                 salary = ``salary``,
                 company = ``company``
               }";
}

table
shared class Company(id, name) {
    column
    shared Key<Company> id;

    column
    shared String name;
}

shared void run() {
    
    value devs = Table("devs", `Employee`);
    value company = Table("company", `Company`);
    print(
        from {
            devs;
            leftJoin(
                company,
                devs.column(`Employee.company`),
                company.column(`Company.id`)
            )
        }
        .where (
            _and {
                greaterThan(devs.column(`Employee.age`), 50),
                _equal(company.column(`Company.name`), "ACME")
            }
        )
        .orderBy {
            asc(devs.column(`Employee.salary`))
        }
        .select(devs)
    );
    
    value dev = Employee {
        id = Key<Employee>(2);
        name = "John Doe";
        age = 43;
        salary = 50_000.00;
        company = Key<Company>(1);
    };
    
    print(insert(dev));
    
    value ds = JdbcDataSource();
    ds.setURL("jdbc:h2:mem:;INIT=RUNSCRIPT FROM './db_init.sql'");

    value sql = Sql(newConnectionFromDataSource(ds));
    value qm = QueryMapper(sql, true);
    
    try (ds.connection) {
        try(sql.Transaction()) {
            qm.doInsert(insert(dev));
        }
            
        try(sql.Transaction()) {
            value results = qm.doSelect(
                from {
                    devs;
                }
                .where (
                    null
                )
                .orderBy {
                    desc(devs.column(`Employee.age`))
                }
                .select(devs)
            );
            
            for (result in results) {
                print(result);
            }
        }
    }
}