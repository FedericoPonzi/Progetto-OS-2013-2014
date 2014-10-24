#!/bin/bash


#Controllo che gli output che mi aspetto siano uguali a quelli richiesti:

function check_expected()
{
    if [ -f $testdir/timeout ]; then
        echo 0 > $testdir/score.stdout
        echo 0 > $testdir/score.exit
        echo 0 > $testdir/score.stderr
        echo 0 > $testdir/score.output
        return
    fi

    if [ "$(cat $testdir/stdout)" == "$(cat $testdir/expected.stdout )" ]; then
        echo 1 > $testdir/score.stdout
    else
        diff $testdir/stdout $testdir/expected.stdout > $testdir/stdout.diff
        echo 0 > $testdir/score.stdout
        
    fi
    
    if [ "$(cat $testdir/exit)" == "$(cat $testdir/expected.exit)" ]; then
        echo 1 > $testdir/score.exit
    else
        diff $testdir/exit $testdir/expected.exit > $testdir/exit.diff
        echo 0 > $testdir/score.exit
    fi
    
    if [ "$(cat $testdir/stderr)" == "$(cat $testdir/expected.stderr)" ]; then
        echo 1 > $testdir/score.stderr
    else
        diff $testdir/stderr $testdir/expected.stderr > $testdir/stderr.diff
        echo 0 > $testdir/score.stderr
   fi
    
    if [ "$(cat $testdir/output)" == "$(cat $testdir/expected.output)" ]; then
        echo 1 > $testdir/score.output
    else
        diff $testdir/output $testdir/expected.output > $testdir/output.diff
        echo 0 > $testdir/score.output
    fi

    
}

#Funzione per generare il file assessment.out
function generate_ass_out()
{

    #Aggiorno il file riassuntivo:
    #STDOUT
    if [ ! -f $testdir/score.stdout.ignore ]; then
        stdoutvar=$(cat $testdir/score.stdout)
    else
        stdoutvar="-"
    fi 
    #STDERR
    if [ ! -f $testdir/score.stderr.ignore ]; then
        stderrvar=$(cat $testdir/score.stderr)
    else
        stderrvar="-"
    fi 
    #EXIT
    if [ ! -f $testdir/score.exit.ignore ]; then
        exitvar=$(cat $testdir/score.exit)
    else
        exitvar="-"
    fi 
    
    #OUTPUT
    if [ ! -f $testdir/score.output.ignore ]; then
        outvar=$(cat $testdir/score.output)
    else
       outvar="-"
    fi 
    
    #TIMEOUT
    if [ -f $testdir/timeout ]; then
        tovar=1
    else
        tovar=0
    fi
    
    assessmentOut="$next,`basename $testdir`,$stdoutvar,$stderrvar,$exitvar,$outvar,$tovar"
    echo $assessmentOut >> $assessment_dir/assessment.out
}

#Conta lo score per un singolo test di un esercizio
function count_test_score()
{
    test_score_total=0
    test_scores_num=0
    
    if [ ! -f $testdir/score.out.ignore ]; then
        score_out=$(cat $testdir/score.output)
        test_score_total=`expr $test_score_total + $score_out`
        test_scores_num=`expr $test_scores_num + 1`
    fi
      if [ ! -f $testdir/score.stdout.ignore ]; then
       test_score_total=`expr $test_score_total + $(cat $testdir/score.stdout)`
       test_scores_num=`expr $test_scores_num + 1`
    fi
      if [ ! -f $testdir/score.stderr.ignore ]; then
       test_score_total=`expr $test_score_total + $(cat $testdir/score.stderr)`
       test_scores_num=`expr $test_scores_num + 1`
    fi
      if [ ! -f $testdir/score.exit.ignore ]; then
       test_score_total=`expr $test_score_total + $(cat $testdir/score.exit)`
       test_scores_num=`expr $test_scores_num + 1`
    fi
    #Valore del singolo test:
    max_score=$(expr 100 / $num_test)
    #Test score:
    var=$(expr $max_score \* $test_score_total / $test_scores_num)
    echo $var > $testdir/test_score
}


#Score:

#Creo il file riassuntivo e lo imposto con le colonne:
assessmentOut="Esercizio,test,stdout,stderr,exit,output,timeout"
echo $assessmentOut > $assessment_dir/assessment.out

for next in $(cat $assessment_dir/exercises.list)
do

    assessment_test=$assessment_dir/$next

    #Mi calcolo il numero di test:
    num_test=$(ls -d $assessment_test/*/ | wc -w)
    total_score=0
    for testdir in $(ls -d $assessment_test/*/)
    do
        #Il massimo score raggiungibile:
        
        var=`expr 100 / $num_test`
        echo $var > $testdir/max_score
        
        #Controllo i risultati dei test
        check_expected

        generate_ass_out
        
        count_test_score
        
        total_score=$(expr $var + $total_score)
    done

    echo $total_score > $assessment_test/total_score
done

if [ "$DEBUG" -eq "1" ]; then
    echo ""
    echo "score.sh - ASSESSMENT.OUT:"
    echo "{"
    cat $assessment_dir/assessment.out
    echo "}"
    echo ""
fi