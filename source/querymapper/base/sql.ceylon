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

class SqlEmitter(Anything(String) emit) {
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

    void columnName(Column<> column) {
        emit("\"");
        emit(column.table.name);
        emit("\".");
        bareColumnName(column.attribute);
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
    
    void tableName(Table<> table) {
        bareTableName(table.cls);
        emit(" AS \"");
        emit(table.name);
        emit("\"");
    }
    
    void columnList(Table<> table) {
        value attrs = table.cls.getAttributes<Nothing, Anything>(`ColumnAnnotation`);
        for (i -> attribute in attrs.indexed) {
            if (i != 0) {
                emit(",");
            }

            emit("\"");
            emit(table.name);
            emit("\".");
            bareColumnName(attribute);
        }
    }

    void condition(Condition<> where) {
        switch (where) 
        case (is Compare<>) {
            columnName(where.lhs);
            emit(
                switch (where)
                case (is Equal<>)       "="
                case (is LessThan<>)    "<"
                case (is AtMost<>)      "<="
                case (is GreaterThan<>) ">"
                case (is AtLeast<>)     ">="
            );
            emit("?");
        }
        case (is And<>) {
            emit("(");
            for (i -> cond in where.conditions.indexed) {
                if (i != 0) {
                    emit(") AND (");
                }
                condition(cond);
            }
            emit(")");
        }
        case (is Or<>) {
            emit("(");
            for (i -> cond in where.conditions.indexed) {
                if (i != 0) {
                    emit(") OR (");
                }
                condition(cond);
            }
            emit(")");
        }
        case (is Not<>) {
            emit("NOT (");
            condition(where.inner);
            emit(")");
        }
    }

    shared void select(Table<> table) {
        emit("SELECT ");
        columnList(table);
    }
    
    shared void from(Table<> table) {
        emit(" FROM ");
        tableName(table);
    }
    
    shared void joins({Join<>+} joins) {
        for (i -> join in joins.indexed) {
            emit(" ");
            emit(
                switch (join)
                case (is InnerJoin<>)       "INNER JOIN "
                case (is LeftJoin<>)        "LEFT JOIN "
                case (is RightJoin<>)       "RIGHT JOIN "
                case (is CrossJoin<>)       "CROSS JOIN "
            );
            tableName(join.table);
            if (is KeyedJoin<> join) {
                emit(" ON ");
                columnName(join.leftKey);
                emit("=");
                columnName(join.rightKey);
            }
        }
    }
    
    shared void where(Condition<> where) {
        emit(" WHERE ");
        condition(where);
    }
    
    shared void orderBy({Ordering<>+} orderings) {
        emit(" ORDER BY ");
        
        for (i -> ordering in orderings.indexed) {
            if (i != 0) {
                emit(",");
            }
            
            columnName(ordering.column);
            if (is Asc<> ordering) {
                emit(" ASC");
            }
            if (is Desc<> ordering) {
                emit(" DESC");
            }
        }
    }
}