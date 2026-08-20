#!/usr/bin/env bash
#Objectif du script : Surveiller l'espace disque et, si un seuil est dépassé, proposer ou effectuer un nettoyage ciblé des zones connues pour s'engorger.
set -euo pipefail
# shellcheck disable=SC2155
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/loggin.sh"
DRY_RUN=false
THRESHOLD=80

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --threshold)
            THRESHOLD="$2"
            shift 2
            ;;
        *)
            log_error "Option inconnue: $1"
            exit 1
            ;;
    esac
done

disk_usage=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
log_info "Utilisation actuelle du disque: $disk_usage%"
if (( disk_usage < THRESHOLD )); then
    log_warn "Seuil d'utilisation du disque maitrisé : $disk_usage% < $THRESHOLD%"
    exit 0
fi

log_warn "Seuil d'utilisation du disque dépassé : $disk_usage% >= $THRESHOLD%"
# Définir les répertoires à nettoyer
declare -A CLEANUP_PATHS=(
    ["/var/log/*.log"]="Fichiers journaux"
    ["/tmp/*"]="Fichiers temporaires"
    ["$HOME/.cache/*"]="Caches système"
    ["/var/cache/apt/archives/*.deb"]="Caches APT"
    ["/var/tmp/*"]="Fichiers temporaires système"
)

for path in "${!CLEANUP_PATHS[@]}"; do
    description="${CLEANUP_PATHS[$path]}"
    log_info "Nettoyage ciblé des $description dans $path"
    if [[ -e "$path" ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            log_info "[DRY-RUN] Commande simulée: rm -rf $path"
            du -sh "$path" 2>/dev/null || echo "0"
        else
            rm -rf "$path" && log_info "Nettoyage de $description terminé avec succès."
        fi
    else
        log_warn "Aucun fichier ou répertoire trouvé pour le nettoyage ciblé des $description dans $path"
        continue
    fi
done
    
