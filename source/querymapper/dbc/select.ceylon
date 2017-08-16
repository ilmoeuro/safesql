import querymapper.backend {
    columnAttributes,
    RowImpl,
    qualifiedColumnAlias
}
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
import ceylon.language.meta.model {
    Attribute,
    Class,
    CallableConstructor
}

import querymapper.base {
    Row,
    FromRowAnnotation,
    fromRow,
    SelectQuery
}

{Result*} select<Result>(sql, query) {
    Sql sql;
    SelectQuery<Result> query;
    
    value columns = query.resultTable;
    value rows = sql
                .Select(query.query)
                .execute(*(query.params.map(toJdbcObject)));

    assert (is Class<> model = `Result`);
    value ctors = model.getDeclaredCallableConstructors<[Row<Result>]>(`FromRowAnnotation`);
    value modelName = model.declaration.qualifiedName;
    value annotationName = `function fromRow`.qualifiedName;
    "``modelName`` must have exactly one constructor annotated ``annotationName``, that takes a `` `Row<Result>` `` argument."
    assert (exists ctor = ctors[0]);
    assert (is CallableConstructor<Result> ctor);
    
    return rows.map((row) {
        value entries = columnAttributes(model).map((attr) {
            assert (is Attribute<Result> attr);
            value colName = qualifiedColumnAlias(columns.column(attr));
            assert (exists val = row[colName]);
            return attr -> fromJdbcObject(val, attr.type);
        });
        return ctor.apply(RowImpl<Result>(map(entries)));
    });
}