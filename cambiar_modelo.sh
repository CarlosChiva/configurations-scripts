#!/bin/bash

# Script interactivo para configurar modelos en agentes
# Permite seleccionar agentes individuales o aplicar el mismo modelo a varios

SEARCH_DIR="$HOME/.config/opencode/agents"
TEMP_FILE="$HOME/.config/opencode/agents/.temp_config.txt"
SELECTED_AGENTS=()
FILES_PROCESSED=0
FILES_UPDATED=0
FILES_SKIPPED=0

# Limpia el archivo temporal
cleanup() {
    rm -f "$TEMP_FILE"
    exit 0
}
trap cleanup EXIT

# Función para mostrar menú de agentes
show_agent_menu() {
    AGENTS=()
    agent_files=()
    
    # Recopilar todos los archivos .md
    while IFS= read -r -d '' file; do
        AGENTS+=("$(basename "$file" .md)")
        agent_files+=("$file")
    done < <(find "$SEARCH_DIR" -name "*.md" -type f -print0)

    if [ ${#AGENTS[@]} -eq 0 ]; then
        echo "❌ No se encontraron agentes en $SEARCH_DIR"
        exit 1
    fi

    # Crear selección numérica
    echo "🎯 Agentes disponibles:"
    echo ""
    for ((i = 0; i < ${#AGENTS[@]}; i++)); do
        printf "%2d. %-20s " $((i + 1)) "${AGENTS[$i]}"
        if [ -f "$SEARCH_DIR/${AGENTS[$i]}.md" ] && grep -qE "^[[:space:]]*model:" "$SEARCH_DIR/${AGENTS[$i]}.md"; then
            current_model=$(grep -m 1 "^[[:space:]]*model:" "$SEARCH_DIR/${AGENTS[$i]}.md" | sed 's/^[[:space:]]*model:[[:space:]]*//')
            echo "(Actual: $current_model)"
        else
            echo "(Sin model configurado)"
        fi
    done
    echo ""
    echo "Selecciona los agentes (deja vacío para continuar):"
}

# Función para seleccionar agente
select_agents() {
    show_agent_menu
    read -r selection
    
    # Manejar selección múltiple
    if [[ "$selection" =~ ^[[:space:]]*$ ]]; then
        return
    fi

    # Verificar si seleccionó "todos"
    if [[ "$selection" =~ "all" ]] || [[ "$selection" =~ "ALL" ]]; then
        ALL_AGENTS=()
        while IFS= read -r -d '' file; do
            ALL_AGENTS+=("$(basename "$file" .md)")
        done < <(find "$SEARCH_DIR" -name "*.md" -type f -print0)
        SELECTED_AGENTS=("${ALL_AGENTS[@]}")
    else
        IFS=' ' read -ra selected <<< "$selection"
        for idx in "${selected[@]}"; do
            if [ "$idx" -ge 1 ] && [ "$idx" -le ${#AGENTS[@]} ]; then
                SELECTED_AGENTS+=("${AGENTS[$((idx - 1))]}")
            fi
        done
    fi

    # Verificar que haya al menos uno
    if [ ${#SELECTED_AGENTS[@]} -eq 0 ]; then
        return
    fi

    # Mostrar resumen
    echo ""
    echo "✅ Agentes seleccionados: ${#SELECTED_AGENTS[@]}"
    for agent in "${SELECTED_AGENTS[@]}"; do
        echo "      - $agent"
    done
    echo ""
}

# Función para confirmar cambios
confirm_changes() {
    echo "¿Deseas aplicar los mismos cambios a TODOS los agentes seleccionados?"
    read -p "> [1] Aplicar a todos / [2] Cambiar cada uno individualmente: " choice
    
    case $choice in
        1|"")
            apply_same_to_all
            ;;
        2)
            change_individual
            ;;
        *)
            echo "❌ Opción inválida"
            confirm_changes
            ;;
    esac
}

# Función para cambiar todos los seleccionados al mismo modelo
apply_same_to_all() {
    echo ""
    echo "📝 Actualizando todos los agentes seleccionados:"
    echo 

    for agent in "${SELECTED_AGENTS[@]}"; do
        agent_file="$SEARCH_DIR/${agent}.md"
        
        if [ ! -f "$agent_file" ]; then
            echo "❌ $agent → No se encontraron"
            FILES_SKIPPED=$((FILES_SKIPPED + 1))
            continue
        fi

        # Verificar si el agente ya tiene el modelo actual
        if grep -qE "^[[:space:]]*model:[[:space:]]*$MODEL_VALUE" "$agent_file"; then
            echo "⏭️  $agent → Ya tiene el modelo asignado"
            FILES_SKIPPED=$((FILES_SKIPPED + 1))
            continue
        fi

        # Actualizar el archivo
        sed -i "0,/^[[:space:]]*model:/s|\([[:space:]]*model:[[:space:]]*\).*|\1${MODEL_VALUE}|" "$agent_file"
        
        # Verificar si se actualizó correctamente
        if grep -qE "^[[:space:]]*model:[[:space:]]*$MODEL_VALUE" "$agent_file"; then
            echo "✅ $agent → Modelo actualizado a: $MODEL_VALUE"
            FILES_UPDATED=$((FILES_UPDATED + 1))
        else
            echo "❌ $agent → Error al actualizar"
            FILES_SKIPPED=$((FILES_SKIPPED + 1))
        fi
        
        FILES_PROCESSED=$((FILES_PROCESSED + 1))
    done
}

# Función para cambiar cada uno individualmente
change_individual() {
    echo ""
    echo "🔧 Modificación individual:"
    echo ""
    
    for agent in "${SELECTED_AGENTS[@]}"; do
        agent_file="$SEARCH_DIR/${agent}.md"
        current_model=$(grep -m 1 "^[[:space:]]*model:" "$agent_file" 2>/dev/null | sed 's/^[[:space:]]*model:[[:space:]]*//' | cut -d' ' -f1)
        
        echo "📝 Agente: $agent"
        echo "   Modelo actual: ${current_model:-No configurado}"
        echo ""
        
        read -p "   Nuevo modelo (proveedor/nombre, o enter para mantener): " new_model
        
        # Si el usuario no ingresa nada, mantener el modelo actual o dejarlo vacío
        if [[ -z "$new_model" ]]; then
            echo "⏭️  $agent → Se mantiene el modelo actual"
            FILES_SKIPPED=$((FILES_SKIPPED + 1))
            continue
        fi

        # Verificar formato
        if [[ ! "$new_model" =~ ^[^/]+/[^/]+$ ]]; then
            echo "❌ Format invalido. Debe ser 'proveedor/nombre'"
        else
            # Actualizar el archivo
            sed -i "0,/^[[:space:]]*model:/s|\([[:space:]]*model:[[:space:]]*\).*|\1${new_model}|" "$agent_file"
            
            # Verificar si se actualizó
            # Extraer nuevo valor
            updated_model=$(grep -m 1 "^[[:space:]]*model:" "$agent_file" | sed 's/^[[:space:]]*model:[[:space:]]*//' | cut -d' ' -f1)
            echo "✅ $agent → Modelo actualizado a: $updated_model"
            FILES_UPDATED=$((FILES_UPDATED + 1))
        fi
        FILES_PROCESSED=$((FILES_PROCESSED + 1))
        echo ""
    done
}

# Flujo principal
while true; do
    echo "═" '═' "═" '═' "═" '═' "═" '═' "═" '═' "═" '═' "═" '═' "═" '═' "═" '═' '═' '═' '═' '═' '═' '═' '═' '═' '═' "═" '═' '═' "═" '═' '═'
    echo "╔ Agentes "
    echo "╚ Interactivo de Configuración de Modelos"
    echo "═" '═' "═" '═' "═" '═' "═" '═' "═" '═' "═" '═' '═' "═" '═' "═" '═' "═" '═' '═' '═' '═' '═' '═' '═' '═' "═" '═' "═" "═" '═' '═'
    echo ""
    echo "1. Seleccionar y modificar agentes"
    echo "2. Salir"
    echo ""
    read -p "Seleccione una opción: " main_choice

    case $main_choice in
        1)
            select_agents
            
            if [ ${#SELECTED_AGENTS[@]} -eq 0 ]; then
                echo "❌ No hay agentes seleccionados"
                continue
            fi
            
            echo ""
            echo "¿Cuál es la nueva configuración de modelos?"

            while true; do
                read -p "Ingrese modelo (proveedor/nombre): " MODEL_INPUT
                if [[ ! "$MODEL_INPUT" =~ ^[^/]+/[^/]+$ ]]; then
                    echo "❌ Error: El formato debe ser 'proveedor/nombre'"
                    echo "Ejemplo: ollama/glm_code"
                else
                    MODEL_VALUE="$MODEL_INPUT"
                    break
                fi
            done
            
            confirm_changes
            break
            ;;
        2)
            echo "👋 Adiós!"
            exit 0
            ;;
        *)
            echo "❌ Opción inválida"
            ;;
    esac
done

echo ""
echo "╔" '═' "═" '═' '═' "═" '═' "═" '═' "═" '═' "═" '═' '═' "═" '═' "═" '═' "═" '═' '═' '═' "═" '═' '═' "═" '═' "═"
echo "║"
echo "║  📊 Resultados Finales"
echo "║"
echo "╚" '═' "═" "═" '═' "═" "═" '═' "═" "═" '═' "═" "═" '═' "═══" '═' '═' '═' '═' "═" '═' '═' '═' '═' "═" '═'
echo ""
echo "  Agentes seleccionados: ${#SELECTED_AGENTS[@]}"
echo "  Archivos procesados: $FILES_PROCESSED"
echo "  Archivos actualizados: $FILES_UPDATED"
echo "  Archivos sin cambios: $FILES_SKIPPED"
echo ""
if [ $FILES_UPDATED -gt 0 ]; then
    echo "  ✅ Configuración completada"
else
    echo "  ⚠️  No se realizaron cambios"
fi
