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
            cd projects_2.0/$proj/$id
            # recoverPom
            cp pom.xml pom.xml.bak
            cp gson/pom.xml gson/pom.xml.bak
            echo Fixing $proj-$id...
            cp pom.xml gson/pom.xml
            sed -i 's,<artifactId>gson-parent</artifactId>,<artifactId>gson</artifactId>,' gson/pom.xml
            sed -i 's,<name>Gson Parent</name>,<name>Gson</name>,' gson/pom.xml
            sed -i 's,<modules>,<!--<modules>,' gson/pom.xml
            sed -i 's,</modules>,</modules>-->,' gson/pom.xml
        fi
        cd $pwd
    done
done