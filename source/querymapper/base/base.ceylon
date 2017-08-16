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
    Class,
    Attribute
}

import querymapper.backend {
    columnAnnotation,
    tableAnnotation
}

"An aliased database table to be used in queries.
 
 All table names are aliased. The aliases are not generated or checked in
 compile time, so keeping them unique is the responsibility of the developer.
 Each table is mapped to one or more classes. If you want multiple projections
 for a table, you can create multiple classes that map to the same table name.
 
 Typical usage:
 
     value employees = Table(\"employees\", `Employee`);
     
     from(employees)
     .where(/* a condition involving employees */)
     .select(employees);
 
 "
shared final class Table<out Source=Anything>(name, cls) {
    "The name of the alias. **Not** statically checked for collisions. **Must
     not** include '.' characters."
    shared String name;
    "The mapped class. **Must** be annotated with [[querymapper.base::table]]."
    shared Class<Source> cls;
    
    "No '.' characters allowed in alias names."
    assert (!("." in name));
    
    // Check that `cls` is properly annotated
    tableAnnotation(cls);
    
    "The [[Column]] object attached to this table, mapped to an attribute
     of the mapped class."
    shared Column<Source, Field> column<Field>(
        "The attribute the column maps to. **Must** be annotated with
         [[querymapper.base::column]]."
        Attribute<Source, Field> attribute
    ) {
        // Check that `attribute` is properly annotated
        columnAnnotation(attribute);

        return Column(this, attribute);
    }
}

"An aliased database column to be used in queries.
 
 All column names are based on [[Table]] aliases - there is no bare columns.
 The class is [[sealed]], so names can only be created using the
 [[Table.column]] method.
 
 Typical usage:
 
     value employees = Table(\"employees\", `Employee`);
     value name = employees.column(`Employee.name`);
     
 "
shared sealed class Column<out Source=Anything, Field = Anything>(table, attribute) {
    "The table this column belongs to."
    shared Table<Source> table;
    "The attribute that this column is mapped to."
    shared Attribute<Nothing, Field> attribute;
}

shared interface Row<EntityType> {
    shared formal ValueType get<ValueType>(
        Attribute<EntityType, ValueType> attr
    );
}

class CovariantColumn<out Source=Anything, out Field = Anything> {
    shared Table<Source> table;
    shared Attribute<Nothing, Field> attribute;
    
    shared new(Column<Source, Field> column) {
        table = column.table;
        attribute = column.attribute;
    }
    
    shared new fromValues(table, attribute) {
        Table<Source> table;
        Attribute<Nothing, Field> attribute;
        this.table = table;
        this.attribute = attribute;
    }
}