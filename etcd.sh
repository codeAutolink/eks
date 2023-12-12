#!/bin/bash

# Chemin où le système de fichiers EFS est monté
EFS_MOUNT_POINT="/mnt/efs/etcd-backups"

# Nom du fichier de sauvegarde
BACKUP_NAME="etcd-backup-$(date +%Y%m%d%H%M%S).db"

# Commande de sauvegarde
etcdctl snapshot save "${EFS_MOUNT_POINT}/${BACKUP_NAME}"

# Vérification de la réussite de la sauvegarde
if [ $? -eq 0 ]; then
    echo "La sauvegarde d'etcd a été effectuée avec succès."

    # Garder uniquement les 3 derniers snapshots
    # Supprimer les anciens snapshots, en ne conservant que les 3 plus récents
    cd $EFS_MOUNT_POINT
    ls -tp | grep -v '/$' | tail -n +4 | xargs -I {} rm -- {}

else
    echo "Échec de la sauvegarde d'etcd."
    exit 1
fi
