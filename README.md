### Cli
All is consistent

### Codec
Parameterized Test `[]`

### Collection
Weird all_tests file. Affects Collections 25-28

In pom.xml of 26/27: `<maven.compiler.source>1.6</maven.compiler.source>`
Keep this 1.6 and compile with JDK 7, then run uniapr with JDK 8 works fine.

### Compress
Parameterized Test `[]`

### Csv
Parameterized Test `[]`; Test result inconsistency
csv-15/16 will prevent print to stderr. Because of its "try-with-resources" style, System.out will be closed.
Run `patch -p1 < CSVPrinterTest.patch` for them.

### Gson
Gson-1 does not have a pom.xml file. Copy one from Gson-2.
Gson-1 needs TZ=America/Los_Angeles to be consistent
Gson 6-18. Uniapr seems doesn't support multimodule projects. A walkaround is to make the submodules in herit the same parent with its original parent.

### JacksonCore
Parameterized Test `[]`; Test result inconsistency (ignored).

### JacksonDatabind
Test result inconsistency. Fixed in https://github.com/ise-uiuc/uniapr/commit/089abf9b54f281730c8618afee935adf53348e83

### Jsoup
Test result inconsistency. Connection refuse issue. Fixed its source code.

### Others
Parameterized Test issues are fixed in https://github.com/ise-uiuc/uniapr/commit/510f5550b228119d9e419864405d3402ad19bce5

