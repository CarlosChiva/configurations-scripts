# Scripts personalizados

Este repository contiene varios scripts de bash para automatizar tareas comunes.

## Scripts disponibles

### `install_ollama.sh`

Instala y configura el servicio Ollama en el sistema.

**Requisitos:**
- Privilegios de administrador (sudo)
- Acceso a /etc/systemd/system/

**Uso:**
```bash
sudo ./install_ollama.sh
```

**Descripción:**
Descarga e instala Ollama automáticamente, actualiza el servicio systemd para permitir acceso desde el puerto 0.0.0.0 y reinicia el servicio.

---

### `update_opencode.sh`

Actualiza el contenedor de Open WebUI a la última versión.

**Requisitos:**
- Docker y docker-compose instalados
- Contenedor de Open WebUI anteriormente ejecutado

**Uso:**
```bash
./update_opencode.sh
```

**Descripción:**
Pula la última imagen de Open WebUI desde GitHub, detiene y elimina el contenedor anterior y lanza la nueva versión con persistencia de datos.

---

### `cambiar_modelo.sh`

Actualiza todos los archivos .md que contienen la clave `model:` en el directorio `~/.config/opencode/agents`.

**Requisitos:**
- Un argumento con el nombre del modelo en formato `proveedor/nombre`

**Uso:**
```bash
./cambiar_modelo.sh "google/gemma-2"
```

**Ejemplos:**
```bash
./cambiar_modelo.sh "google/gemma-2"
./cambiar_modelo.sh "meta/llama-3"
./cambiar_modelo.sh "openai/gpt4"
```

**Descripción:**
Busca recursivamente todos los archivos .md en `~/.config/opencode/agents` y reemplaza el valor de `model:` por el proporcionado. Solo actualiza archivos que aún no tengan el modelo especificado.

## Notas generales

- Estos scripts requieren permisos de lectura y escritura en sus respectivos archivos/directorios
- Siempre verifica los scripts antes de ejecutarlos en producción
- Se recomienda tener permisos de administrador para algunos scripts