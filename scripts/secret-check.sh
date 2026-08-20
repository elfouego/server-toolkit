#!/usr/bin/env bash
# secret-check.sh - Vérification de la présence de secrets dans un dépôt Git
# Usage: ./scripts/toolkit.sh secret-check <répertoire> ou ./secret-check.sh <répertoire> 

set -euo pipefail
# shellcheck disable=SC2155
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/loggin.sh"
PATTERNS=(
    "AKIA[0-9A-Z]{16}"  # AWS Access Key ID
    "ASIA[0-9A-Z]{16}"  # AWS Session Token
    "AIza[0-9A-Za-z\\-_]{35}"  # Google API Key
    "ghp_[0-9A-Za-z]{36}"  # GitHub Personal Access Token
    "xox[baprs]-[0-9a-zA-Z]{10,48}"  # Slack Token
    "BEGIN PRIVATE KEY"  # Private Key    
    "password[=:][^,; ]+"  # Password in config files
    "api_key[=:][^,; ]+"  # API Key in config files
    "token[=:][^,; ]+"  # Token in config files
    "secret[=:][^,; ]+"  # Secret in config files
    "Authentication[=:][^,; ]+"  # Authentication in config files
    "Autorization[=:][^,; ]+"  # Authorization in config files
    "Bearer[=:][^,; ]+"  # Bearer token in config files
)

main () {
    if [[ $# -ne 1 ]]; then
        log_error "Usage: $0 <répertoire>"
        exit 1
    fi

    local directory="$1"
    local tmp_dir=""
    #clonnage du dépôt Git si le répertoire est un URL
    if [[ "$directory" =~ ^https://? ]]; then
        tmp_dir=$(mktemp -d)
        log_info "Clonage du dépôt Git $directory dans le répertoire temporaire: $tmp_dir"
        git clone --depth 1 "$directory" "$tmp_dir" > /dev/null || {
            log_error "Échec du clonage du dépôt Git: $directory"
            exit 1
        }
        directory="$tmp_dir"
    fi

    if [[ ! -d "$directory" ]]; then
        log_error "Le répertoire spécifié n'existe pas: $directory"
        exit 1
    fi

    log_info "Vérification de la présence de secrets dans le répertoire: $directory"
    local found_secrets=0

    #cherche de secrets dans le répertoire en utilisant les motifs définis et affiche les fichiers et les lignes correspondantes
    for pattern in "${PATTERNS[@]}"; do
        log_info "Recherche de secrets correspondant au motif: $pattern"
        if grep -rE -l "$pattern" "$directory" > /dev/null; then
            log_warn "Secret trouvé correspondant au motif: $pattern"
            while read -r line; do
                log_warn "Fichier: ${line%%:*}, Ligne: ${line#*:}"
            done < <(grep -rE -n "$pattern" "$directory")
            found_secrets=1
        fi
    done
    #ne pas oublier de supprimer le répertoire temporaire si on a cloné un dépôt Git
    if [[ -n "${tmp_dir:-}" ]]; then
        log_info "Suppression du répertoire temporaire: $tmp_dir"
        rm -rf "$tmp_dir"
    fi

    if [[ $found_secrets -eq 0 ]]; then
        log_info "Aucun secret trouvé dans le répertoire: $directory"
    else
        log_error "Des secrets ont été trouvés dans le répertoire: $directory"
        exit 1
    fi
}

main "$@"
