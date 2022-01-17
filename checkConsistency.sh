
pwd=`pwd`

check_empty_and_delete(){
    if [ ! -s $1 ]; then
        echo Error: $1 is empty!!!
        rm $1
    fi
}

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
        git clone git@github.com:claudeyj/prapr_data.git
        cd prapr_data
        git reset --hard be9ababc95df45fd66574c6af01122ed9df3db5d
        cd Projects
        cp -r Cli Codec Collections Compress Csv Gson JacksonCore JacksonDatabind JacksonXml Jsoup JxPath ../../projects_2.0
        cd $pwd
    fi
}

prepare_uniapr(){
    if [ ! -d uniapr-profiler-only ]; then
        git clone git@github.com:ise-uiuc/uniapr.git uniapr-profiler-only
        cd uniapr-profiler-only 
        git checkout yicheng
        git reset --hard 29096a41051cad0985dcf54806f9bd1fda8dc22a
        cp ../uniapr.patch .
        git apply uniapr.patch
        mvn clean install
    fi
}

prepare_projects
prepare_uniapr
for proj in `ls projects_2.0`; do
    for id in `ls projects_2.0/$proj`; do
        # there are some irrelevant file under projects_2.0/$proj
        if [ ! -d projects_2.0/$proj/$id ] || file_contains_string identicalProj "$proj-$id$" ; then
            continue
        fi

        # prepare the result directory
        [ ! -d result/$proj/$id ] && mkdir -p result/$proj/$id
        
        # run d4j tests
        echo processing $proj-$id for defects4j
        # checkout and test if target directory does not exist or checkout/test is interrupted
        if [ ! -d d4j_projects/$proj/$id ] || [ ! -f d4j_projects/$proj/$id/d4jFailedTests ]; then
            [ -d d4j_projects/$proj/$id ] && rm -rf d4j_projects/$proj/$id
            [ ! -d d4j_projects/$proj ] && mkdir -p d4j_projects/$proj
            echo checking out defects4j $proj-$id
            defects4j checkout -p $proj -v "$id"b -w d4j_projects/$proj/$id > /dev/null
            # if checkout failed, further test make no sense
            if [ -d d4j_projects/$proj/$id ];then
                cd d4j_projects/$proj/$id 
                echo defects4j testing
                defects4j test > d4j-test.log
            else 
                echo *** Defects4j Checkout Failed!  ***
            fi
        else
            echo d4j_projects/$proj/$id already exists, skip defects4j testing
        fi
        if [ -d $pwd/d4j_projects/$proj/$id ];then
            cd $pwd/d4j_projects/$proj/$id 
            sed -n 's/  - \(.*\)::\(.*\)/\1#\2/p' d4j-test.log | sort | uniq > d4jFailedTests
            # the second pipe is to handle the parameterized tests
            sed -n 's/\(.*\)(\(.*\))/\2#\1 PASS/p' all_tests | sed 's/\(.*\)\[.*\] PASS/\1 PASS/' | sort | uniq > d4jTestResult
            for line in `cat d4jFailedTests`; do
                sed -i "s/$line PASS/$line FAIL/" d4jTestResult
            done
            cp all_tests d4j-test.log d4jFailedTests d4jTestResult $pwd/result/$proj/$id
        fi
        cd $pwd
        echo

        # run uniapr profiler
        echo processing $proj-$id for uniapr
        cd projects_2.0/$proj/$id
        #if [ ! -f uniaprTestResult ]; then
            #mvn clean test-compile -l mvn-test-compile.log
            #if file_contains_string mvn-test-compile.log "BUILD SUCCESS"; then
            #    echo mvn test-compile succeed!
            #else 
            #    echo mvn test-compile failed!
            #fi
            echo running uniapr for $proj-$id
            # Gson-1 needs TZ=America/Los_Angeles to be consistent
            TZ=America/Los_Angeles mvn org.uniapr:uniapr-plugin:profiler-only:validate -DrestartJVM=true -Dd4jAllTestsFile=$pwd/d4j_projects/$proj/$id/all_tests -Ddebug=true -l uniapr.log
        #else
        #    echo uniapr.log already exists, skip running uniapr
        #fi
        sed -n 's/Profiler failed test: \(.*\)\.\(..*\)/\1#\2/p' uniapr.log | sort | uniq > uniaprFailedTests
        sed -n 's/RUNNING: \(.*\)\.\(..*\)\.\.\. /\1#\2 PASS/p' uniapr.log | sort | uniq > uniaprTestResult
        for line in `cat uniaprFailedTests`; do
            sed -i "s/$line PASS/$line FAIL/" uniaprTestResult
        done
        cp uniapr.log uniaprFailedTests uniaprTestResult $pwd/result/$proj/$id
        cd $pwd
        check_empty_and_delete projects_2.0/$proj/$id/uniaprTestResult
        check_empty_and_delete result/$proj/$id/uniaprTestResult
        echo
        
    done
done
