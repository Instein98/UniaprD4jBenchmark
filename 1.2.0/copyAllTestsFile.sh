d4j_mvn_proj_path="/home/yicheng/apr/d4jMvn/Projects/"
d4j_proj_path="/home/yicheng/apr/d4jProj/"

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
        [ ! -d $d4j_mvn_proj_path/$proj/$id ] && continue
        cp $d4j_proj_path/$proj/$id/all_tests $d4j_mvn_proj_path/$proj/$id/
        cp $d4j_proj_path/$proj/$id/failing_tests $d4j_mvn_proj_path/$proj/$id/
    done
done
