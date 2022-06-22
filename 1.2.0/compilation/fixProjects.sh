pluginForMockito="  <plugin>\n    <groupId>org.codehaus.mojo</groupId>\n    <artifactId>build-helper-maven-plugin</artifactId>\n    <version>3.2.0</version>\n    <executions>\n        <execution>\n        <id>add-source</id>\n        <phase>generate-sources</phase>\n        <goals>\n          <goal>add-source</goal>\n        </goals>\n        <configuration>\n          <sources>\n            <source>mockmaker/bytebuddy/main/java</source>\n          </sources>\n        </configuration>\n      </execution>\n      <execution>\n        <id>add-test-source</id>\n        <phase>generate-test-sources</phase>\n        <goals>\n          <goal>add-test-source</goal>\n        </goals>\n        <configuration>\n          <sources>\n            <source>mockmaker/bytebuddy/test/java</source>\n          </sources>\n        </configuration>\n      </execution>\n    </executions>\n  </plugin>"

profileForLang="    <profile>\n      <id>8</id>\n      <activation>\n        <jdk>1.8</jdk>\n      </activation>\n      <properties>\n        <maven.compile.source>1.8</maven.compile.source>\n        <maven.compile.target>1.8</maven.compile.target>\n      </properties>\n    </profile>"

profileForMath="  <profiles>  \n    <profile>\n      <id>8</id>\n      <activation>\n        <jdk>1.8</jdk>\n      </activation>\n      <properties>\n        <commons.jacoco.version>0.8.4</commons.jacoco.version>\n      </properties>\n    </profile>\n  </profiles>"

d4j_mvn_proj_path="/home/yicheng/apr/d4jMvn/Projects/"
pwd=`pwd`

# add caja to Repository (caja is not in the Repository directory of D4J_Maven)
mkdir -p ~/.m2/repository/caja/caja/r4314/
cp $d4j_mvn_proj_path/Closure/1/lib/caja-r4314.jar ~/.m2/repository/caja/caja/r4314/

for proj in `ls $d4j_mvn_proj_path`; do
    [ ! -d $d4j_mvn_proj_path/$proj ] && continue
    for idx in `ls $d4j_mvn_proj_path/"$proj"`; do
        [ ! -d $d4j_mvn_proj_path/$proj/$idx ] && continue

        tmp=$d4j_mvn_proj_path/$proj/$idx
        [ ! -f $tmp/pom.xml.bak ] && cp $tmp/pom.xml $tmp/pom.xml.bak
        # recover the pom in case it is already fixed before
        cp $tmp/pom.xml.bak $tmp/pom.xml

        if [ "$proj" = 'Lang' ]; then
            echo Fixing $proj-$idx
            cd $d4j_mvn_proj_path/"$proj"/$idx
            sed -i "s,<profiles>,&\n$profileForLang," pom.xml
            cd $pwd
        elif [ "$proj" = 'Math' ]; then
            echo Fixing $proj-$idx
            cd $d4j_mvn_proj_path/"$proj"/$idx
            sed -i "s,<build>,$profileForMath\n\n&," pom.xml
            cd $pwd
        elif [ "$proj" = 'Mockito' ]; then
            if [[ $idx -ne 1 && $idx -ne 3 && $idx -ne 18 && $idx -ne 19 && $idx -ne 38 ]]; then
                continue
            fi
            echo Fixing $proj-$idx
            cd $d4j_mvn_proj_path/"$proj"/$idx
            sed -i "s,<plugins>,&\n$pluginForMockito," pom.xml
            if [ $idx -eq 38 ]; then
                sed -i 's_<version>1.0-own</version>_&\n      <scope>system</scope>\n      <systemPath>${project.basedir}/lib/build/jarjar-1.0.jar</systemPath>_g' pom.xml
            fi
            cd $pwd
        else
            break
        fi
    done
done
