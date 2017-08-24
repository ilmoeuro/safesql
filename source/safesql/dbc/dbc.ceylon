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
    Sql
}
import ceylon.logging {
    Logger,
    logger
}

import safesql.core {
    SelectQuery,
    InsertQuery,
    Dialect
}

Logger log = logger(`module`);

shared class SafeSql(sql, dialect, logSql = false) {
    "The [[Sql]] object used to connect to the database and execute queries. You
     can mix [[Sql]] and [[SafeSql]] queries freely."
    Sql sql;
    Dialect dialect;
    "Log the generated SQL using `ceylon.logging`"
    Boolean logSql;
    
    void logIfEnabled(String message) {
        if (logSql) {
            log.debug(message);
        }
    }

    "Execute a [[SelectQuery]].
     
     Use [[safesql.core::from]] to build the query, and pass it to this
     method to be executed. Example:
     
     ~~~
     value qm = QueryMapper(sql);
     
     value results = qm.doSelect(
         from {
             devs;
         }
         .where (
             greaterThan(devs.column(`Employee.age`), 10)
         )
         .select(devs)
     );
     
     for (result in results) {
         print(result);
     }
     ~~~"
    shared {Result*} doSelect<Result>(query) {
        "The query to execute."
        SelectQuery<Result> query;
        logIfEnabled(query.query(dialect));
        return select(dialect, sql, query);
    }
    
    "Execute an [[InsertQuery]].
     
     Use [[safesql.core::insertOne]] to build the query, and pass it to this
     method to be executed. Example:
     
     ~~~
     Employee employee = /* ... */;
     
     value qm = QueryMapper(sql);
     
     qm.doInsert(insert(employee));
     ~~~"
    shared void doInsert<Insertable>(query) {
        InsertQuery<Insertable> query;
        logIfEnabled(query.query(dialect));
        insert(dialect, sql, query);
    }
}
