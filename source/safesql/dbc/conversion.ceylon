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

import ceylon.dbc {
	SqlNull
}
import ceylon.language.meta.model {
	Attribute,
	Type,
	Class
}

import java.lang {
	JLong=Long,
	JDouble=Double,
	Types {
		nativeString
	}
}
import java.sql {
	SqlTypes=Types
}

import safesql.core {
	Key
}

Object toJdbcObject([Anything, Attribute<>] param) {
    value [source, attr] = param;
    if (!exists source) {
        // TODO more flexible SqlNulls (eg. varchar/text for Strings)
        if (attr.type == `Integer?`) {
            return SqlNull(SqlTypes.integer);
        }
        if (attr.type == `String?`) {
            return SqlNull(SqlTypes.varchar);
        }
        if (attr.type == `Float?`) {
            return SqlNull(SqlTypes.double);
        }
        if (attr.type.subtypeOf(`Key<out Anything, out Object>?`)) {
            return SqlNull(SqlTypes.integer);
        }
        return SqlNull(SqlTypes.binary);
    }
    if (is Integer source) {
        return JLong(source);
    }
    if (is Float source) {
        return JDouble(source);
    }
    if (is String source) {
        return nativeString(source);
    }
    if (is Key<out Object, out Object> source) {
        return toJdbcObject([source.field, attr]);
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