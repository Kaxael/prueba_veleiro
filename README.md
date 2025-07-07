# 📁 Prueba Técnica - Veleiro.ai

Sistema de gestión de archivos desarrollado como prueba técnica full-stack para **Veleiro.ai**.  
Permite crear carpetas anidadas, subir archivos (.txt, .pdf, .csv, .xlsx), visualizar su contenido, extraer metadata usando la API de Pulse y navegar una estructura de archivos desde un frontend moderno.

---

## ⚙️ Tecnologías usadas

- **Backend:** Django + Django REST Framework
- **Frontend:** Vue 3 + TailwindCSS
- **Base de datos:** PostgreSQL
- **Contenedores:** Docker + Docker Compose
- **Integración externa:** [Pulse API](https://pro.api.runpulse.com)

---

## 🚀 Iniciar el proyecto

### 1. Clona el repositorio

```bash
git clone https://github.com/tu-usuario/prueb_veleiro.git
cd prueb_veleiro
2. Ejecuta el entorno completo (backend + frontend)
bash
Copiar
Editar
chmod +x run.sh
./run.sh
Este script:

Intenta aplicar migraciones localmente usando un entorno virtual ./venv

Levanta todos los servicios de Docker (backend, db, etc.)

Instala dependencias del frontend (npm install)

Lanza el frontend (npm run dev)

Si es la primera vez que corres el proyecto, el backend estará en http://localhost:8000/ y el frontend en http://localhost:5173/.

🔄 Comandos rápidos
bash
Copiar
Editar
./run.sh bash           # Entrar al contenedor del backend
./run.sh migrate        # Ejecutar migrate dentro del contenedor
./run.sh makemigrations # Ejecutar makemigrations dentro del contenedor
./run.sh logs           # Ver logs del backend en tiempo real
🧹 Apagar y limpiar todo
bash
Copiar
Editar
./run.sh down
Esto:

Detiene y elimina contenedores

Borra la red Docker personalizada

Elimina node_modules del frontend

Elimina el entorno virtual ./venv

Ideal para dejar el proyecto en estado limpio y volver a levantarlo desde cero.

📄 Estructura del proyecto
bash
Copiar
Editar
prueb_veleiro/
├── backend/               # Django project (DRF + PostgreSQL)
│   ├── core/              # App principal
│   └── manage.py
├── frontend/
│   └── file-manager/      # Vue 3 + Tailwind + Vite
├── venv/                  # Entorno virtual (generado por run.sh)
├── run.sh                 # Script maestro para levantar o limpiar
├── docker-compose.yml
└── README.md
🔐 API de Pulse
Se utiliza el endpoint /extract_beta de Pulse para extraer:

Idioma del archivo

Número de líneas

Entidades nombradas (NER)

Bounding boxes (OCR)

El archivo .txt se convierte internamente a .pdf si no es compatible, y luego se envía a Pulse directamente desde el backend.

🧪 Ejemplo de uso
Crear una carpeta

Seleccionarla

Subir un archivo .txt o .pdf

El sistema convierte, envía a Pulse y almacena la metadata

Al hacer clic en un archivo, se muestra su resumen de metadata

📦 Requisitos
Docker + Docker Compose

Python 3.8+

Node.js v16+

✨ Autor
Miguel Ángel Restrepo T.
Desarrollador Full Stack 
Tecnologías: Django REST | PostgreSQL | Vue.js | Docker