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

"Project goals:
 
  - Type safety
  - Full power of a subset of SQL common to popular DB's
  - Non-invasiveness
  - Cooperation with existing database connections (ceylon.dbc &c)
  
  Non-goals:
  
  - Synchronizing object graphs between DB and memory
  - Minimal amount of code
  - Magic, including manipulating objects' internal state
"
by("Ilmo Euro <ilmo.euro@gmail.com>")
license("[ASL 2.0](http://www.apache.org/licenses/LICENSE-2.0.html)")
module safesql.core "1.0.0" {
    import ceylon.collection "1.3.3";
    import safesql.backend "1.0.0";
}
