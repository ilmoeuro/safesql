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

import java.sql {
    Types
}
import safesql.core {
    Key
}
import java.lang {
    JLong=Long,
    JDouble=Double
}
import ceylon.interop.java {
    javaString
}
import ceylon.language.meta.model {
    Attribute,
    Type,
    Class
}
import ceylon.dbc {
    SqlNull
}

Object toJdbcObject([Anything, Attribute<>] param) {
    value [source, attr] = param;
    if (!exists source) {
        // TODO more flexible SqlNulls (eg. varchar/text for Strings)
        if (attr.type == `Integer?`) {
            return SqlNull(Types.integer);
        }
        if (attr.type == `String?`) {
            return SqlNull(Types.varchar);
        }
        if (attr.type == `Float?`) {
            return SqlNull(Types.double);
        }
        if (attr.type.subtypeOf(`Key<out Anything, out Object>?`)) {
            return SqlNull(Types.integer);
        }
        return SqlNull(Types.binary);
    }
    if (is Integer source) {
        return JLong(source);
    }
    if (is Float source) {
        return JDouble(source);
    }
    if (is String source) {
        return javaString(source);
    }
    return source;
}

Anything fromJdbcObject(Object source, Type<Anything> type) {
    if (is SqlNull source) {
        return null;
    }
    if (is Class<Key<out Anything, out Object>> type) {
        return type.apply(source);
    }
    return source;
}