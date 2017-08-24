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

import safesql.backend {
    columnAnnotation,
    tableAnnotation,
    columnAttributes,
    defaultWhenAnnotation,
    primaryKeyAnnotation
}

abstract class SqlEmitter(Anything(String) emit) {
    shared formal void startIdentifier();
    shared formal void endIdentifier();
    
    shared void bareColumnName(Attribute<> attribute) {
        value decl = attribute.declaration;
        value annotation = columnAnnotation(attribute);
        startIdentifier();
        emit(annotation.nullableName else decl.name);
        endIdentifier();
    }

    shared void columnName(CovariantColumn<> column) {
        startIdentifier();
        emit(column.table.name);
        endIdentifier();
        emit(".");
        bareColumnName(column.attribute);
    }
    
    shared void qualifiedColumnAlias(CovariantColumn<> column) {
        value attribute = column.attribute;
        value decl = attribute.declaration;
        value annotation = columnAnnotation(attribute);

        emit(column.table.name);
        emit(".");
        emit(annotation.nullableName else decl.name);
    }

    shared void bareTableName(Class<> table) {
        value decl = table.declaration;
        value annotation = tableAnnotation(table);
        startIdentifier();
        if (annotation.name != "") {
            emit(annotation.name);
        } else {
            emit(decl.name);
        }
        endIdentifier();
    }
    
    shared void tableName(Table<> table) {
        bareTableName(table.cls);
        emit(" AS ");
        startIdentifier();
        emit(table.name);
        endIdentifier();
    }
    
    void columnList(Table<> table) {
        for (i -> attribute in columnAttributes(table.cls).indexed) {
            if (i != 0) {
                emit(",");
            }

            startIdentifier();
            emit(table.name);
            endIdentifier();
            emit(".");
            bareColumnName(attribute);
            emit(" AS ");
            startIdentifier();
            value column = CovariantColumn.fromValues(table, attribute);
            qualifiedColumnAlias(column);
            endIdentifier();
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
            
            switch (ordering)
            case (is ColumnOrdering<>) {
                columnName(ordering.column);
            }

            if (is Asc<> ordering) {
                emit(" ASC");
            }
            if (is Desc<> ordering) {
                emit(" DESC");
            }
        }
    }
    
    shared void insertInto(Class<> model) {
        emit("INSERT INTO ");
        bareTableName(model);

        emit("(");

        for (i -> attribute in columnAttributes(model).indexed) {
            if (i != 0) {
                emit(",");
            }
            bareColumnName(attribute);
        }

        emit(")");
    }
    
    shared void values(Class<> model) {
        emit(" VALUES (");

        for (i -> attribute in columnAttributes(model).indexed) {
            if (i != 0) {
                emit(",");
            }
            if (exists annotation = defaultWhenAnnotation(attribute),
                inserting in annotation.targets) {
                emit("DEFAULT");
            } else {
                emit("?");
            }
        }

        emit(")");
    }
    
    shared void updateOne(Class<> model) {
        emit("UPDATE ");
        bareTableName(model);

        emit(" SET ");
        value attributes = columnAttributes(model)
            .filter((attr) => !primaryKeyAnnotation(attr) exists);
        for (i -> attribute in attributes.indexed) {
            if (i != 0) {
                emit(",");
            }

            bareColumnName(attribute);
            emit("=");
            if (exists annotation = defaultWhenAnnotation(attribute),
                updating in annotation.targets) {
                emit("DEFAULT");
            } else {
                emit("?");
            }
        }
        
        emit(" WHERE ");
        value pkAttributes = columnAttributes(model)
            .filter((attr) => primaryKeyAnnotation(attr) exists)
            .sequence();
        "`` `function updateOne` `` requires exactly one \
         attribute annotated `` `function primaryKey` ``"
        assert (exists pkAttribute = pkAttributes[0]);
        bareColumnName(pkAttribute);
        emit("=?");
    }
}

class PgH2SqlEmitter(Anything(String) emit) extends SqlEmitter(emit) {
    shared actual void endIdentifier() {
        emit("\"");
    }

    shared actual void startIdentifier() {
        emit("\"");
    }
}

