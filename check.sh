#!/bin/bash


#Input:
#$1: $tmp_dir  
tmp_dir=$tmp/$ID

function check_input()
{
	#Controllo che ci siano esattamente due file:
	if [[ $(ls $tmp_dir | wc -w) -ne 2 ]]; then
    	echo "Troppi file all' interno della directory temporanea!"
        red_echo "Ce ne sono: $(ls $tmp_dir | wc -w)"
        red_echo $(ls $tmp_dir)
        exit 1
    fi
    #Controllo che esista il file elaborato_info.sh:
	if [[ ! -f "$tmp_dir/elaborato_info.sh" ]]; then
		red_echo "elaborato_info.sh not found!"
        exit 1
    fi
    #Importo variabili dello studente:
    source $tmp/$ID/elaborato_info.sh
    assessment_dir=$base_dir/assessment/$assessment_type/$type/$session/$student_surname.$student_ID

    #controllo che esista un file tar.gz:
    if [ ! -f $tmp_dir/*.tar.gz ]; then
    	red_echo "not a tar.gz"
    fi
}

##
# Controlla che l'archivio sia apposto
##
function check_archive()
{
  #check che il nome sia corretto
  	if [[ ! -f "$tmp_dir/"$student_surname"_$student_ID.tar.gz" ]]; then
		#ed_echo "EARCHIVE NAME"
		exit $EARCHIVE_NAME
    fi
  
  
  # tenta e nel caso scompatta
  tar -C $1 -xzf $tmp_dir/"$student_surname"_$student_ID.tar.gz 2>/dev/null || 
  {
    exit $EARCHIVE_INTEGRITY
  }
  
  #a questo punto ha scompattato, devo controllare la struttura ovvero
  #devo controllare che ci siano le cartelle 1,2,3,4,5 e candidato.info
  
  if [ ! -f "$tmp_dir/candidato.info" ]; then
         exit $EARCHIVE_STRUCTURE
  fi


    #Controllo che nella directory temporanea, ci siano le directory degli esercizi
    # che mi aspetto di trovare.
    for cartella in $(ls -d $base_dir/$type/$session/*/ )
        do
            namebase=$(basename $cartella)
            if [ ! -d "$tmp_dir/$namebase/" ]; then
                exit $EARCHIVE_STRUCTURE
            fi
        done
}

########
#Controlla che le informazioni del candidato corrispondano con le informazioni contenute in elaborato_info
##
function check_candidato_info()
{
	grep student_name[^a-zA-Z1-9]*$student_name $tmp_dir/candidato.info > /dev/null || exit $EARCHIVE_CANDATE_INFO
	grep student_surname[^a-zA-Z1-9]*$student_surname $tmp_dir/candidato.info > /dev/null || exit $EARCHIVE_CANDATE_INFO
    grep student_ID[^a-zA-Z1-9]*$student_ID $tmp_dir/candidato.info > /dev/null || exit $EARCHIVE_CANDATE_INFO
    grep student_email[^a-zA-Z1-9]*$student_email $tmp_dir/candidato.info > /dev/null || exit $EARCHIVE_CANDATE_INFO
}

function check_esercizi_svolti()
{
	touch $tmp_dir/exercises.list
    value=1
    for cartella in $(ls -d $tmp_dir/*)
    	do
        	if [ -f "$cartella/elaborato.sh" ]; then
            	echo "$value" >> $tmp_dir/exercises.list
    		fi
            value=$(expr $value + 1)
        done 
}

#MAIN:

#Controllo l' input:
check_input $tmp_dir

#Controllo archivio
check_archive $tmp_dir

#Controllo le informazioni del candidato
check_candidato_info

#Controllo gli esercizi che ha svolto 
check_esercizi_svolti
mkdir -p $assessment_dir

#DEBUG

if [ "$DEBUG" -eq "1" ]; then
    #Mi evito di spostare i file degli assesment da questa cartella.
    
    echo "Check.sh: Ho fatto il copy"
    cp -r $tmp_dir/* $assessment_dir
    rm -r $tmp_dir/1 $tmp_dir/2 $tmp_dir/4 $tmp_dir/5 $tmp_dir/3  $tmp_dir/candidato.info $tmp_dir/exercises.list
    
    
else
    mv $tmp_dir/* $assessment_dir
fi
