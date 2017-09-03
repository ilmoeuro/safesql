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
    Attribute
}

"Determine if two objects are of compatible types and have equal attribute values. Returns
 [[true]] if:
 
  - [[me]] and [[it]] are of the same type
  - Each getter in [[getters]] produce equal values for both [[me]] and [[it]], or both
    produce `null`.
 
 This function is meant to be used as the implementation for [[Object.equals]], like this:
 
 ~~~
 class MyClass() {
     // ...
     equals(Object that) => structuralEquals(this, that, MyClass.attr1, MyClass.attr2);
     // ...
 }
 ~~~"
shared Boolean structuralEquals<T>(me, it, getters) {
    "The reference object for equality comparison"
    T me;
    "The object to compare to the reference object"
    Object it;
    "The getters for attribute values that are used in equality comparison."
    Anything(T)+ getters;
    if (is T it) {
        for (getter in getters) {
            Anything mine = getter(me);
            Anything its = getter(it);
            if (exists mine, exists its, mine != its) {
                return false;
            }
            if (exists mine, !exists its) {
                return false;
            }
            if (!exists mine, exists its) {
                return false;
            }
        }
        return true;
    } else {
        return false;
    }
}

"Use the metamodel to determine if two objects are of compatible types and have equal
 attribute values. Returns [[true]] if:
 
  - [[me]] and [[it]] are of the same type
  - Each attribute in [[attrs]] has equal values for both [[me]] and [[it]], or both
    values are `null`.
 
 This function is meant to be used as the implementation for [[Object.equals]], like this:
 
 ~~~
 equals(Object that) => reflectionEquals(this, that, `attr1`, `attr2`);
 ~~~"
shared Boolean metamodelEquals<T>(me, it, attrs) {
    "The reference object for equality comparison"
    T me;
    "The object to compare to the reference object"
    Object it;
    "The attribute values that are used in equality comparison."
    Attribute<T>+ attrs;
    
    function toGetter(Attribute<T> attr) {
        return (T obj) => attr.bind(obj).get();
    }
    
    return structuralEquals(me, it, *attrs.map(toGetter));
}

"Calculate a combined hash for [[values]]. [[null]]s are hashed as 0.
 
 This function is meant to be used as the implementation for [[Object.hash]], like this:
 
 ~~~
 hash => compositeHash(attr1, attr2, attr3);
 ~~~"
shared Integer compositeHash(Anything+ values) {
    variable Integer result = 1;
    for (val in values) {
        result = result*31 + (val?.hash else 0);
    }
    return result;
}

"Use the metamodel to construct a developer-friendly string representation of an instance.
 The string is constructed from the fully qualified name of [[T]] and the name-value pairs
 of [[attrs]], in the following form:
 
 ~~~
 moduleName::T{attr1=value1;attr2=value2;attr3=value3;}
 ~~~
 
 This function is meant to be used as the implementation for [[Object.string]], like this:
 
 ~~~
 string => reflectionString(this, `attr1`, `attr2`, `attr3`);
 ~~~"
shared String metamodelString<T>(T me, Attribute<T>+ attrs) {
    value result = StringBuilder();
    result.append(`T`.string);
    result.append("{");
    for (attr in attrs) {
        result.append(attr.declaration.name);
        result.append("=");
        result.append(attr.bind(me).get()?.string else "<null>");
        result.append(";");
    }
    result.append("}");
    return result.string;
}