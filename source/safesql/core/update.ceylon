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

import safesql.backend {
    tableAnnotation,
    columnAttributes,
    defaultWhenAnnotation,
    primaryKeyAnnotation
}

shared alias UpdateQueryParameter => [Attribute<>, Anything];

"An `UPDATE` query.
 
 Use [[updateOne]] to build instances of this class."
suppressWarnings("unusedDeclaration") // Updatable is a phantom type parameter
shared sealed class UpdateQuery<Updatable>(query, params) {
    shared String query(Dialect dialect);
    shared {UpdateQueryParameter*} params;

    string => "`` `class`.qualifiedName `` {
                   query(h2)=``query(Dialect.h2)``,
                   params=``params``
               }";
}

"Construct an `UPDATE` query that persists [[updatable]] to the database.
 
 [[Updatable]] **must** be a class, and annotated [[table]]. If specified, the
 attributes specified in [[fields]] are used as columns in the `UPDATE` query.
 If no attributes are specified, all the attributes annotated [[column]] are
 used. The actual values for the columns are retrieved from [[updatable]]. The
 function won't work if [[Updatable]] is something else than the actual type of
 [[updatable]] (for example, [[Object]])."
shared UpdateQuery<Updatable> updateOne<Updatable>(updatable, fields)
        given Updatable satisfies Object {
    "The object to be persisted to the database"
    Updatable updatable;
    "The attributes to be persisted as database columns. If no attributes are
     specified, all attributes annotated [[column]] are used."
    Attribute<Updatable>* fields;
    
    value queryBuilder = StringBuilder();
    value queryParams = ArrayList<UpdateQueryParameter>();
    value emitter = PgH2SqlEmitter(queryBuilder.append);

    "`` `function insertOne` `` expects a class type parameter, \
     given `` `Updatable` ``"
    assert (is Class<> type = `Updatable`);
    value attributes = columnAttributes(type);
    value fieldAttributes = if (fields.empty) then attributes else fields;

    emitter.updateOne(type, fieldAttributes);
    
    // check that `Insertable` is propery annotated
    tableAnnotation(type);
    
    for (attribute in fieldAttributes) {
        if (exists annotation = defaultWhenAnnotation(attribute),
            updating in annotation.targets) {
            continue;
        }
        
        if (exists annotation = primaryKeyAnnotation(attribute)) {
            continue;
        }

        variable Anything val = attribute.bind(updatable).get();
        queryParams.add([attribute, val]);
    }

    for (attribute in attributes) {
        if (exists annotation = primaryKeyAnnotation(attribute)) {
            variable Anything val = attribute.bind(updatable).get();
            queryParams.add([attribute, val]);
        }
    }

    return UpdateQuery<Updatable> {
        query(Dialect _) => queryBuilder.string;
        params = queryParams;
    };
}