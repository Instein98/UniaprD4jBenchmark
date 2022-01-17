pwd=`pwd`

recoverPom(){
    cp pom.xml.bak pom.xml
    cp gson/pom.xml.bak gson/pom.xml
}


for proj in `ls projects_2.0`; do
    for id in `ls projects_2.0/$proj`; do
        # there are some irrelevant file under projects_2.0/$proj
        if [ ! -d projects_2.0/$proj/$id ] ; then
            continue
        fi

        if [ "$proj" = 'Gson' ]; then
            if [ $id -lt 6 ] || [ $id -gt 18 ]; then
                continue
            fi
            echo Fixing $proj-$id...
            cd projects_2.0/$proj/$id
            # recoverPom
            cp pom.xml pom.xml.bak
            cp gson/pom.xml gson/pom.xml.bak
            cp pom.xml gson/pom.xml
            sed -i 's,<artifactId>gson-parent</artifactId>,<artifactId>gson</artifactId>,' gson/pom.xml
            sed -i 's,<name>Gson Parent</name>,<name>Gson</name>,' gson/pom.xml
            sed -i 's,<modules>,<!--<modules>,' gson/pom.xml
            sed -i 's,</modules>,</modules>-->,' gson/pom.xml
            echo
        elif [ "$proj" = 'Jsoup' ]; then
            if [ $id -lt 67 ] || [ $id -gt 93 ]; then
                continue
            fi
            echo Fixing $proj-$id...
            cd projects_2.0/$proj/$id
            # if [ $id -ge 67 ] && [ $id -le 77 ];then
            #     patch -p0 -N < $pwd/jsoup67.patch
            # elif [ $id -ge 78 ] && [ $id -le 81 ];then
            #     echo not implemented
            #     # patch -p0 -R < $pwd/jsoup78.patch
            # elif [ $id -ge 82 ] && [ $id -le 93 ];then
            #     echo not implemented
            #     # patch -p0 -R < $pwd/jsoup82.patch
            # fi
            patch -p0 -N < $pwd/jsoup.patch
            sed -i 's/EchoServlet.Url/TestServer.checkAndFixUrl(&)/g' src/test/java/org/jsoup/integration/ConnectTest.java
            sed -i 's/HelloServlet.Url/TestServer.checkAndFixUrl(&)/g' src/test/java/org/jsoup/integration/ConnectTest.java
            sed -i 's/Deflateservlet.Url/TestServer.checkAndFixUrl(&)/g' src/test/java/org/jsoup/integration/ConnectTest.java
            sed -i 's/InterruptedServlet.Url/TestServer.checkAndFixUrl(&)/g' src/test/java/org/jsoup/integration/ConnectTest.java
            sed -i 's/RedirectServlet.Url/TestServer.checkAndFixUrl(&)/g' src/test/java/org/jsoup/integration/ConnectTest.java
            sed -i 's/return Url + path;/return TestServer.checkAndFixUrl(Url) + path;/g' src/test/java/org/jsoup/integration/servlets/FileServlet.java
            echo
        fi
        cd $pwd
    done
done