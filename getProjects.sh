java8_home="/usr/lib/jvm/java-8-openjdk-amd64/jre"
java7_home="/usr/local/java/jdk1.7.0_80/"
# path of the repository of prapr_data (git@github.com:claudeyj/prapr_data.git)
prapr_data_path="/home/yicheng/research/apr/experiments/uniapr-consistency/prapr_data"

pwd=`pwd`

# 1st arg is file, 2nd arg is string
file_contains_string(){
    if grep -q "$2" $1; then
        true
    else
        false
    fi
}

prepare_projects(){
    if [ ! -d projects_2.0 ]; then
        mkdir projects_2.0
        if [ ! -d $prapr_data_path ]; then
            git clone git@github.com:claudeyj/prapr_data.git
            cd prapr_data
        else 
            cd $prapr_data_path
        fi
        git reset --hard be9ababc95df45fd66574c6af01122ed9df3db5d
        cd Projects
        cp -r Cli Codec Collections Compress Csv Gson JacksonCore JacksonDatabind JacksonXml Jsoup JxPath $pwd/projects_2.0
        cd $pwd
    fi
}

prepare_projects

# remove deprecated bug
rm -rf $pwd/projects_2.0/Cli/6

# fix Gson/Jsoup/Csv
for proj in `ls projects_2.0`; do
    for id in `ls projects_2.0/$proj`; do

        # there are some irrelevant file under projects_2.0/$proj
        if [ ! -d projects_2.0/$proj/$id ] ; then
            continue
        fi

        if [ "$proj" = 'Gson' ]; then
            if [ $id -ge 6 ] && [ $id -le 18 ]; then
                echo Fixing $proj-$id...
                cd projects_2.0/$proj/$id
                cp pom.xml pom.xml.bak
                cp gson/pom.xml gson/pom.xml.bak
                cp pom.xml gson/pom.xml
                sed -i 's,<artifactId>gson-parent</artifactId>,<artifactId>gson</artifactId>,' gson/pom.xml
                sed -i 's,<name>Gson Parent</name>,<name>Gson</name>,' gson/pom.xml
                sed -i 's,<modules>,<!--<modules>,' gson/pom.xml
                sed -i 's,</modules>,</modules>-->,' gson/pom.xml
                echo
            elif [ $id = "1" ]; then
                echo Fixing $proj-$id...
                cd projects_2.0/$proj/$id
                cp ../2/pom.xml .
                echo
            fi

        elif [ "$proj" = 'Jsoup' ]; then
            if [ $id -lt 67 ] || [ $id -gt 93 ]; then
                continue
            fi
            echo Fixing $proj-$id...
            cd projects_2.0/$proj/$id
            patch -p0 -N < $pwd/jsoup.patch
            sed -i 's/EchoServlet.Url/TestServer.checkAndFixUrl(&)/g' src/test/java/org/jsoup/integration/ConnectTest.java
            sed -i 's/HelloServlet.Url/TestServer.checkAndFixUrl(&)/g' src/test/java/org/jsoup/integration/ConnectTest.java
            sed -i 's/Deflateservlet.Url/TestServer.checkAndFixUrl(&)/g' src/test/java/org/jsoup/integration/ConnectTest.java
            sed -i 's/InterruptedServlet.Url/TestServer.checkAndFixUrl(&)/g' src/test/java/org/jsoup/integration/ConnectTest.java
            sed -i 's/RedirectServlet.Url/TestServer.checkAndFixUrl(&)/g' src/test/java/org/jsoup/integration/ConnectTest.java
            sed -i 's/SlowRider.Url/TestServer.checkAndFixUrl(&)/g' src/test/java/org/jsoup/integration/ConnectTest.java
            sed -i 's/FileServlet.Url/TestServer.checkAndFixUrl(&)/g' src/test/java/org/jsoup/integration/ConnectTest.java
            if [ -f src/test/java/org/jsoup/integration/servlets/FileServlet.java ];then
                sed -i 's/return Url + path;/return TestServer.checkAndFixUrl(Url) + path;/g' src/test/java/org/jsoup/integration/servlets/FileServlet.java
            fi
            echo
        elif [ "$proj" = 'Csv' ]; then
            if [ $id -lt 15 ] || [ $id -gt 16 ]; then
                continue
            fi
            echo Fixing $proj-$id...
            cd projects_2.0/$proj/$id
            patch -p1 < $pwd/csv.patch 
            echo
        fi
        cd $pwd
    done
done

# compile all projects
for proj in `ls projects_2.0`; do
    for id in `ls projects_2.0/$proj`; do

        # there are some irrelevant file under projects_2.0/$proj
        [ ! -d projects_2.0/$proj/$id ] && continue
        
        echo Compiling $proj-$id
        cd projects_2.0/$proj/$id
        if [ "$proj" = 'Collections' ]; then
            if [ $id = "26" ] || [ $id = "27" ]; then
                JAVA_HOME=$java7_home mvn clean test-compile -l mvn-test-compile.log
            else 
                JAVA_HOME=$java8_home mvn clean test-compile -l mvn-test-compile.log
            fi
        else
            JAVA_HOME=$java8_home mvn clean test-compile -l mvn-test-compile.log
        fi

        # check if compile succeed
        if file_contains_string mvn-test-compile.log "BUILD SUCCESS"; then
            echo mvn clean test-compile succeed!
        else
            echo mvn clean test-compile failed!
        fi
        echo
        cd $pwd
    done
done