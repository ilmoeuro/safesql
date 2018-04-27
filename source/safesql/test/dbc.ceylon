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
import ceylon.test {
    test,
    parameters
}

import org.h2.jdbcx {
    JdbcDataSource
}

import safesql.core {
    Dialect {
        h2
    },
    from,
    SelectQuery,
    _equal,
    Key,
    _lessThan
}
import safesql.dbc {
    SafeSql
}

String insertEmployeesSql =
     """INSERT INTO
            "Employee"("name", "salary")
        VALUES
            ('Employee #1', 50000),
            ('Employee #2', 50000),
            ('Employee #3', 60000),
            ('Employee #4', 70000),
            ('Employee #5', 80000),
            ('Employee #6', 90000),
            ('Employee #7', 100000),
            ('Employee #8', NULL),
            (NULL, 1000),
            (NULL, NULL);
        """;
     

{[SelectQuery<Employee>, {Employee*}]*} dbcSelectParameters = {
    [   from(employees)
            .where(_equal(employees.column(`Employee.name`), "Employee #1"))
            .select(employees)
    ,   {   Employee {
                id = Key<Employee>(1);
                name = "Employee #1";
                salary = 50_000.0;
            }
        }
    ]
,   [   from(employees)
            .where(_lessThan(employees.column(`Employee.salary`), 70_000.0))
            .select(employees)
    ,   {   Employee {
                id = Key<Employee>(1);
                name = "Employee #1";
                salary = 50_000.0;
            }
        ,   Employee {
                id = Key<Employee>(2);
                name = "Employee #2";
                salary = 50_000.0;
            }
        ,   Employee {
                id = Key<Employee>(3);
                name = "Employee #3";
                salary = 60_000.0;
            }
        ,   Employee {
                id = Key<Employee>(9);
                name = null;
                salary = 1000.0;
            }
        }
    ]
};

test
parameters(`value dbcSelectParameters`)
void testDbcSelect(query, expected) {
    SelectQuery<Employee> query;
    {Employee*} expected;

    value ds = JdbcDataSource();
    ds.setURL("jdbc:h2:mem:");
    
    try (ds.connection) {
        value sql = Sql(newConnectionFromDataSource(ds));

        try (sql.Transaction()) {
            sql.Statement(Employee.schemaSql).execute();

            value [inserted,_] = sql.Insert(insertEmployeesSql).execute();
            assert (inserted == 10);
            
            value actual = SafeSql(sql, h2).doSelect(query);
                    
            assert ([*expected] == [*actual]);
        }
    }
}
