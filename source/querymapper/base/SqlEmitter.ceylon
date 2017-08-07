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

class SqlEmitter<Subject>(Anything(String) emit) {
    void bareColumnName(Attribute<> attribute) {
        value decl = attribute.declaration;
        value annotations = decl.annotations<ColumnAnnotation>();
        assert(exists annotation = annotations.first);
        emit("\"");
        if (annotation.name != "") {
            emit(annotation.name);
        } else {
            emit(decl.name);
        }
        emit("\"");
    }

    void columnName(Column<Subject> column) {
        if (is AliasedColumn<Subject> column) {
            emit("\"");
            emit(column.table.name);
            emit("\".");
            bareColumnName(column.attribute);
        }
        if (is BareColumn<Subject> column) {
            bareColumnName(column.attribute);
        }
    }

    void bareTableName(Class<Subject> table) {
        value decl = table.declaration;
        value annotations = decl.annotations<TableAnnotation>();
        assert(exists annotation = annotations.first);
        emit("\"");
        if (annotation.name != "") {
            emit(annotation.name);
        } else {
            emit(decl.name);
        }
        emit("\"");
    }
    
    void tableName(Table<Subject> table) {
        switch (table)
        case (is AliasedTable<Subject>) {
            bareTableName(table.cls);
            emit(" AS \"");
            emit(table.name);
            emit("\"");
        }
        case (is Class<Subject>) {
            bareTableName(table);
        }
    }
    
    void columnList(Table<Subject> table) {
        Class<Subject> cls;
        switch (table)
        case (is AliasedTable<Subject>) {
            cls = table.cls;
        }
        case (is Class<Subject>) {
            cls = table;
        }
        value attrs = cls.getAttributes<Anything, Anything>(`ColumnAnnotation`);
        for (i -> attribute in attrs.indexed) {
            if (i != 0) {
                emit(",");
            }

            switch (table)
            case (is AliasedTable<Subject>) {
                columnName(table.column(attribute));
            }
            case (is Class<Subject>) {
                bareColumnName(attribute);
            }
        }
    }
    
    void tableList(Table<Subject> table) {
        tableName(table);
    }

    void condition(Condition<Subject> where) {
        switch (where) 
        case (is Compare<Subject>) {
            columnName(where.lhs);
            switch (where)
            case (is Equal<Subject>)       { emit("=");  }
            case (is LessThan<Subject>)    { emit("<");  }
            case (is AtMost<Subject>)      { emit("<="); }
            case (is GreaterThan<Subject>) { emit(">");  }
            case (is AtLeast<Subject>)     { emit(">="); }
            emit("?");
        }
        case (is And<Subject>) {
            emit("(");
            condition(where.left);
            emit(") AND (");
            condition(where.right);
            emit(")");
        }
        case (is Or<Subject>) {
            emit("(");
            condition(where.left);
            emit(") OR (");
            condition(where.right);
            emit(")");
        }
        case (is Not<Subject>) {
            emit("NOT (");
            condition(where.inner);
            emit(")");
        }
    }

    shared void select(Table<Subject> cls) {
        emit("SELECT ");
        columnList(cls);
    }
    
    shared void from(Table<Subject> cls) {
        emit(" FROM ");
        tableList(cls);
    }
    
    shared void where(Condition<Subject> where) {
        emit(" WHERE ");
        condition(where);
    }
    
    shared void orderBy({Ordering<Subject>+} orderings) {
        emit(" ORDER BY ");
        
        for (i -> ordering in orderings.indexed) {
            if (i != 0) {
                emit(",");
            }
            
            columnName(ordering.column);
            if (is Asc<Subject> ordering) {
                emit(" ASC");
            }
            if (is Desc<Subject> ordering) {
                emit(" DESC");
            }
        }
    }
}