import ceylon.language.meta.declaration {
    ValueDeclaration,
    ClassDeclaration,
    CallableConstructorDeclaration
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
    
    shared String? nullableName => if (name != "") then name else null;
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
        CallableConstructorDeclaration
> {
}

"The annotation for the no-arg constructor that builds the object from a database row.
 
 If you want to retrieve objects using a [[from]] query, annotate one
 constructor with this annotation. The constructor **must** have one argument, a
 [[Row]], parametrized with the annotated class. Instances of a class without a
 constructor annotated with this annotation **cannot be retrieved** using
 queries.
 
 Use the [[Row]] argument to retrieve the attribute values, like this:

 ~~~
 table
 shared class Employee {
     column
     shared Key<Employee> id;
 
     column
     shared String name;

     suppressWarnings(\"unusedDeclaration\")
     fromRow
     new fromRow(Row<Employee> row) {
         id = row.get(`id`);
         name = row.get(`name`);
     }
 }
 ~~~
 "
shared annotation FromRowAnnotation fromRow() => FromRowAnnotation();