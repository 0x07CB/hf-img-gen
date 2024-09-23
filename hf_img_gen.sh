#!/bin/bash

# if env var 'SEED' don't exists: SET 'SEED' with a RANDOM INTEGER 
if [ -z "$SEED" ]; then
    SEED=$((1 + RANDOM % 1000))
fi

# Initialiser les variables avec des valeurs par défaut
MODEL_URL="$SERVERLESS_URL"
PROMPT_FILE=""
OUTPUT_FILE="output.json"
PARAMETER__SEED=$SEED

# Fonction pour afficher l'aide
usage() {
    echo "Usage: $0 [-m MODEL_URL] [-f PROMPT_FILE]"
    exit 1
}

# Lire les options en ligne de commande
while getopts ":m:f:" opt; do
    case ${opt} in
        m )
            MODEL_URL=$OPTARG
            ;;
        f )
            PROMPT_FILE=$OPTARG
            ;;
        \? )
            usage
            ;;
    esac
done

# Vérifier que HF_API_KEY est défini
if [ -z "$HF_API_KEY" ]; then
    echo "Error: HF_API_KEY environment variable is not set."
    exit 1
fi

# Vérifier que le fichier de prompts est spécifié
if [ -z "$PROMPT_FILE" ]; then
    echo "Error: Please specify a prompt file using the -f option."
    usage
fi

# Vérifier que le fichier de prompts existe
if [ ! -f "$PROMPT_FILE" ]; then
    echo "Error: Prompt file '$PROMPT_FILE' not found."
    exit 1
fi

# Lire les prompts depuis le fichier
while read -r PROMPT; do
    # Remplacer les espaces par des underscores dans le prompt
    PROMPT=${PROMPT// /_}

    # Générer un nom de fichier unique
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    RANDOM_NUMBER=$((1 + RANDOM % 1000))
    OUTPUT_FILE="${PROMPT}_${TIMESTAMP}_${RANDOM_NUMBER}.jpg"

    # Exécuter la requête curl
    curl $MODEL_URL \
        -X POST \
        -d "{\"inputs\": \"$PROMPT\", \"parameters\": {\"seed\": $PARAMETER__SEED}}" \
        -H 'Content-Type: application/json' \
        -H "Authorization: Bearer ${HF_API_KEY}" \
	--output $OUTPUT_FILE

    # changer les droits d'accès du fichier
    chmod o+rw $OUTPUT_FILE

    # Vérifier le code de retour de curl
    if [ $? -ne 0 ]; then
        echo "Error: Failed to execute curl request for prompt '$PROMPT'."
    fi
done < "$PROMPT_FILE"
