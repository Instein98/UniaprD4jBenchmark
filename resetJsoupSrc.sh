pwd=`pwd`

for proj in `ls projects_2.0`; do
    for id in `ls projects_2.0/$proj`; do
        # there are some irrelevant file under projects_2.0/$proj
        if [ ! -d projects_2.0/$proj/$id ] ; then
            continue
        fi

        if [ "$proj" = 'Jsoup' ]; then
            if [ $id -lt 67 ] || [ $id -gt 93 ]; then
                continue
            fi
            # echo Reseting $proj-$id...
            # cd projects_2.0/$proj/$id
            # cp $pwd/prapr_data/Projects/$proj/$id/src/test/java/org/jsoup/integration/ConnectTest.java src/test/java/org/jsoup/integration/ConnectTest.java
            # cp $pwd/prapr_data/Projects/$proj/$id/src/test/java/org/jsoup/integration/TestServer.java src/test/java/org/jsoup/integration/TestServer.java
            echo Compiling $proj-$id...
            cd projects_2.0/$proj/$id
            mvn clean test-compile
        fi
        cd $pwd
    done
done