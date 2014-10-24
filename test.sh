#!/bin/bash

##
#Crea l' ambiente prima di avviare il test.
##
#Input:
#$1: L' N-esimo esercizio.
#$2: L' i-esimo test.
##

function create_test_enviornment()
{
    #Creo la directory per il test e cambio la working directory:
    mkdir $testdir && cd $testdir
    #Adesso dovrei:

    #1. copiarmi tutti i file da:
    cp -r $assessment_template_dir/* ./
    #2. Reimposto il tempo di timeout di default
    timeout_time=$TIMEOUT_DEFAULT
    #3. Richiamare l' environment    
    source environment.sh
    if [ "$DEBUG" -eq 1 ]; then
        echo "Timeout: [$timeout_time]"
    fi
}

##
# Invoca l’elaborato ($assessment_tests/elaborato.sh)
# Con tutte le cose che gli servono.
function run_elaborato()
{
    
    #Leggo i parametri
    params=$(cat parametri)


    chmod +x $assessment_tests/elaborato.sh
    start=`date +%s`
    
    # Cat stdin: Passo lo stdin.
    # Timeout: per limitare il tempo di esecuzione
    # params per passare gli argomenti
    # Redirezione stdout, ed errori
    timeout -k $timeout_time --preserve-status $timeout_time bash -c " cat stdin | $assessment_tests/elaborato.sh $params" 1> $testdir/stdout 2> $testdir/stderr

    # Salvo l' exit code
    echo $? > $testdir/exit
    
    end=`date +%s`
    runtime=$(($end-$start))
    
    if [ "$DEBUG" -eq "1" ]; then
        echo "RUNTIME:" $runtime
    fi
    
    #Se il runtime e' uguale al timeout allora vuol dire che sono andato in timeout
    if [ $runtime -eq $timeout_time ]; then
        echo $timeout_time > timeout
    fi
    
    echo $runtime > DONE
    
    #DEBUG
    if [ "$DEBUG" -eq "1" ]; then
        echo "Test.sh"
        echo "{"
        echo "   Ho avviato: '$assessment_tests/elaborato.sh'":
        echo "   Parametri:[$params]"
        echo "   Stdin: [$(cat stdin)]"
        echo ""
        echo "   I risultati:"
        echo "   $testdir/stdout:[$(cat $testdir/stdout)]"
        echo "   $testdir/exit:[$(cat $testdir/exit)]"
        echo "}"
    fi

}

#MAIN



#Itero sulle righe del file exercises.list
for next in `cat $assessment_dir/exercises.list`
do
    #Definisco assessment_test come richiesto:
    assessment_tests=$assessment_dir/$next

    #Per ogni test che il prof ha definito (sarebbe tipo $assessement_template_dir)
    for test in `ls $base_dir/$type/$session/$next`
    do
        #Imposto assessment_template_dir:
        assessment_template_dir=$base_dir/$type/$session/$next/$test
        
        #Imposto test dir:
        testdir=$assessment_tests/$test
        
        #Mi creo l'environment:
        create_test_enviornment
        
        
        #DEBUG
        if [ "$DEBUG" -eq "1" ]; then
            echo "Sto' eseguendo il test: \" $testdir\""
        fi
        #Avvio il test dell' elaborato
        run_elaborato
        
    done
    
done