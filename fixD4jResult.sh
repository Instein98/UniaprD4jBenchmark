pwd=`pwd`
for proj in `ls result`; do
    for id in `ls result/$proj`; do
        echo fixing result/$proj/$id
        cd result/$proj/$id
        sed -n 's/\(.*\)(\(.*\))/\2#\1 PASS/p' all_tests | sed 's/\(.*\)\[.*\] PASS/\1 PASS/' | sort | uniq > d4jTestResult
        for line in `cat d4jFailedTests`; do
                sed -i "s/$line PASS/$line FAIL/" d4jTestResult
        done
        cd $pwd
    done
done