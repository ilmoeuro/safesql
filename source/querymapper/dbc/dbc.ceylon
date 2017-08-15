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

import javax.sql {
    DataSource
}

import querymapper.base {
    SelectQuery,
    InsertQuery
}

shared class QueryMapper(database) {
    Sql|DataSource database;
    Sql sql;
    if (is Sql database) {
        sql = database;
    } else {
        sql = Sql(newConnectionFromDataSource(database));
    }

    "Execute a [[SelectQuery]].
     
     Use [[querymapper.base::from]] to build the query, and pass it to this
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
        return select(sql, query);
    }
    
    "Execute an [[InsertQuery]].
     
     Use [[querymapper.base::insert]] to build the query, and pass it to this
     method to be executed. Example:
     
     ~~~
     Employee employee = /* ... */;
     
     value qm = QueryMapper(sql);
     
     qm.doInsert(insert(employee));
     ~~~"
    shared void doInsert<Insertable>(query) {
        InsertQuery<Insertable> query;
        insert(sql, query);
    }
}
