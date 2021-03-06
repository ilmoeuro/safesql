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

import safesql.core {
    InsertQuery,
    Dialect
}

void insert<Insertable>(dialect, sql, query) {
    Dialect dialect;
    Sql sql;
    InsertQuery<Insertable> query;

    value [rows, keys] = sql
                .Insert(query.query(dialect))
                .execute(*(query.params.map(toJdbcObject)));
}