for d in result/*/*; do
    echo ===== $d =====
    diff $d/d4jTestResult $d/uniaprTestResult
    echo
done
