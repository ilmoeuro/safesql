import querymapper.backend {
    columnAnnotation,
    tableAnnotation,
    columnAttributes
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

import ceylon.collection {
    ArrayList
}
import ceylon.language.meta.model {
    Class,
    Attribute
}

suppressWarnings("unusedDeclaration") // Result is a phantom type parameter
shared sealed class InsertQuery<Insertable>(query, params) {
    shared String query;
    shared {[Anything, Attribute<>]*} params;

    string => "`` `class`.qualifiedName `` {
                   query=``query``,
                   params=``params``
               }";
}

"Construct an `INSERT` query that persists [[insertable]] to the database.
 
 [[Insertable]] **must** be a class, and annotated [[table]]. It's scanned for
 attributes annotated with [[column]], and each one of them is used a as a
 column in the `INSERT` query. The actual values for the columns are retrieved
 from [[insertable]]. The function won't work if [[Insertable]] is something
 else than the actual type of
 [[insertable]] (for example, [[Object]])."
shared InsertQuery<Insertable> insert<Insertable>(insertable)
        given Insertable satisfies Object {
    "The object to be persisted to the database"
    Insertable insertable;
    value queryBuilder = StringBuilder();
    value queryParams = ArrayList<[Anything, Attribute<>]>();
    value emitter = PgH2SqlEmitter(queryBuilder.append);
    value fnName = `function insert`.name;
    value insertableName = `Insertable`.string;

    "``fnName`` expects a class type parameter, given ``insertableName``"
    assert (is Class<> type = `Insertable`);
    emitter.insert(type);
    
    // check that `Insertable` is propery annotated
    tableAnnotation(type);
    
    for (attribute in columnAttributes(type)) {
        if (columnAnnotation(attribute).insert) {
            variable Anything val = attribute.bind(insertable).get();
            if (is Key<out Anything, out Object> key = val) {
                val = key.field;
            }
            queryParams.add([val, attribute]);
        }
    }

    return InsertQuery<Insertable>(queryBuilder.string, queryParams);
}