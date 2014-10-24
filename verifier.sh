#!/bin/bash

source etc/settings.sh

#Input:
#$1: base_dir, directory di lavoro  
#$2: assessment_type (self, bundle) autocorrezione o correzione del prof
#$3: type, shell o system
#$4: session, AAAA_AAAA_mm_gg
#$5: ID identificatore del compito che si trova in $tmp/$ID

##Mi salvo le variabili:
base_dir="$1"
assessment_type="$2"
type="$3"
session="$4"
ID="$5"
#set -x
#Function: Usage.
#It prints out the usage of this script.
function usage()
{
	echo ""
	echo "USAGE: $0 base_dir assessment_type type session ID"
	exit 1
}


#Function: error_parameter
#Print out the number of the bad argument.
error_parameter()
{
	
	red_echo "Error on parameter: '$1'"
	red_echo "$2 excepted"
    usage
	echo ""
	exit 1
}

#Function: check_input
#This function check for the correct inputs. If and error is found, it prints out the usage.
check_input()
{

	#Check base dir:
	if [ ! -d "$1" ]; then
		error_parameter "$1" "A directory"
	fi
	#Base_dir ok
    #Check assessment_type
    if [[ "$2" != "self" ]] && [[ "$2" != "bundle" ]]; then
		error_parameter "$2" "self or bundle"
    fi
    
    if [[ "$3" != "shell" ]] && [[ "$3" != "system" ]]; then
    	error_parameter "$3" "shell or system"
	fi
    if [[ "$4" != [0-9][0-9][0-9][0-9]_[0-9][0-9][0-9][0-9]_[0-9][0-9]_[0-9][0-9] ]]; then
    	error_parameter "$4" "number"
    fi
}


#chiamata a funzione
check_input $1 $2 $3 $4


#Importo variabili dello studente:
#source $tmp/$ID/elaborato_info.sh

#Imposto la variabile assessment_dir che verra' usata dopo
#assessment_dir=$base_dir/assessment/$assessment_type/$type/$session/$student_surname.$student_ID

#Mi salvo la working directory
wd=$(pwd)

#Eseguo check.sh
source check.sh 

#Eseguo i test:
source test.sh

#Mi reimposto la wd:

cd $wd

#Calcolo lo score:
source score.sh

#Calcolo la valutazione
source valutazione.sh