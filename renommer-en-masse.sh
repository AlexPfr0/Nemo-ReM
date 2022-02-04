#!/bin/bash

# Ce script permet à Nemo de renommer plusieurs fichiers et/ou dossiers en même temps
# Ajouter le chemin du script dans les options de Nemo :
# Nemo -> Edition -> Préférences -> Comportement -> Renommer plusieurs fichiers
# Puis sélectionner plusieurs fichiers dans Nemo and et presser F2 (ou clic droit -> Renommer)

# Convertit '+' en ' ' et '%20' en ' '
# $1 = chaine à décoder
function urldecode() {
    : "${*//+/ }"; echo -e "${_//%/\\x}";
}

# Ecrit dans un fichier log (si dispo)
function log() {
    echo $1 >> "/tmp/renommage-en-masse.log"
}

# Cette fonction renomme les fichiers sélectionnés avec les données du formulaire
# $1 Nom du dichier 
# $2 Numéro du fichier
# $3 Nombre de chiffres
pattern=":::" # => Schéma qui doit être remplacé par le compteur
function renommerFichier() {

    nom=$1
    numero=$2
    nbCh=$3

# Si le nouveau nom ne contient pas le modèle à remplacer, on l'ajoute.
    if [[ ! "$nom" =~ "$pattern" ]];

        then

            nom="$nom $pattern"

    fi

# Si le nombre de chiffre n'est pas indiqué
# On renomme avec un format standard
# Sinon on renomme 
    if [[ "$nbCh" -eq "" ]];

        then

            nom="$nom $numero"
            echo "${nom/"$pattern "/""}"
            
        else

            printf -v index "%0$3d" $numero
            echo "${nom/"$pattern"/"$index"}"
    
        fi

}

log "============ Nouvelle série de renommage `date '+%Y-%m-%d %H:%M:%S'` ============"

#Affichage du formulaire de renommage

nomFichierForm="$(zenity --forms \
    --title="Renommer en masse" \
    --text="Définir une nouvelle série de nom\nUtiliser ::: pour choisir l'emplacement du numéro" \
    --add-entry="Nom du nouveau fichier" \
    --add-entry="Index de départ (0-9)" \
    --add-entry="Nombre de chiffres (1-9)" \
    --separator="|")"

# Mémorisation des réponses
nomFichier="$(echo "$nomFichierForm"| cut -d '|' -f 1)"
indexDepart="$(echo "$nomFichierForm"| cut -d '|' -f 2)"
nbChiffre="$(echo "$nomFichierForm"| cut -d '|' -f 3)"

log "Nouvelle série : $nomFichier"

# Si le champs nom est vide ou qu'il contient des / => Erreur
if [[ -z "$nomFichier" ]] || [[ $nomFichier == *\/*  ]]; then
    notify-send "Erreur" "Le nom n'est pas valide !" -i error -u low
    exit 0
fi

# Initialisation du numéro de fichier
# Si le champ "Index de départ" n'est est pas rempli, on part de 1
if [[ "$indexDepart" -eq "" ]];
    then
        numeroF=1
    else
        numeroF=$indexDepart
fi

# Boucle dans la liste des fichier sélectionnés dans Nemo
# Format initial du chemin "file:///home/user/.."

# Initialisation du nombre de fichiers renommés
nbFichierRenomme=0

# La boucle
for i; do

i=$(urldecode $i)
    
    # Suppression du préfixe "file://"
    oldPath=${i/"file://"/""}  # /mnt/media/file.yxy.xx
    path="${oldPath%\/*}" # /mnt/media/
    
    f=${oldPath##*\/} # file.yxy.xx
    #ext=${f#*.} # .yxy.xx
    ext=${oldPath##*.} # .xx

taille=$(stat -c%s "$oldPath")


# L'élément courant est un fichier (4096 = taille en octets d'un dossier / un peu barbare mais bon ..)
if [[ $taille -ne 4096 ]]; 

    then

        type="(fichier)"

        # si le fichier n'a pas d'extention, $ext contient le nom du fichier (sans extension)
        if [[ ! "$f" =~ "." ]];
        
            then 

                nouNom="$path/$(renommerFichier "$nomFichier" "$numeroF" "$nbChiffre")"
        # Sinon, on renomme et on ajoute l'extension
            else 

                nouNom="$path/$(renommerFichier "$nomFichier" "$numeroF" "$nbChiffre").$ext"
        fi
# Du coup l'élément est un dossier, on renomme sans extension (on ne tient pas compte des . dans le nom du dossier)
    else
        type="(dossier)"    
                nouNom="$path/$(renommerFichier "$nomFichier" "$numeroF" "$nbChiffre")"
fi


    log "= $oldPath -> $nouNom $type"
    mv "$oldPath" "$nouNom"
    numeroF=$((numeroF+1))
    nbFichierRenomme=$((nbFichierRenomme+1))
done

notify-send "Nemo : Terminé" "Succès : $nbFichierRenomme fichiers ont été renommés" -i nemo -u low
log "Succès : $nbFichierRenomme éléments ont été renommés"
log "### Terminé ###"
exit 0