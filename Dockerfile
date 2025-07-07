# backend/Dockerfile
FROM python:3.11-slim

# Evita que Python cree archivos .pyc y asegura logs en tiempo real
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Establece el directorio de trabajo dentro del contenedor
WORKDIR /app

# Instala dependencias del sistema necesarias para compilar paquetes como psycopg2
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copia el archivo de requerimientos y los instala
COPY requirements.txt .

RUN pip install --upgrade pip && pip install -r requirements.txt

# Copia el resto del proyecto al contenedor
COPY . .

# Comando por defecto: aplicar migraciones y levantar el servidor
CMD ["sh", "-c", "python manage.py migrate && python manage.py runserver 0.0.0.0:8000"]