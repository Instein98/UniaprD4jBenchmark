java8_home="/usr/lib/jvm/java-8-openjdk-amd64/jre/"
java7_home="/usr/lib/jvm/jdk1.7.0_80/"
d4j_mvn_proj_path="/home/yicheng/apr/d4jMvn/Projects/"
pwd=`pwd`

# 1st arg is file, 2nd arg is string
file_contains_string(){
    if grep -q "$2" $1; then
        true
    else
        false
    fi
}

for proj in `ls $d4j_mvn_proj_path`; do
    [ ! -d $d4j_mvn_proj_path/$proj ] && continue
    for id in `ls $d4j_mvn_proj_path/$proj`; do
        # there are some irrelevant file under $d4j_mvn_proj_path/$proj
        [ ! -d $d4j_mvn_proj_path/$proj/$id ] && continue
        
        echo === $proj-$id ===
        cd $d4j_mvn_proj_path/$proj/$id
        # if [ -f mvn-test-compile8.log ] && file_contains_string mvn-test-compile8.log "BUILD SUCCESS"; then
        #     echo [JDK8] mvn test-compile succeed!
        #     continue
        # fi
        JAVA_HOME=$java8_home mvn clean test-compile -l mvn-test-compile8.log
        if file_contains_string mvn-test-compile8.log "BUILD SUCCESS"; then
            echo [JDK8] mvn test-compile succeed!
        else
            echo [JDK8] mvn test-compile failed!
            JAVA_HOME=$java7_home mvn clean test-compile -l mvn-test-compile7.log
            if file_contains_string mvn-test-compile7.log "BUILD SUCCESS"; then
                echo [JDK7] mvn test-compile succeed!
            else
                echo [JDK7] mvn test-compile failed!
            fi
        fi

        echo
        cd $pwd
    done
done
