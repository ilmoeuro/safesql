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
    newConnectionFromDataSource,
    SqlNull
}
import ceylon.interop.java {
    javaString
}
import ceylon.language.meta.model {
    Class,
    Attribute,
    CallableConstructor,
    Type
}

import java.lang {
    JLong=Long,
    JDouble=Double
}
import java.sql {
    Types
}

import javax.sql {
    DataSource
}

import querymapper.base {
    Table,
    Join,
    Condition,
    Ordering,
    innerJoin,
    leftJoin,
    rightJoin,
    crossJoin,
    sqlFrom=from,
    columnAttributes,
    FromRowAnnotation,
    fromRow,
    qualifiedColumnAlias,
    Key,
    Row
}

shared class QueryMapper(dataSource) {
    DataSource dataSource;

    "The entry point to a `SELECT` query, builds the `FROM` clause of the query.
     
     The `FROM` clause is **first**, because it then determines the table types
     that can be used in the rest of the query, which aids in type inference
     and autocompletion."
    shared From<Source> from<Source>(
        "The first table to select from, that may be subject to joins"
        Table<Source> source,
        "The joins, applied in order."
        see(`function innerJoin`,
            `function leftJoin`,
            `function rightJoin`,
            `function crossJoin`)
        {Join<Source>*} joins = {}
    ) => From(dataSource, source, joins);
}

"The auxiliary class used by [[QueryMapper.from]]"
shared sealed class From<Source>(dataSource, source, joins = {}) {
    DataSource dataSource;
    Table<Source> source;
    {Join<Source>*} joins;
    
    "Build the `WHERE` cause of the query."
    shared Where<Source> where(condition) {
        "The condition of the `WHERE` clause"
        Condition<Source>? condition;
        return Where(dataSource, source, joins, condition);
    }
}

"The auxiliary class used by [[From.where]]"
shared sealed class Where<Source>(dataSource, source, joins, condition) {
    DataSource dataSource;
    Table<Source> source;
    {Join<Source>*} joins;
    Condition<Source>? condition;
    
    "Build the `ORDER BY` clause of the query"
    shared OrderBy<Source> orderBy(ordering) {
        "The criteria to order the results by."
        {Ordering<Source>+} ordering;
        return OrderBy(dataSource, source, joins, condition, ordering);
    }

    "Finish the `SELECT` query."
    shared {Result*} select<Result>(columns) given Result satisfies Source {
        "The table to pick from the query as the result"
        Table<Result> columns;
        return selectQuery(dataSource, columns, source, {}, condition);
    }
}

shared sealed class OrderBy<Source>(dataSource, source, joins, condition, ordering) {
    DataSource dataSource;
    Table<Source> source;
    {Join<Source>*} joins;
    Condition<Source>? condition;
    {Ordering<Source>+} ordering;
    
    "Finish the `SELECT` query."
    shared {Result*} select<Result>(columns)
            given Result satisfies Source {
        "The table to pick from the query as the result"
        Table<Result> columns;
        return selectQuery(dataSource, columns, source, joins, condition, ordering);
    }
}

Object toJavaObject([Anything, Attribute<>] param) {
    value [source, attr] = param;
    if (!exists source) {
        // TODO more flexible SqlNulls (eg. varchar/text for Strings)
        if (attr.type == `Integer`) {
            return SqlNull(Types.integer);
        }
        if (attr.type == `String`) {
            return SqlNull(Types.varchar);
        }
        if (attr.type == `Float`) {
            return SqlNull(Types.double);
        }
        if (attr.type.subtypeOf(`Key<out Anything, out Object>`)) {
            return SqlNull(Types.integer);
        }
        return SqlNull(Types.binary);
    }
    if (is Integer source) {
        return JLong(source);
    }
    if (is Float source) {
        return JDouble(source);
    }
    if (is String source) {
        return javaString(source);
    }
    return source;
}

Anything fromSqlObject(Object source, Type<Anything> type) {
    if (is SqlNull source) {
        return null;
    }
    if (is Class<Key<out Anything, out Object>> type) {
        return type.apply(source);
    }
    return source;
}

{Result*} selectQuery<Result, Source>(
    dataSource,
    columns,
    source,
    joins,
    condition = null,
    ordering = {}
) given Result satisfies Source {
    DataSource dataSource;
    Table<Result> columns;
    Table<Source> source;
    {Join<Source>*} joins;
    Condition<Source>? condition;
    {Ordering<Source>*} ordering;
    
    value query = sqlFrom(columns, joins)
                .where(condition)
                .orderBy(ordering)
                .select(columns);
    
    value rows = Sql(newConnectionFromDataSource(dataSource))
                .Select(query.query)
                .execute(*(query.params.map(toJavaObject)));
    
    return rows.map((row) {
        assert (is Class<> model = `Result`);
        value ctors = model.getDeclaredCallableConstructors<[Row<Result>]>(`FromRowAnnotation`);
        value modelName = model.declaration.qualifiedName;
        value annotationName = `function fromRow`.qualifiedName;
        "``modelName`` must have exactly one no-arg constructor annotated ``annotationName``"
        assert (exists ctor = ctors[0]);
        assert (is CallableConstructor<Result> ctor);
        value entries = columnAttributes(model).map((attr) {
            assert (is Attribute<Result> attr);
            value colName = qualifiedColumnAlias(columns.column(attr));
            assert (exists val = row[colName]);
            return attr -> fromSqlObject(val, attr.type);
        });
        return ctor.apply(Row<Result>(map(entries)));
    });
}