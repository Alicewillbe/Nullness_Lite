# Automate the evaluation result on Ubuntu
#
# Author(s): XINRONG ZHAO

#----------------------------Variables & Helper Methods
RESULT=$(pwd)"/result.txt"
SEP="--------------------"
GET_BRANCH="git branch | grep \* | sed -r \"s/\* //g\""
GET_JAVA="find src/main | grep -e \"\.java$\""

declare -a CHECKER_NAME=("Nullness_Lite Option"
			 # other features fill here
			 "The Nullness Checker")
declare -a BRANCH_NAME=("annos_nl_all_xz"
			"analysis_3_nc_yk_xz")

countWord() {
    eval $GET_JAVA"| xargs grep -on \"$1\" | wc -l"
}

appendResult () {
    echo $1 >> $RESULT
}

#----------------------------Fetch Source Code

echo "Generating results in $RESULT"
printf "$(date +%Y-%m-%d)\n" > $RESULT

rm -rf junit4/
git clone https://github.com/NullnessLiteGroup/junit4.git junit4
cd junit4

appendResult $SEP
countSubject=1
appendResult "Experiment Subject #$countSubject:"
appendResult "JUnit4"

#----------------------------Annotations Added Report
appendResult $SEP
appendResult "1. # of annotations:"
appendResult "Name of the Checker|Current Branch|Total Count|@Nullable|@UnderInitialization|@UnknownInitialization"

count=0
for i in "${CHECKER_NAME[@]}"
do
    git checkout ${BRANCH_NAME[$count]} > /dev/null 2>&1
    countNullable=$(countWord "@Nullable")
    countUnderInit=$(countWord "@UnderInitialization")
    countUnknownInit=$(countWord "@UnknownInitialization")
    total=$(($countNullable + $countUnderInit + $countUnknownInit))
    appendResult "$i|$(eval $GET_BRANCH)|$total|$countNullable|$countUnderInit|$countUnknownInit"
    count=$(( $count + 1 ))
done

#----------------------------Errors Analysis Report
appendResult $SEP
appendResult "2. Analysis Report:"
appendResult "Name of the Checker|Current Branch|True Positives|False Positives"

count=0
for i in "${CHECKER_NAME[@]}"
do
    git checkout ${BRANCH_NAME[$count]} > /dev/null 2>&1
    appendResult "$i|$(eval $GET_BRANCH)|$(countWord "TRUE_POSITIVE")|$(countWord "FALSE_POSITIVE")"
    count=$(( $count + 1 ))
done

#----------------------------END
echo $SEP
printf "Finish evaluation with JUnit4! \n"
cd ../
rm -rf junit4

# print the result
column -t -s "|" $RESULT