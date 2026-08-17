# Journal de récupération Git

## Incident : régression healthcheck (v1.0.1)
- Détectée via `git bisect` entre v1.0.0 et HEAD
- Commit fautif identifié et corrigé
- Voir commit "fix: corriger la régression trouvée par git bisect"

## Bonnes pratiques appliquées dans ce dépôt
- ORIG_HEAD vérifié avant tout reset --hard
- rerere activé pour les conflits récurrents
- Sauvegarde bundle régulière (voir Phase 4)
