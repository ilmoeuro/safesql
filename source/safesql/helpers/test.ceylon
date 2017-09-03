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

import ceylon.test {
    test
}

class OneField(fieldValue) extends Object() {
    shared String? fieldValue;
    
    equals(Object that) => metamodelEquals(this, that, `fieldValue`);
    hash => compositeHash(fieldValue);
    string => metamodelString(this, `fieldValue`);
}

class MultipleFields(fieldValue1, fieldValue2) extends Object() {
    shared String? fieldValue1;
    shared String? fieldValue2;

    equals(Object that) => metamodelEquals(this, that, `fieldValue1`, `fieldValue2`);
    hash => compositeHash(fieldValue1, fieldValue2);
    string => metamodelString(this, `fieldValue1`, `fieldValue2`);
}

class CollectionField(fieldValue) extends Object() {
    shared [Anything*] fieldValue;

    equals(Object that) => metamodelEquals(this, that, `fieldValue`);
    hash => compositeHash(fieldValue);
    string => metamodelString(this, `fieldValue`);
}

test
void testEqualsOneField() {
    value me = OneField("test");
    value it = OneField("test");
    assert(me == it);
}

test
void testNotEqualsOneField() {
    value me = OneField("test");
    value it = OneField("not test");
    assert(me != it);
}

test
void testEqualsOneFieldNull() {
    value me = OneField(null);
    value it = OneField(null);
    assert(me == it);
}

test
void testNotEqualsOneFieldNull() {
    value me = OneField("test");
    value it = OneField(null);
    assert(me != it);
}

test
void testEqualsMultipleFields() {
    value me = MultipleFields("test1", "test2");
    value it = MultipleFields("test1", "test2");
    assert(me == it);
}

test
void testEqualsMultipleFieldsNull() {
    value me = MultipleFields("test1", null);
    value it = MultipleFields("test1", null);
    assert(me == it);
}

test
void testNotEqualsMultipleFields() {
    value me = MultipleFields("test1", "test2");
    value it = MultipleFields("test2", "test1");
    assert(me != it);
}

test
void testNotEqualsMultipleFieldsNull() {
    value me = MultipleFields("test1", null);
    value it = MultipleFields(null, "test2");
    assert(me != it);
}

test
void testEqualsCollectionField() {
    value me = CollectionField([1, 2, 3]);
    value it = CollectionField([1, 2, 3]);
    assert (me == it);
}

test
void testNotEqualsCollectionField() {
    value me = CollectionField([1, 2, 3]);
    value it = CollectionField([4, 5, 6]);
    assert (me != it);
}

test
void testStructuralEqualsOneField() {
    value me = OneField("test");
    value it = OneField("test");
    assert(structuralEquals(me, it, OneField.fieldValue));
}

test
void testNotStructuralEqualsOneField() {
    value me = OneField("test");
    value it = OneField("not test");
    assert(!structuralEquals(me, it, OneField.fieldValue));
}

test
void testStructuralEqualsOneFieldNull() {
    value me = OneField(null);
    value it = OneField(null);
    assert(structuralEquals(me, it, OneField.fieldValue));
}

test
void testNotStructuralEqualsOneFieldNull() {
    value me = OneField("test");
    value it = OneField(null);
    assert(!structuralEquals(me, it, OneField.fieldValue));
}

test
void testStructuralEqualsMultipleFields() {
    value me = MultipleFields("test1", "test2");
    value it = MultipleFields("test1", "test2");
    assert(structuralEquals(
        me,
        it,
        MultipleFields.fieldValue1,
        MultipleFields.fieldValue2
    ));
}

test
void testStructuralEqualsMultipleFieldsNull() {
    value me = MultipleFields("test1", null);
    value it = MultipleFields("test1", null);
    assert(structuralEquals(
        me,
        it,
        MultipleFields.fieldValue1,
        MultipleFields.fieldValue2
    ));
}

test
void testNotStructuralEqualsMultipleFields() {
    value me = MultipleFields("test1", "test2");
    value it = MultipleFields("test2", "test1");
    assert(!structuralEquals(
        me,
        it,
        MultipleFields.fieldValue1,
        MultipleFields.fieldValue2
    ));
}

test
void testNotStructuralEqualsMultipleFieldsNull() {
    value me = MultipleFields("test1", null);
    value it = MultipleFields(null, "test2");
    assert(!structuralEquals(
        me,
        it,
        MultipleFields.fieldValue1,
        MultipleFields.fieldValue2
    ));
}

test
void testStructuralEqualsCollectionField() {
    value me = CollectionField([1, 2, 3]);
    value it = CollectionField([1, 2, 3]);
    assert(structuralEquals(me, it, CollectionField.fieldValue));
}

test
void testNotStructuralEqualsCollectionField() {
    value me = CollectionField([1, 2, 3]);
    value it = CollectionField([4, 5, 6]);
    assert(!structuralEquals(me, it, CollectionField.fieldValue));
}

test
void testHashOneField() {
    value me = OneField("test");
    value it = OneField("test");
    assert(me.hash == it.hash);
}

test
void testNotHashOneField() {
    value me = OneField("test");
    value it = OneField("not test");
    assert(me.hash != it.hash);
}

test
void testHashOneFieldNull() {
    value me = OneField(null);
    value it = OneField(null);
    assert(me.hash == it.hash);
}

test
void testNotHashOneFieldNull() {
    value me = OneField("test");
    value it = OneField(null);
    assert(me.hash != it.hash);
}

test
void testHashMultipleFields() {
    value me = MultipleFields("test1", "test2");
    value it = MultipleFields("test1", "test2");
    assert(me.hash == it.hash);
}

test
void testHashMultipleFieldsNull() {
    value me = MultipleFields("test1", null);
    value it = MultipleFields("test1", null);
    assert(me.hash == it.hash);
}

test
void testNotHashMultipleFields() {
    value me = MultipleFields("test1", "test2");
    value it = MultipleFields("test2", "test1");
    assert(me.hash != it.hash);
}

test
void testNotHashMultipleFieldsNull() {
    value me = MultipleFields("test1", null);
    value it = MultipleFields(null, "test2");
    assert(me.hash != it.hash);
}

test
void testStringOneField() {
    value me = OneField("test");
    value expected = "safesql.helpers::OneField{fieldValue=test;}";
    value actual = me.string;
    assert(expected == actual);
}

test
void testStringOneFieldNull() {
    value me = OneField(null);
    value expected = "safesql.helpers::OneField{fieldValue=<null>;}";
    value actual = me.string;
    assert(expected == actual);
}

test
void testStringMultipleFields() {
    value me = MultipleFields("test1", "test2");
    value expected = "safesql.helpers::MultipleFields{fieldValue1=test1;fieldValue2=test2;}";
    value actual = me.string;
    assert(expected == actual);
}