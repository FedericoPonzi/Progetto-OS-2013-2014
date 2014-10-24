#!/bin/bash

##
#Mi calcolo la media degli esercizi
#
function calcola_media()
{
    #Mi conto il numero di esercizi da valutare:
    numero_esercizi=$(ls $base_dir/$type/$session/ | wc -w)
    

    score_raggiunto_esercizi=0
    for esercizio in $(cat $assessment_dir/exercises.list)
    do
       score_raggiunto_esercizi=$(expr $score_raggiunto_esercizi + $(cat $assessment_dir/$esercizio/total_score))
    done
    

    
    valutazione=$(expr $score_raggiunto_esercizi / $numero_esercizi)
    
    #DEBUG

}

function superamento_valutazione_minima()
{
    if [ $valutazione -ge $threshold_val ]; then
        valutazione_minima=1
    else
        valutazione_minima=0
    fi
}

function superamento_soglia_sup()
{

    soglia_sup=0
    nElaborati=0
    for esercizio in $(cat $assessment_dir/exercises.list)
    do
        if [ $(cat $assessment_dir/$esercizio/total_score) -ge $score_minimo ]; then
            nElaborati=$(expr $nElaborati + 1)
        fi
    done
    
    if [ $nElaborati -ge $threshold_sup ]; then
        soglia_sup=1
    fi
    
    
    
}

function superamento_soglia_inf()
{

    soglia_inf=0
    nElaborati=0
    #for ls in assessmentdir, prendo le directory degli esercizi
    #di ogni esercizio prendo il total_score
    #Il total_score di un elaborato non presente deve valere 0.
    for esercizio in $(cat $assessment_dir/exercises.list)
    do
        if [ $(cat $assessment_dir/$esercizio/total_score) -le $score_insufficiente ]; then
            nElaborati=$(expr $nElaborati + 1)
        fi
    done
    
    if [ $nElaborati -lt $threshold_inf ]; then
        soglia_inf=1
    fi
}

#Ritorna il valore di superamento in $assessment_dir/superamento
function risultato_esame_candidato()
{
    
    prove=$(expr $soglia_inf + $soglia_sup + $valutazione_minima)
    if  [ "$prove" -ge 2 ]; then
        echo "partial" > $assessment_dir/superamento
    fi
    
    if [ "$prove" -eq 3 ]; then
        echo "full" > $assessment_dir/superamento
    fi
    if [ "$prove" -le 1 ]; then
        echo "failed" > $assessment_dir/superamento
    fi
    
    #Stampo la valutazione
    echo $valutazione > $assessment_dir/valutazione
    
    superamento=$(cat $assessment_dir/superamento)
    
    
    #Stampo il voto
    voto=$(expr $valutazione \* 31 )
    voto=$(expr  $voto / 100 )
    echo $voto > $assessment_dir/voto
    
    #DEBUG
    if [ "$DEBUG" -eq "1" ]; then
        echo "Valutazione.sh"
        echo "{"
        echo "  Lo score totale raggiunto e':$score_raggiunto_esercizi"
        echo "  Numero esercizi totali: $numero_esercizi"
        echo "  La valutazione dello studente in centesimi e': $valutazione"
        echo "  La valutazione_minima e': $valutazione_minima"
        echo "  La soglia sup e': $soglia_sup"
        echo "  La soglia inf e': $soglia_inf"
        echo "  Il numero di prove che ha superato e': $prove"
        echo "  Con un voto di: $voto"
        echo "  l' esame del candidato risulta: $superamento"
        echo "}"
    fi

}

#Calcolo la media dei risultati degli esercizi
calcola_media 


superamento_valutazione_minima
superamento_soglia_inf
superamento_soglia_sup

#Calcolo il risultato dell' esame 
risultato_esame_candidato