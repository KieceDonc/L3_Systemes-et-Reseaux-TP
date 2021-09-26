file_path=$1
file_inoeuds=($(ls -i $file_path)^[0-9])
file_owner_name=$(stat $file_path -c %U)
file_owner_group=$(stat $filepath -c %D)
file_size=$(stat $filepath -c %s)
echo "nom du fichier :" $(basename $file_path)
echo "numéro de i-noeuds :" $file_inoeuds
echo "nom du propriétaire :" $file_owner_name
echo "nom du groupe :" $file_owner_group
echo "taille :" $file_size " en bits"
