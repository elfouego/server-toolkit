#!/usr/bin/env bash
#
# toolkit.sh - Orchestrateur pour server-tookit
# Usage: ./toolkit.sh [-v] <command> [<args>]
# Commandes: audit | logs <fichier> | health <url> 
#
set -euo pipefail

# shellcheck disable=SC2155
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERBOSE=0
# shellcheck disable=SC1091
source "$SCRIPT_DIR/loggin.sh"
usage() {
    cat << EOF
Usage: $(basename "$0") [-v] <command> [<args>]
Commandes: 
    - audit  : audit des comptes et des permissions
    - logs <fichier>  : analyse des fichiers logs du système
    - health <url> : Healthcheck HTTP d'une URL donnée
    - secret-check <répertoire> : Vérification de la présence de secrets dans un dépôt Git
    - disk-cleanup [--dry-run] [--threshold <pourcentage>] : Surveiller l'espace disque et proposer un nettoyage ciblé si le seuil est dépassé
    - backup-rotate -s <répertoire_source> [-d <répertoire_destination>] [-k <jours_à_conserver>] : Créer une archive compressée d'un répertoire, la dater, et supprimer les archives plus anciennes qu'un nombre de jours donné
    Options:
    -v : mode verbeux (affiche les logs en temps réel)
    -h: : affiche ce message d'aide
EOF
}
# --- Parsing des options ---
while getopts ":vh" opt; do
    case ${opt} in
        v )
            VERBOSE=1
            echo "Mode $VERBOSE : verbeux activé, les logs seront affichés en temps réel"
            ;;  
        h )
            usage
            exit 0
            ;;
        \? )
            log_error "Option invalide: -$OPTARG"
            usage
            exit 1
            ;;
        : )
            log_error "Option -$OPTARG requiert un argument."
            usage
            exit 1
            ;;
    esac
done
shift $((OPTIND -1))

# --- Vérification des arguments ---
if [[ $# -lt 1 ]]; then
    log_error "Aucune commande spécifiée"
    usage
    exit 1
fi  

COMMAND="$1"
shift # Supprime la commande des arguments restants

case "$COMMAND" in
    audit)
        log_info "Exécution de l'audit des comptes et permissions"
        bash "$SCRIPT_DIR/audit.users.sh" 
        log_info "Audit terminé avec succès"
        ;;
    logs)
        if [[ $# -lt 1 ]]; then
            log_error "La commande 'logs' requiert un fichier comme argument <fichier>"
            usage
            exit 1
        fi
        LOGFILE="$1"
        if [[ ! -f "$LOGFILE" ]]; then
            log_error "Le fichier log spécifié n'existe pas: $LOGFILE"
            exit 1
        fi
        log_info "Analyse du fichier log: $LOGFILE"
        bash "$SCRIPT_DIR/analyze-logs.sh" "$LOGFILE"
        log_info "Analyse des logs terminée avec succès"
        ;;
    health)
        if [[ $# -lt 1 ]]; then
            log_error "La commande 'health' requiert une URL comme argument <url>"
            usage
            exit 1
        fi
        URL="$1"
        log_info "Healthcheck de l'URL: $URL"
        if bash "$SCRIPT_DIR/healthcheck.sh" "$URL"; then
            log_info "Healthcheck réussi pour l'URL: $URL"
        else
            log_error "Healthcheck échoué pour l'URL: $URL"
            exit 1
        fi
        ;;
    secret-check)
        if [[ $# -lt 1 ]]; then
            log_error "La commande 'secret-check' requiert un répertoire comme argument <répertoire>"
            usage
            exit 1
        fi
        DIRECTORY="$1"
        log_info "Vérification de la présence de secrets dans le répertoire: $DIRECTORY"
        bash "$SCRIPT_DIR/secret-check.sh" "$DIRECTORY"
        ;;
    disk-cleanup)
        log_info "Surveillance de l'espace disque et nettoyage ciblé si nécessaire"
        bash "$SCRIPT_DIR/disk-cleanup.sh" "$@"
        ;;
    backup-rotate)
        log_info "Création d'une archive compressée et rotation des sauvegardes"
        bash "$SCRIPT_DIR/backup-rotate.sh" "$@"
        ;;
    *)
        log_error "Commande inconnue: $COMMAND"
        usage
        exit 1
        ;;
esac





