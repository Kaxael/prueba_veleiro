#!/bin/bash

PROJECT_NAME="prueb_veleiro"
NETWORK="${PROJECT_NAME}_default"
VENV_PATH="./venv"
VENV_ACTIVATE="$VENV_PATH/bin/activate"

# ⛔ COMANDO PARA APAGAR Y LIMPIAR TODO
if [[ "$1" == "down" ]]; then
  echo "🛑 Deteniendo todos los servicios..."
  docker-compose down -v --remove-orphans
  echo "🧹 Eliminando red $NETWORK (si existe)..."
  docker network rm $NETWORK 2>/dev/null
  echo "🧼 Eliminando carpeta node_modules frontend (si existe)..."
  rm -rf frontend/file-manager/node_modules
  echo "🧼 Eliminando entorno virtual (si existe)..."
  rm -rf "$VENV_PATH"
  echo "🧽 Proyecto limpio. Puedes volver a correr con ./run.sh"
  exit 0
fi

check_docker() {
  if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker no está corriendo. Por favor inicia Docker Desktop."
    exit 1
  fi
}

cleanup_network() {
  echo "⚠️ Eliminando red $NETWORK si existe..."
  docker network rm $NETWORK 2>/dev/null
}

create_and_setup_venv() {
  echo "🐍 Creando entorno virtual en $VENV_PATH..."
  python3 -m venv "$VENV_PATH"
  source "$VENV_ACTIVATE"

  echo "📦 Instalando dependencias desde requirements.txt..."
  pip install --upgrade pip
  pip install -r requirements.txt
}

migrate_local_postgres() {
  if [ ! -f "$VENV_ACTIVATE" ]; then
    create_and_setup_venv
  else
    echo "🐍 Activando entorno virtual existente..."
    source "$VENV_ACTIVATE"
  fi

  echo "📁 Entrando a carpeta backend..."
  cd backend || {
    echo "❌ No se encontró la carpeta backend."
    return 1
  }

  echo "🔄 Ejecutando makemigrations local..."
  if ! python manage.py makemigrations --noinput; then
    echo "❌ makemigrations falló. Mostrando error completo:"
    python manage.py makemigrations
    cd ..
    return 1
  fi

  echo "🔄 Ejecutando migrate local..."
  if ! python manage.py migrate --noinput; then
    echo "❌ migrate falló. Mostrando error completo:"
    python manage.py migrate
    cd ..
    return 1
  fi

  echo "✅ Migración local completada con éxito."
  cd ..
}

# Comandos rápidos
if [[ "$1" == "bash" ]]; then
  docker exec -it veleiro_backend bash
  exit 0
fi

if [[ "$1" == "migrate" ]]; then
  docker exec -it veleiro_backend python manage.py migrate
  exit 0
fi

if [[ "$1" == "makemigrations" ]]; then
  docker exec -it veleiro_backend python manage.py makemigrations
  exit 0
fi

if [[ "$1" == "test" ]]; then
  docker exec -it veleiro_backend python manage.py test
  exit 0
fi

if [[ "$1" == "logs" ]]; then
  echo "📜 Mostrando logs en tiempo real del backend:"
  docker logs -f veleiro_backend
  read -p "Presiona Enter para salir..."
  exit 0
fi

# --- MAIN ---
migrate_local_postgres

echo "🔍 Verificando estado de Docker..."
check_docker

echo "🧹 Apagando contenedores antiguos..."
docker-compose down

echo "🚧 Intentando construir la imagen y levantar servicios..."
docker-compose up -d --build 2> docker_error.log

if grep -q 'Network ".*" needs to be recreated' docker_error.log; then
  echo "♻️ Red conflictiva detectada, reiniciando desde cero..."
  cleanup_network
  docker-compose down
  docker-compose up -d --build
fi

echo "✅ Servicios corriendo:"
docker-compose ps

# Mostrar IP del contenedor PostgreSQL
echo "🛰  Buscando IP interna del contenedor PostgreSQL (db)..."
DB_CONTAINER=$(docker ps --filter "name=_db_" --format "{{.Names}}")
if [ -n "$DB_CONTAINER" ]; then
  DB_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$DB_CONTAINER")
  echo "📡 Puedes conectarte a PostgreSQL desde DBeaver con:"
  echo "     Host: localhost"
  echo "     Port: 5433"
  echo "     User: files_user"
  echo "     Password: files_pass"
  echo "     Database: files_db"
else
  echo "⚠️ No se pudo obtener la IP del contenedor de base de datos. ¿Está corriendo?"
fi

echo ""
echo "🌐 Backend disponible en: http://localhost:8000/"
rm -f docker_error.log

### FRONTEND ###
echo ""
echo "🧭 Entrando al frontend en ./frontend/file-manager ..."
cd frontend/file-manager || {
  echo "❌ No se encontró la carpeta frontend/file-manager"
  exit 1
}

if [ ! -d "node_modules" ]; then
  echo "📦 Instalando dependencias con npm install..."
  npm install
else
  echo "✅ Dependencias npm ya instaladas"
fi

echo "🚀 Levantando frontend con npm run dev..."
npm run dev &

sleep 2
echo ""
echo "🌐 Frontend disponible en: http://localhost:5173/"
echo "🖥️  Puedes acceder desde tu navegador para usar la app completa."
