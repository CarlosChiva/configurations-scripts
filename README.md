# Scripts personalizados

Este repository contiene varios scripts de bash para automatizar tareas comunes.

## Scripts disponibles

### `install_ollama.sh`

Instala y configura el servicio Ollama en el sistema.

**Requisitos:**
- Privilegios de administrador (sudo)
- Acceso a /etc/systemd/system/

**Uso:**

Para instalar/actualizar 
```bash
sudo ./install_ollama.sh
```
Si se quiere añadir alguna variable de entorno se puede añadir como argumento como por ejemplo:

```bash
sudo ./install_ollama.sh OLLAMA_HOST=0.0.0.0
```
Tambien admite pasarle multiples variables de entorno:

```bash
sudo ./install_ollama.sh OLLAMA_HOST=0.0.0.0 CUDA_VISIBLE_DEVICES=0
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
./cambiar_modelo.sh 
```

El script te mostrará la lista de modleos encontrados y se puede seleccionar que modelos se quiere cambiar y por cual proveedor/modelo.
Tambien se puede cambiar los agentes seleccionados por el proveedor/modelo escrito o cambiarlos individualmente si se prefiere.

**Descripción:**
Busca recursivamente todos los archivos .md en `~/.config/opencode/agents` y reemplaza el valor de `model:` por el proporcionado. Solo actualiza archivos que aún no tengan el modelo especificado.

## Notas generales

- Estos scripts requieren permisos de lectura y escritura en sus respectivos archivos/directorios
- Siempre verifica los scripts antes de ejecutarlos en producción
- Se recomienda tener permisos de administrador para algunos scripts