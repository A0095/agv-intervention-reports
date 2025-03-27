


#!/bin/bash

source .env

REPO="A0095/agv-intervention-reports"
BRANCH="main"
FILEPATH="reports/rapport_2025-03-27_07-22-28.md"
COMMIT_MESSAGE="Ajout du rapport 2025-03-27_07-22-28"
REPORT_CONTENT="## Rapport AGV - 27/03/2025

Aucune erreur critique. Temps de traitement légèrement élevés sur PathProcessor. Surveillance recommandée.

Script d’extraction X90 réussi."

ENCODED_CONTENT=$(echo "$REPORT_CONTENT" | base64)

# Tenter de récupérer le SHA (si le fichier existe déjà)
SHA=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/$REPO/contents/$FILEPATH | grep '"sha"' | head -1 | cut -d '"' -f 4)

# Construire la requête JSON
if [ -n "$SHA" ]; then
  echo ">> Fichier existe déjà, mise à jour."
  JSON_PAYLOAD=$(cat <<EOF
{
  "message": "$COMMIT_MESSAGE",
  "content": "$ENCODED_CONTENT",
  "branch": "$BRANCH",
  "sha": "$SHA"
}
EOF
)
else
  echo ">> Nouveau fichier, création."
  JSON_PAYLOAD=$(cat <<EOF
{
  "message": "$COMMIT_MESSAGE",
  "content": "$ENCODED_CONTENT",
  "branch": "$BRANCH"
}
EOF
)
fi

# Envoi de la requête
curl -X PUT -H "Authorization: token $GITHUB_TOKEN" \
     -H "Content-Type: application/json" \
     -d "$JSON_PAYLOAD" \
     https://api.github.com/repos/$REPO/contents/$FILEPATH
