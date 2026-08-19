#Choix de l'architecture de  server-toolkit.sh
## Pourquoi un orchestrateur plutôt que 3 scripts indépendants
Centraliser l'interface (`getopts`, aide, codes de sortie cohérents) tout en
gardant chaque script métier indépendant et testable seul.

## Pourquoi `set -euo pipefail` partout
Un script de production ne doit jamais continuer silencieusement après un
échec.

## Pourquoi un trap EXIT systématique
Garantit un message de fin cohérent et un log exploitable, que le script
réussisse, échoue, ou soit interrompu — indispensable pour un script destiné
à tourner en cron ou en pipeline CI/CD sans supervision humaine directe.

## Pourquoi la journalisation vers un fichier ET stdout (tee)
Permet un usage interactif (on voit tout de suite) tout en gardant une trace
exploitable a posteriori — utile en cas d'exécution non supervisée.

## Limites connues
- `set -e` n'intercepte pas les échecs dans les conditions `if`/`while` — géré
  explicitement dans chaque commande via des tests dédiés.
- Le fichier de log n'est pas rotaté par ce script — à déléguer à `logrotate`
  en production (voir cours systemd/logrotate de ce même parcours).