

compile0.log is the original log when nothing is fixed yet.

## Fixes

### Closure

#### Could not find artifact rhino:rhino:jar:1.1 in central
`cp -r Repository/* ~/.m2/repository/`

### Lang
#### Compilation failure

change
```xml
<maven.compile.source>1.6</maven.compile.source>
<maven.compile.target>1.6</maven.compile.target>
```
to
```xml
<maven.compile.source>1.8</maven.compile.source>
<maven.compile.target>1.8</maven.compile.target>
```
by
```shell
sed -i 's/<\(maven.compile.source\)>.*<\/\1>/<\1>1.8<\/\1>/' pom.xml
sed -i 's/<\(maven.compile.target\)>.*<\/\1>/<\1>1.8<\/\1>/' pom.xml
```
