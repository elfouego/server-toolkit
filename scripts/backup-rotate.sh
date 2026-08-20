#!/usr/bin/env bash
#Objectif du script : Créer une archive compressée d'un répertoire, la dater, et supprimer les archives plus anciennes qu'un nombre de jours donné
set -euo pipefail
# shellcheck disable=SC2155
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/loggin.sh"

BACKUP_SOURCE_DIR=""
BACKUP_DEST_DIR="/tmp/backups"
KEEP_DAYS=7

while getopts ":s:d:k:" opt; do
    case ${opt} in
        s )
            BACKUP_SOURCE_DIR="$OPTARG"
            ;;
        d )
            BACKUP_DEST_DIR="$OPTARG"
            ;;
        k )
            KEEP_DAYS="$OPTARG"
            ;;
        \? )
            log_error "Option invalide: -$OPTARG"
            exit 1
            ;;
        : )
            log_error "Option -$OPTARG requiert un argument."
            exit 1
            ;;
    esac
done
shift $((OPTIND -1))

if [[ -z "$BACKUP_SOURCE_DIR" ]]; then
    log_error "Le répertoire source pour la sauvegarde n'a pas été spécifié. Utilisez l'option -s <répertoire_source>"
    exit 1
fi

#Création du backup
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_FILENAME="$(basename "$BACKUP_SOURCE_DIR")-${TIMESTAMP}.tar.gz"
log_info "Création de l'archive de sauvegarde: $BACKUP_FILENAME à partir du répertoire: $BACKUP_SOURCE_DIR"

if [[ -z "$BACKUP_DEST_DIR" ]]; then
    log_warn "Le répertoire de destination pour la sauvegarde n'a pas été spécifié. le repertoire par défaut sera utilisé: $BACKUP_DEST_DIR"
else
    if [[ ! -d "$BACKUP_DEST_DIR" ]]; then
        log_info "Le répertoire de destination pour la sauvegarde n'existe pas. Création du répertoire: $BACKUP_DEST_DIR"
        mkdir -p "$BACKUP_DEST_DIR"
    fi
    log_info "Le répertoire de destination pour la sauvegarde est: $BACKUP_DEST_DIR"
fi

tar -czf "$BACKUP_DEST_DIR/$BACKUP_FILENAME" -C "$(dirname "$BACKUP_SOURCE_DIR")" "$(basename "$BACKUP_SOURCE_DIR")"
log_info "Sauvegarde terminée: $BACKUP_DEST_DIR/$BACKUP_FILENAME"

#Suppression des backups plus anciens que KEEP_DAYS
log_info "Suppression des archives de sauvegarde plus anciennes que $KEEP_DAYS jours dans le répertoire: $BACKUP_DEST_DIR"
find "$BACKUP_DEST_DIR" -name "$(basename "$BACKUP_SOURCE_DIR")-*.tar.gz" -type f -mtime +"$KEEP_DAYS" -exec rm -f {} \; -exec log_info "Supprimé: {}" \;
log_info "Rotation des sauvegardes terminée"