# 🛠️ server-toolkit

Boîte à outils Bash pour l'administration et le diagnostic de serveurs Linux — audit de comptes utilisateurs, analyse de logs d'accès et healthcheck HTTP.

## Pourquoi ce projet

Trois scripts simples, mais réels : chacun résout un besoin concret rencontré en administration système et en DevOps — vérifier qu'aucun compte inattendu ne traîne sur un serveur, repérer une IP qui abuse d'un service web, ou confirmer qu'un endpoint répond avant de continuer un déploiement.

## Scripts disponibles

| Script | Rôle |
|---|---|
| `scripts/audit-users.sh` | Liste les comptes utilisateurs actifs (UID ≥ 1000) pour détecter tout compte inattendu |
| `scripts/analyze-logs.sh` | Extrait et classe les IPs générant le plus d'erreurs 4xx dans un fichier de log d'accès |
| `scripts/healthcheck.sh` | Vérifie qu'une URL répond avec le code HTTP attendu, avec code de sortie exploitable en script |

## Prérequis

- Bash 4+
- `awk`, `curl` (préinstallés sur la quasi-totalité des distributions Linux)

## Installation

```bash
git clone git@github.com:elfouego/server-toolkit.git
cd server-toolkit
chmod +x scripts/*.sh
```

## Usage

### Audit des comptes utilisateurs

```bash
./scripts/audit-users.sh
```
Affiche tous les comptes avec UID ≥ 1000 (comptes humains standards) — utile pour vérifier qu'aucun compte n'a été créé sans autorisation.

### Analyse des logs d'accès

```bash
./scripts/analyze-logs.sh /var/log/nginx/access.log
```
Retourne le top 10 des IPs générant le plus d'erreurs 4xx — un bon premier réflexe en cas d'activité suspecte.

### Healthcheck HTTP

```bash
./scripts/healthcheck.sh https://example.com
```
Retourne un code de sortie `0` si le service répond en `200`, `1` sinon — directement intégrable dans un pipeline CI/CD ou un cron de surveillance.

```bash
./scripts/healthcheck.sh https://example.com && echo "Déploiement OK" || echo "Rollback nécessaire"
```

## Contribuer

Les conventions de contribution (format des commits, stratégie de merge) sont détaillées dans [CONTRIBUTING.md](CONTRIBUTING.md).

## Récupération et gestion d'incident

Ce projet documente également les pratiques de récupération Git appliquées lors de son développement (résolution de régression via `git bisect`, sauvegardes) — voir [RECOVERY.md](RECOVERY.md).
