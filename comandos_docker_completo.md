
# 🐳 Comandos de Docker

Esta guía recopila **todos los comandos de Docker**, explicados desde los más usados hasta los menos frecuentes, con ejemplos reales para entornos de **DevOps y desarrollo web** (Flask, PostgreSQL, Nginx, Redis).

---

## 🚀 1. Introducción rápida a Docker

Docker permite empaquetar una aplicación y sus dependencias en **contenedores** que se ejecutan de forma consistente en cualquier entorno.

Un contenedor es una **instancia ligera y aislada** de una imagen.

---

## ⚙️ 2. Comandos Esenciales

### Ver información general
```bash
docker version        # Muestra la versión de cliente y servidor Docker
docker info           # Muestra detalles del sistema Docker
```

### Listar imágenes y contenedores
```bash
docker images         # Lista imágenes locales
docker ps             # Lista contenedores activos
docker ps -a          # Lista todos los contenedores (incluyendo detenidos)
```

### Descargar imágenes
```bash
docker pull nginx     # Descarga la última imagen de Nginx desde Docker Hub
```

### Construir imágenes
```bash
docker build -t formulario-web ./flask_formulario
```
👉 **Explicación:**  
- `-t formulario-web` etiqueta la imagen.  
- `./flask_formulario` es el directorio donde está el `Dockerfile`.

---

## 🧱 3. Gestión de Contenedores

### Crear y ejecutar contenedores
```bash
docker run -d   --name form_db   -e POSTGRES_USER=postgres   -e POSTGRES_PASSWORD=postgres   -e POSTGRES_DB=formdb   -v pgdata:/var/lib/postgresql/data   -p 5432:5432   postgres:15
```

👉 Crea un contenedor PostgreSQL:
- `-d`: modo background (detached)
- `--name`: nombre del contenedor
- `-e`: variables de entorno
- `-v`: volumen persistente
- `-p`: mapea el puerto 5432 del contenedor al 5432 del host

### Ejecutar contenedor Flask conectado a PostgreSQL
```bash
docker run -d   --name form_web   -e DATABASE_URL=postgresql://postgres:postgres@form_db:5432/formdb   -p 5000:5000   formulario-web
```

### Acceder a un contenedor
```bash
docker exec -it form_db bash
```

### Ver logs
```bash
docker logs form_web
```

### Detener / iniciar / eliminar contenedores
```bash
docker stop form_web
docker start form_web
docker rm form_web
```

---

## 🌐 4. Redes y Volúmenes

### Crear una red personalizada
```bash
docker network create form_net
```

### Conectar contenedores en la misma red
```bash
docker run -d   --name form_db   --network form_net   -e POSTGRES_USER=postgres   -e POSTGRES_PASSWORD=postgres   -e POSTGRES_DB=formdb   -v pgdata:/var/lib/postgresql/data   -p 5432:5432   postgres:15
```

```bash
docker run -d   --name form_web   --network form_net   -e DATABASE_URL=postgresql://postgres:postgres@form_db:5432/formdb   -p 5000:5000   formulario-web
```

---

## 🧩 5. Docker Compose (Flask + PostgreSQL + Nginx)

### Estructura del proyecto
```
project/
│
├── flask_app/
│   ├── app.py
│   ├── requirements.txt
│   └── Dockerfile
├── nginx/
│   └── nginx.conf
├── docker-compose.yml
└── .env
```

### Ejemplo de `.env`
```env
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=formdb
DATABASE_URL=postgresql://postgres:postgres@db:5432/formdb
```

### Ejemplo de `Dockerfile` (Flask)
```Dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["python", "app.py"]
```

### Ejemplo de `docker-compose.yml`
```yaml
version: '3.9'

services:
  db:
    image: postgres:15
    container_name: form_db
    restart: always
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    volumes:
      - pgdata:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    networks:
      - form_net

  web:
    build: ./flask_app
    container_name: form_web
    restart: always
    environment:
      DATABASE_URL: ${DATABASE_URL}
    depends_on:
      - db
    ports:
      - "5000:5000"
    networks:
      - form_net

  nginx:
    image: nginx:latest
    container_name: nginx_proxy
    ports:
      - "80:80"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - web
    networks:
      - form_net

volumes:
  pgdata:

networks:
  form_net:
```

### Comandos útiles de Compose
```bash
docker-compose up -d        # Inicia todos los servicios
docker-compose down         # Detiene y elimina los contenedores
docker-compose ps           # Muestra el estado
docker-compose logs -f      # Logs en tiempo real
docker-compose build        # Reconstruye las imágenes
```

---

## 🧹 6. Limpieza del Sistema

```bash
docker system prune         # Elimina todo lo no usado
docker image prune          # Limpia imágenes no usadas
docker container prune      # Elimina contenedores detenidos
docker volume prune         # Elimina volúmenes no usados
```

---

## ☁️ 7. Docker Hub y CI/CD Básico

```bash
docker tag formulario-web usuario/formulario-web:v1
docker login
docker push usuario/formulario-web:v1
```

👉 **Flujo típico DevOps:**
1. Se construye la imagen en CI/CD (por ejemplo en GitHub Actions)
2. Se etiqueta (`tag`)
3. Se sube (`push`) a Docker Hub o un registro privado

---

## 🔍 8. Comandos Avanzados y Menos Frecuentes

```bash
docker inspect <nombre>     # Muestra metadatos del contenedor o imagen
docker diff <nombre>        # Muestra los cambios en el contenedor
docker stats                # Monitorea uso de CPU, memoria y red
docker history <imagen>     # Historial de capas de una imagen
docker export -o cont.tar form_web   # Exporta contenedor
docker import cont.tar nuevo_form    # Importa como nueva imagen
docker save -o img.tar formulario-web  # Guarda una imagen como tar
docker load -i img.tar               # Carga una imagen desde tar
```

---

