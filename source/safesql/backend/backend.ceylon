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

import ceylon.language.meta.model {
    Model,
    Attribute,
    Class
}

import safesql.core {
    ColumnAnnotation,
    column,
    TableAnnotation,
    table,
    Column,
    DefaultWhenAnnotation,
    defaultWhen,
    Row,
    PrimaryKeyAnnotation,
    primaryKey
}

AnnotationType annotationFor<AnnotationType>(target, annotationName)
        given AnnotationType satisfies Annotation {
    Model target;
    String annotationName;
    "``target`` must be annotated with ``annotationName``"
    assert(exists annotation = optionalAnnotationFor<AnnotationType>(target));
    return annotation;
}

AnnotationType? optionalAnnotationFor<AnnotationType>(target)
        given AnnotationType satisfies Annotation {
    Model target;
    value decl = target.declaration;
    value annotations = decl.annotations<AnnotationType>();
    return annotations.first;
}

"Look up the [[column]] annotation of the given attribute, or throw an error
 if one doesn't exist."
shared ColumnAnnotation columnAnnotation(Attribute<> attr) =>
        annotationFor<ColumnAnnotation>(attr, `function column`.qualifiedName);

"Look up the [[table]] annotation of the given class, or throw an error
 if one doesn't exist."
shared TableAnnotation tableAnnotation(Class<> cls) =>
        annotationFor<TableAnnotation>(cls, `function table`.qualifiedName);

"Look up the [[defaultWhen]] annotation of the given attribute."
shared DefaultWhenAnnotation? defaultWhenAnnotation(Attribute<> attr) =>
        optionalAnnotationFor<DefaultWhenAnnotation>(attr);

"Look up the [[primaryKey]] annotation of the given attribute."
shared PrimaryKeyAnnotation? primaryKeyAnnotation(Attribute<> attr) =>
        optionalAnnotationFor<PrimaryKeyAnnotation>(attr);

"Find all the attributes of the class that are annotated with [[column]],
 in alphabetical order."
shared {Attribute<>*} columnAttributes(Class<> cls) {
    return cls
            .getAttributes<Nothing, Anything>(`ColumnAnnotation`)
            .sort((a1, a2) => a1.declaration.name <=> a2.declaration.name);
}

shared class RowImpl<EntityType>(values) satisfies Row<EntityType> {
    Map<Attribute<>, Anything> values;
    
    shared actual ValueType get<ValueType>(attr) {
        Attribute<EntityType, ValueType> attr;
        
        "The returned database row contains a value of wrong type"
        assert (is ValueType result = values[attr]);
        return result;
    }
}

shared String qualifiedColumnAlias<Source, Field>(Column<Source, Field> col) {
    value attr = col.attribute;
    value decl = attr.declaration;
    value tableName = col.table.name;
    value annotation = columnAnnotation(col.attribute);
    value columnName = annotation.nullableName else decl.name;
    return "``tableName``.``columnName``";
}