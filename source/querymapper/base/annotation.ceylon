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
    ClassDeclaration
}

"The annotation class for [[column]] annotation"
see(`function column`)
shared final annotation class ColumnAnnotation(name = "")
    satisfies OptionalAnnotation<
        ColumnAnnotation,
        ValueDeclaration
> {
    shared String name;
}

"The annotation to mark an attribute as a database column.
 
 All class attributes that are not annotated as columns are ignored. If you
 specify the `name` parameter, it will be used as the column name, otherwise
 the attribute name will be used as the column name."
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

"The annotation to mark a class as a database table.
 
 Classes can't be used in queries if not annotated `table`. If you specify
 the `name` parameter, it will be used as the table name, otherwise the
 name of the class itself is used."
shared annotation TableAnnotation table(
    "The name of the database table corresponding to the annotated class.
     If empty, the class name itself is used."
    String name = ""
)
        => TableAnnotation(name);