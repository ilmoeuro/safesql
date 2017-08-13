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
    ArrayList,
    MutableList
}

shared From<Source> from<Source>(
    Table<Source> source,
    {Join<Source>*} joins = {}
) => From(source, joins);

shared sealed class From<Source>(source, joins = {}) {
    Table<Source> source;
    {Join<Source>*} joins;
    
    shared Where<Source> where(condition) {
        Condition<Source>? condition;
        return Where(source, joins, condition);
    }
}

shared sealed class Where<Source>(source, joins, condition) {
    Table<Source> source;
    {Join<Source>*} joins;
    Condition<Source>? condition;
    
    shared OrderBy<Source> orderBy(ordering) {
        {Ordering<Source>+} ordering;
        return OrderBy(source, joins, condition, ordering);
    }

    shared Query select<Result>(Table<Result> columns)
            given Result satisfies Source {
        return selectQuery(columns, source, {}, condition);
    }
}

shared sealed class OrderBy<Source>(source, joins, condition, ordering) {
    Table<Source> source;
    {Join<Source>*} joins;
    Condition<Source>? condition;
    {Ordering<Source>+} ordering;
    
    shared Query select<Result>(Table<Result> columns)
            given Result satisfies Source {
        return selectQuery(columns, source, joins, condition, ordering);
    }
}

Query selectQuery<Result, Source>(
    columns,
    source,
    joins,
    condition = null,
    ordering = {}
) given Result satisfies Source {
    Table<Result> columns;
    Table<Source> source;
    {Join<Source>*} joins;
    Condition<Source>? condition;
    {Ordering<Source>*} ordering;
    
    value queryBuilder = StringBuilder();
    value queryParams = ArrayList<Anything>();
    value emitter = PgH2SqlEmitter(queryBuilder.append);

    emitter.select(columns);
    emitter.from(source);
    if (is {Join<Source>+} joins) {
        emitter.joins(joins);
    }
    if (exists condition) {
        emitter.where(condition);
        extractConditionParams(queryParams, condition);
    }
    if (is {Ordering<Source>+} ordering) {
        emitter.orderBy(ordering);
    }
    
    return Query(queryBuilder.string, queryParams);
}

void extractConditionParams<Source>(MutableList<Anything> result, Condition<Source> where) {
    switch (where) 
    case (is Compare<Source>) {
        variable Anything val = where.rhs;
        if (is Key<out Anything, out Object> key = val) {
            val = key.field;
        }
        result.add(val);
    }
    case (is BinaryCondition<Source>) {
        for (condition in where.conditions) {
            extractConditionParams(result, condition);
        }
    }
    case (is UnaryCondition<Source>) {
        extractConditionParams(result, where.inner);
    }
}