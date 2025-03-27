#!/bin/bash

# Variables à personnaliser
GITHUB_TOKEN="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"
REPO="A0095/agv-intervention-reports"
BRANCH="main"
FILEPATH="reports/rapport_2025-03-27_07-22-28.md"
COMMIT_MESSAGE="Ajout du rapport 2025-03-27_07-22-28"
REPORT_CONTENT="## Rapport AGV - 27/03/2025\n\nAucune erreur critique. Temps de traitement légèrement élevés sur PathProcessor. Surveillance recommandée.\n\nScript d’extraction X90 réussi."

# Encodage base64 du contenu
ENCODED_CONTENT=$(echo "$REPORT_CONTENT" | base64)

# Récupérer le SHA si le fichier existe déjà (nécessaire pour update)
SHA=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/$REPO/contents/$FILEPATH | jq -r .sha)

# Préparer la requête JSON
if [ "$SHA" != "null" ]; then
  echo ">> Fichier existe déjà, mise à jour."
  JSON_PAYLOAD=$(jq -n --arg msg "$COMMIT_MESSAGE" --arg content "$ENCODED_CONTENT" --arg branch "$BRANCH" --arg sha "$SHA" \
  '{message: $msg, content: $content, branch: $branch, sha: $sha}')
else
  echo ">> Nouveau fichier, création."
  JSON_PAYLOAD=$(jq -n --arg msg "$COMMIT_MESSAGE" --arg content "$ENCODED_CONTENT" --arg branch "$BRANCH" \
  '{message: $msg, content: $content, branch: $branch}')
fi

# Envoi vers GitHub
curl -X PUT -H "Authorization: token $GITHUB_TOKEN" \
     -H "Content-Type: application/json" \
     -d "$JSON_PAYLOAD" \
     https://api.github.com/repos/$REPO/contents/$FILEPATH
