#!/bin/bash

# Some settings

#########################################
### Variabili da modificare: ############
#########################################
# Path della cartella tmp, senza slash finale.
tmp="./basedir/tmp"

# Valore di Timeout di default
TIMEOUT_DEFAULT=5

# Valore minimo della valutazione di una prova di esame sopra il quale la prova si intende superata. Espressa in centesimi.
threshold_val=60

# Numero minimo di elaborati che debbono superare uno $score_minimo 
threshold_sup=4

# Rappresenta il massimo numero di elaborati che possono avere uno score inferiore a $score_insufficiente
threshold_inf=2

score_minimo=60

score_insufficiente=59


#########################################
### Debug: ##############################
#########################################
#Se settato ad uno, stampa informazioni utili per il debug
readonly DEBUG=0

#########################################
### Altro: ##############################
#########################################

EARCHIVE_NAME=2
EARCHIVE_INTEGRITY=3
EARCHIVE_STRUCTURE=4
EARCHIVE_CANDIDATE_INFO=5


#Function: red_echo
#Print out red message.
red_echo() 
{

    echo -e "\e[1;31m$1\e[0m" # il codice serve pe stampa in rosso

}