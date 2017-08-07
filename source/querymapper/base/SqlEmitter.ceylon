import ceylon.language.meta.model {
    Class,
    Attribute
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

class SqlEmitter(Anything(String) emit) {
    void bareColumnName(Attribute<> column) {
        value decl = column.declaration;
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

    void columnName(Column column) {
        if (is AliasedColumn column) {
            emit("\"");
            emit(column.table.name);
            emit("\".");
            bareColumnName(column.attribute);
        }
        if (is Attribute<> column) {
            bareColumnName(column);
        }
    }

    void bareTableName(Class<> table) {
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
    
    void tableName(Table table) {
        switch (table)
        case (is AliasedTable) {
            bareTableName(table.cls);
            emit(" AS \"");
            emit(table.name);
            emit("\"");
        }
        case (is Class<>) {
            bareTableName(table);
        }
    }
    
    void columnList(Table table) {
        Class<> cls;
        switch (table)
        case (is AliasedTable) {
            cls = table.cls;
        }
        case (is Class<>) {
            cls = table;
        }
        value attributes = cls.getAttributes<>(`ColumnAnnotation`);
        for (i -> attribute in attributes.indexed) {
            if (i != 0) {
                emit(",");
            }

            switch (table)
            case (is AliasedTable) {
                columnName(table.column(attribute));
            }
            case (is Class<>) {
                columnName(attribute);
            }
        }
    }
    
    void tableList(Table table) {
        tableName(table);
    }

    void condition(Condition where) {
        switch (where) 
        case (is Equal | LessThan | AtMost | GreaterThan | AtLeast) {
            columnName(where.lhs);
            switch (where)
            case (is Equal) { emit("=");  }
            case (is LessThan) { emit("<");  }
            case (is AtMost) { emit("<="); }
            case (is GreaterThan) { emit(">");  }
            case (is AtLeast) { emit(">="); }
            emit("?");
        }
        case (is And) {
            emit("(");
            condition(where.left);
            emit(") AND (");
            condition(where.right);
            emit(")");
        }
        case (is Or) {
            emit("(");
            condition(where.left);
            emit(") OR (");
            condition(where.right);
            emit(")");
        }
        case (is Not) {
            emit("NOT (");
            condition(where.inner);
            emit(")");
        }
    }

    shared void select(Table cls) {
        emit("SELECT ");
        columnList(cls);
    }
    
    shared void from(Table cls) {
        emit(" FROM ");
        tableList(cls);
    }
    
    shared void where(Condition where) {
        emit(" WHERE ");
        condition(where);
    }
    
    shared void orderBy({Ordering+} orderings) {
        emit(" ORDER BY ");
        
        for (i -> ordering in orderings.indexed) {
            if (i != 0) {
                emit(",");
            }
            
            columnName(ordering.column);
            if (is Asc ordering) {
                emit(" ASC");
            }
            if (is Desc ordering) {
                emit(" DESC");
            }
        }
    }
}