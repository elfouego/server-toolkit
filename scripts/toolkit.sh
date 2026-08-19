#!/usr/bin/env bash
#
# toolkit.sh - Orchestrateur pour server-tookit
# Usage: ./toolkit.sh [-v] <command> [<args>]
# Commandes: audit | logs <fichier> | health <url> 
#
set -euo pipefail

# shellcheck disable=SC2155
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC2155
readonly LOG_FILE="/tmp/toolkit-$(date +%Y-%m-%d).log"
VERBOSE=0
echo "dossier du script: $SCRIPT_DIR"
# --- Journalisation structurée ---
log() {
    local level="$1" # INFO, WARN, ERROR
    shift
    local message="$*"
    local timestamp
    timestamp="$(date +'%Y-%m-%d %H:%M:%S')"
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

log_info() {
    log "INFO" "$@";
}
log_warn() {
    log "WARN" "$@";
}
log_error() {
    log "ERROR" "$@" >&2;
}
# -- Gestion des errreurs (trap ERR) ---
on_error() {
    local line_num="$1"
    local command="$2"
    local exit_code="$3"
    log_error "Échec à la ligne $line_num : la commande '$command' a retourné le code $exit_code"
}
trap 'on_error $LINENO "$BASH_COMMAND" $?' ERR

# --- Netoyyage systématique, quelle que soit l'issue rencontrée ---
cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        log_error "Le script s'est terminé avec le code $exit_code"
    else
        log_info "Le script s'est terminé avec succès"
    fi
    log_info "Fin d'éxéution du script, log complet disponible dans $LOG_FILE"
}
trap cleanup EXIT

# --- Arrêt propre après interruption ---
trap 'log_warn "Interruption par utilisateur"; exit 130' INT TERM

usage() {
    cat << EOF
Usage: $(basename $0) [-v] <command> [<args>]
Commandes: 
    - audit  : audit des comptes et des permissions
    - logs <fichier>  : analyse des fichiers logs du système
    - health <url> : Healthcheck HTTP d'une URL donnée

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
    *)
        log_error "Commande inconnue: $COMMAND"
        usage
        exit 1
        ;;
esac





