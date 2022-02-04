# Nemo-ReM (Nemo - Renommer en Masse)

Ce script permet de renommer des fichiers et / ou des dossiers par paquet via l'explorateur de fichiers Nemo.

Pour utiliser ce script :

  - Démarrer Nemo
  - Nemo -> Edition -> Préférences -> Comportement -> Renommer plusieurs fichiers -> Coller le chemin du fichier renommer-en-masse.sh.
  - Puis sélectionner plusieurs fichiers/dossiers dans Nemo et presser F2 (ou clic droit -> Renommer)

Dans la fenêtre qui s'ouvre :

  - Case 1* : saisir le nom de la nouvelle série de fichiers / dossiers (voir plus bas pour plus de détails)
  - Case 2  : saisir le numéro de départ. Par exemple, si vous voulez commencer la série à "fichier 05, fichier 06, .." mettez 5.
  - Case 3  : saisir le nombre de chiffres. Par exemple, 2 donnera "fichier 01, fichier 02", 3 donnera "fichier 001, fichier 002".

Précisions Case 1 (* case obligatoire)

Vous pouvez placer le numéro de fichier là où vous le souhaitez grâce au modèle de remplacement ":::".

  exemples (avec Index de départ : 1 et nb de chiffres : 2) :
  
    fichier     -> Episode ::: S01 donnera Episode 01 S01
    fichier.mkv -> Episode ::: S01 donnera Episode 01 S01.mkv
    fichier     -> Episode donnera Episode 01
    fichier     -> Episode :::.mkv donnera Episode 01.mkv
    dossier     -> Saison ::: donnera Saison 01
    dossier.moi -> Saison ::: donnera Saison 01
    
Bug possible : Le script détermine si il a affaire à un fichier ou à dossier avec la commande bash "stat" qui retourne la taille de l'élément.
Si la commande retourne 4096, c'est que l'élément est un dossier. Si par malchance, des fichiers de 4096 octets sont dans la sélection, le script les interprêtera comme des dossiers.

/!\ Les fichiers à double extension type .tar.gz ne sont pas pris en compte.
