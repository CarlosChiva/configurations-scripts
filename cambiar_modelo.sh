#!/bin/bash

# Script para cambiar el valor de 'model:' en archivos .md
#
# Uso: ./cambiar_modelo.sh "nombre_proveedor/nombre_modelo"
#
# Ejemplos:
#   ./cambiar_modelo.sh "google/gemma-2"
#   ./cambiar_modelo.sh "meta/llama-3"
#   ./cambiar_modelo.sh "openai/gpt4"

if [ -z "$1" ]; then
    echo "Error: Debes proporcionar el nombre del modelo en formato 'proveedor/modelo'"
    echo "Uso: $0 \"nombre_proveedor/nombre_modelo\""
    exit 1
fi

# Verificar que el argumento tenga el formato "proveedor/nombre"
if [[ ! "$1" =~ ^[^/]+/[^/]+$ ]]; then
    echo "Error: El argumento debe tener el formato 'proveedor/modelo'"
    echo "Ejemplo: $0 \"google/gemma-2\""
    exit 1
fi

SEARCH_DIR="$HOME/.config/opencode/agents"
MODEL_VALUE="$1"
FILES_FOUND=0
FILES_UPDATED=0

# Buscar todos los archivos .md recursivamente
echo "🔍 Buscando archivos .md en $SEARCH_DIR..."

# Buscar y procesar cada archivo .md recursivamente
while IFS= read -r -d '' file; do
    FILES_FOUND=$((FILES_FOUND + 1))

    # Verificar si el archivo ya tiene el modelo especificado (con o sin indentación)
    if grep -qE "^[[:space:]]*model:[[:space:]]*$MODEL_VALUE" "$file"; then
        echo "⏭️  $file → Ya tiene el modelo especificado"
        continue
    fi

    # Verificar que el archivo tenga la clave model: (con o sin indentación)
    if ! grep -qE "^[[:space:]]*model:" "$file"; then
        echo "⚠️  $file → No tiene la clave 'model:'"
        continue
    fi

    # Reemplazar solo la primera línea que tenga "model:" (con o sin indentación)
    # Usamos | como delimitador para evitar conflictos con / en el modelo
    # [[:space:]]* captura espacios/tabs al inicio, y se preservan en el reemplazo
    sed -i "0,/[[:space:]]*model:/s|\([[:space:]]*model:[[:space:]]*\).*|\1${MODEL_VALUE}|" "$file"
    echo "✅ $file → Modelo actualizado a: $MODEL_VALUE"
    FILES_UPDATED=$((FILES_UPDATED + 1))

done < <(find "$SEARCH_DIR" -name "*.md" -type f -print0)

echo ""
echo "📝 Resumen:"
echo "   Archivos encontrados: $FILES_FOUND"
echo "   Archivos actualizados: $FILES_UPDATED"
if [ $FILES_UPDATED -eq 0 ]; then
    echo "   No se encontraron archivos que requerían actualización"
fi
echo ""