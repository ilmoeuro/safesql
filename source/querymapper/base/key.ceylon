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

"A wrapper class for values to be used as references.
 
 Use this as the type of primary/foreign keys on your model objects,
 so their reference types can be checked by the compiler. Defaults
 to using Integer as the wrapped field type, but other types can also be used.
 
 Example:

     table
     shared class Employee(id, company) {
         shared column Key<Employee>? id;
         shared column Key<Company> company;
     }
 
     table
     shared class Company(id, name) {
         shared column Key<Company>? id;
     }"
shared class Key<Target, Field=Integer>(field) extends Object()
        given Field satisfies Object {
    shared Field field;

    shared actual Boolean equals(Object that) {
        if (is Key<Target,Field> that) {
            return field == that.field;
        }
        else {
            return false;
        }
    }
    
    shared actual Integer hash => field.hash;
}

class CovariantKey<out Target = Anything, out Field=Object>(key)
        given Field satisfies Object {
    Key<Target, Field> key;

    shared Object field = key.field;
}