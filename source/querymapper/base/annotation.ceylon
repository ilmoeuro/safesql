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

import ceylon.language.meta.declaration {
    ValueDeclaration,
    ClassDeclaration,
    ConstructorDeclaration
}
import ceylon.language.meta.model {
    Model,
    Attribute,
    Class
}

"The annotation class for [[column]] annotation"
see(`function column`)
shared final annotation class ColumnAnnotation(name = "", insert = true)
    satisfies OptionalAnnotation<
        ColumnAnnotation,
        ValueDeclaration
> {
    shared String name;
    shared Boolean insert;
}

"The annotation to map an attribute to a database column.
 
 All attributes not annotated with this annotation are ignored when performing
 the database mapping. If you specify the `name` parameter, it will be used as
 the column name, otherwise the attribute name will be used as the column name."
shared annotation ColumnAnnotation column(
    "The name of the database column corresponding to the annotated attribute.
     If empty, the attribute name itself is used."
    String name = ""
)
        => ColumnAnnotation(name);

"The annotation class for [[table]] annotation."
see(`function table`)
shared final annotation class TableAnnotation(name = "")
    satisfies OptionalAnnotation<
        TableAnnotation,
        ClassDeclaration
> {
    shared String name;
}

"The annotation to map a class to a database table.
 
 Classes can't be used in queries if not annotated `table`. If you specify the
 `name` parameter, it will be used as the table name, otherwise the name of the
 class itself is used."
shared annotation TableAnnotation table(
    "The name of the database table corresponding to the annotated class.
     If empty, the class name itself is used."
    String name = ""
)
        => TableAnnotation(name);

"The annotation class for [[fromRow]] annotation."
see(`function fromRow`)
shared final annotation class FromRowAnnotation()
    satisfies OptionalAnnotation<
        FromRowAnnotation,
        ConstructorDeclaration
> {
}

"The annotation for the no-arg constructor that builds the object from a database row.
 
 If you want to retrieve objects using a [[from]] query, annotate one
 constructor with this annotation. The constructor should have no arguments; the
 values will be directly injected into attributes annotated with [[column]]. The
 constructor doesn't need to be shared. Instances of a class without a
 constructor annotated with this annotation **cannot be retrieved** using
 queries."
shared annotation FromRowAnnotation fromRow() => FromRowAnnotation();

AnnotationType annotationFor<AnnotationType>(Model target)
        given AnnotationType satisfies Annotation {
    value decl = target.declaration;
    value annotations = decl.annotations<AnnotationType>();
    value typeName = `AnnotationType`.string;
    "``target`` must be annotated with ``typeName``"
    assert(exists annotation = annotations.first);
    return annotation;
}

shared ColumnAnnotation columnAnnotation(Attribute<> attr) =>
        annotationFor<ColumnAnnotation>(attr);

shared TableAnnotation tableAnnotation(Class<> cls) =>
        annotationFor<TableAnnotation>(cls);
    
shared {Attribute<>*} columnAttributes(Class<> cls) {
    return cls
            .getAttributes<Nothing, Anything>(`ColumnAnnotation`)
            .sort((a1, a2) => a1.declaration.name <=> a2.declaration.name);
}
