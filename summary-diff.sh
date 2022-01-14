for d in result/*/*; do
    echo ===== $d =====
    diff -s $d/d4jTestResult $d/uniaprTestResult
    echo
done
