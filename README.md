# 🛠️ server-toolkit

Boîte à outils Bash pour l'administration et le diagnostic de serveurs Linux. Le toolkit couvre désormais un parcours complet : audit des comptes, analyse de logs, contrôle d'état HTTP et orchestration centralisée des actions via un point d'entrée unique.

## Pourquoi ce projet

Le besoin initial était simple : automatiser des vérifications systémiques rapide à exécuter sur un serveur en production ou dans un environnement de déploiement. Aujourd'hui, le projet regroupe plusieurs diagnostics utiles pour :

- détecter des comptes utilisateurs inattendus,
- repérer des adresses IP qui génèrent beaucoup d'erreurs,
- vérifier la disponibilité d'un service avant de poursuivre un déploiement,
- lancer ces contrôles via un orchestrateur cohérent.

## Scripts disponibles

| Script | Rôle |
|---|---|
| `scripts/toolkit.sh` | Point d'entrée unique pour orchestrer les diagnostics : `audit`, `logs` et `health` |
| `scripts/audit.users.sh` | Liste les comptes utilisateurs actifs (UID ≥ 1000) pour détecter tout compte inattendu |
| `scripts/analyze-logs.sh` | Extrait et classe les IPs générant le plus d'erreurs 4xx dans un fichier de log d'accès |
| `scripts/healthcheck.sh` | Vérifie qu'une URL répond avec le code HTTP attendu, avec code de sortie exploitable en script |

## Prérequis

- Bash 4+
- `awk`, `curl`
- Droits d'exécution sur les scripts

## Installation

```bash
git clone git@github.com:elfouego/server-toolkit.git
cd server-toolkit
chmod +x scripts/*.sh
```

## Utilisation principale

Le point d'entrée recommandé est `scripts/toolkit.sh`. Il fournit une interface unique et journalise les exécutions dans `/tmp/toolkit-<date>.log`.

### Audit des comptes utilisateurs

```bash
./scripts/toolkit.sh audit
```

ou, si vous voulez exécuter directement le script interne :

```bash
./scripts/audit.users.sh
```

Cette commande affiche les comptes avec UID ≥ 1000 pour repérer des comptes humans standards ou des comptes suspects.

### Analyse des logs d'accès

```bash
./scripts/toolkit.sh logs /var/log/nginx/access.log
```

ou directement :

```bash
./scripts/analyze-logs.sh /var/log/nginx/access.log
```

Le script retourne le top des IPs générant le plus d'erreurs 4xx, utile pour identifier un comportement anormal ou une tentative d'attaque.

### Healthcheck HTTP

```bash
./scripts/toolkit.sh health https://example.com
```

ou directement :

```bash
./scripts/healthcheck.sh https://example.com
```

Le script retourne un code de sortie `0` si le service répond en `200`, `1` sinon. Cette propriété permet de l'intégrer facilement dans un pipeline CI/CD ou un cron de surveillance.

```bash
./scripts/toolkit.sh health https://example.com && echo "Déploiement OK" || echo "Rollback nécessaire"
```

### Mode verbeux

```bash
./scripts/toolkit.sh -v health https://example.com
```

Le mode `-v` active une sortie détaillée des messages et permet de suivre les étapes du traitement.

## Commandes supportées par l'orchestrateur

```bash
./scripts/toolkit.sh [-v] <command> [<args>]
```

Commandes disponibles :

- `audit`
- `logs <fichier>`
- `health <url>`

## Contribuer

Les conventions de contribution (format des commits, stratégie de merge) sont détaillées dans [CONTRIBUTING.md](CONTRIBUTING.md).

## Récupération et gestion d'incident

Ce projet documente également les pratiques de récupération Git appliquées lors de son développement (résolution de régression via `git bisect`, sauvegardes) — voir [RECOVERY.md](RECOVERY.md).
