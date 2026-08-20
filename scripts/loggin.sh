#!/usr/bin/env bash
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
