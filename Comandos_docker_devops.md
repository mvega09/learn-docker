# Guía Completa de Comandos Docker para DevOps

## Tabla de Contenidos
1. [Gestión de Imágenes](#gestión-de-imágenes)
2. [Gestión de Contenedores](#gestión-de-contenedores)
3. [Gestión de Volúmenes](#gestión-de-volúmenes)
4. [Gestión de Redes](#gestión-de-redes)
5. [Docker Compose](#docker-compose)
6. [Docker Swarm](#docker-swarm)
7. [Registro y Repositorios](#registro-y-repositorios)
8. [Inspección y Monitoreo](#inspección-y-monitoreo)
9. [Limpieza y Mantenimiento](#limpieza-y-mantenimiento)
10. [Docker Build](#docker-build)
11. [Seguridad](#seguridad)
12. [Troubleshooting](#troubleshooting)

---

## Gestión de Imágenes

### `docker pull`
Descarga una imagen desde un registro (por defecto Docker Hub).

```bash
# Descargar la última versión
docker pull nginx

# Descargar versión específica
docker pull nginx:1.21-alpine

# Descargar desde registro privado
docker pull registry.company.com/myapp:latest

# Descargar todas las tags
docker pull --all-tags nginx
```

### `docker build`
Construye una imagen desde un Dockerfile.

```bash
# Build desde directorio actual
docker build -t myapp:1.0 .

# Build con Dockerfile específico
docker build -f Dockerfile.prod -t myapp:prod .

# Build sin caché
docker build --no-cache -t myapp:1.0 .

# Build con argumentos
docker build --build-arg ENV=production -t myapp:1.0 .

# Build con target específico (multi-stage)
docker build --target production -t myapp:prod .

# Build para múltiples plataformas
docker buildx build --platform linux/amd64,linux/arm64 -t myapp:1.0 .
```

### `docker images` / `docker image ls`
Lista las imágenes disponibles localmente.

```bash
# Listar todas las imágenes
docker images

# Listar con formato personalizado
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

# Filtrar por nombre
docker images nginx

# Mostrar imágenes dangling
docker images --filter "dangling=true"

# Mostrar solo IDs
docker images -q

# Mostrar con digest
docker images --digests
```

### `docker rmi`
Elimina una o más imágenes.

```bash
# Eliminar imagen específica
docker rmi nginx:latest

# Eliminar múltiples imágenes
docker rmi image1:tag1 image2:tag2

# Forzar eliminación
docker rmi -f myapp:1.0

# Eliminar todas las imágenes dangling
docker rmi $(docker images -f "dangling=true" -q)

# Eliminar todas las imágenes
docker rmi $(docker images -q)
```

### `docker tag`
Crea un alias/tag para una imagen.

```bash
# Crear tag local
docker tag myapp:1.0 myapp:latest

# Tag para registry privado
docker tag myapp:1.0 registry.company.com/myapp:1.0

# Tag para Docker Hub
docker tag myapp:1.0 username/myapp:1.0
```

### `docker save`
Exporta una o más imágenes a un archivo tar.

```bash
# Guardar imagen en archivo
docker save myapp:1.0 > myapp-1.0.tar

# Guardar con opción -o
docker save -o myapp-1.0.tar myapp:1.0

# Guardar múltiples imágenes
docker save -o images-backup.tar myapp:1.0 nginx:latest mysql:8
```

### `docker load`
Carga una imagen desde un archivo tar.

```bash
# Cargar imagen desde archivo
docker load < myapp-1.0.tar

# Cargar con opción -i
docker load -i myapp-1.0.tar

# Ver salida detallada
docker load --input myapp-1.0.tar
```

### `docker import`
Importa contenido desde un tarball para crear una imagen.

```bash
# Importar desde tarball
docker import backup.tar myapp:imported

# Importar desde URL
docker import http://example.com/backup.tar myapp:imported

# Importar con mensaje
docker import -m "Initial import" backup.tar myapp:v1
```

### `docker history`
Muestra el historial de capas de una imagen.

```bash
# Ver historial completo
docker history nginx:latest

# Sin truncar salida
docker history --no-trunc nginx:latest

# Ver solo comandos que crearon capas
docker history --format "{{.CreatedBy}}" nginx:latest

# Con formato legible de tamaños
docker history --human=true nginx:latest
```

---

## Gestión de Contenedores

### `docker run`
Crea y ejecuta un nuevo contenedor desde una imagen.

```bash
# Ejecutar contenedor simple
docker run nginx

# Ejecutar en modo detached (background)
docker run -d nginx

# Ejecutar con nombre personalizado
docker run --name my-nginx -d nginx

# Ejecutar con mapeo de puertos
docker run -d -p 8080:80 nginx
docker run -d -p 127.0.0.1:8080:80 nginx  # Solo localhost

# Ejecutar con variables de entorno
docker run -d -e MYSQL_ROOT_PASSWORD=secret mysql
docker run -d --env-file ./env.list mysql

# Ejecutar con volumen
docker run -d -v /host/path:/container/path nginx
docker run -d -v my-volume:/app/data nginx

# Ejecutar en modo interactivo
docker run -it ubuntu bash
docker run -it --rm ubuntu bash  # Eliminar al salir

# Ejecutar con límites de recursos
docker run -d --memory="512m" --cpus="1.5" nginx
docker run -d --memory="1g" --memory-swap="2g" nginx

# Ejecutar con política de reinicio
docker run -d --restart=always nginx
docker run -d --restart=unless-stopped nginx
docker run -d --restart=on-failure:5 nginx

# Ejecutar en red específica
docker run -d --network my-network nginx

# Ejecutar como usuario específico
docker run -d --user 1000:1000 nginx

# Ejecutar con hostname personalizado
docker run -d --hostname myhost nginx

# Ejecutar con working directory
docker run -d -w /app nginx

# Ejecutar con health check
docker run -d --health-cmd="curl -f http://localhost/ || exit 1" \
  --health-interval=30s --health-timeout=10s --health-retries=3 nginx

# Ejecutar con labels
docker run -d --label env=production --label version=1.0 nginx

# Ejecutar en modo read-only
docker run -d --read-only nginx

# Ejecutar con capabilities específicas
docker run -d --cap-add=NET_ADMIN nginx
docker run -d --cap-drop=ALL nginx
```

### `docker ps`
Lista los contenedores.

```bash
# Listar contenedores en ejecución
docker ps

# Listar todos los contenedores (incluidos detenidos)
docker ps -a

# Listar solo IDs
docker ps -q
docker ps -aq  # Todos incluidos detenidos

# Listar últimos N contenedores
docker ps -n 5

# Formato personalizado
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
docker ps --format "{{.ID}}: {{.Names}}"

# Filtrar contenedores
docker ps --filter "status=running"
docker ps --filter "status=exited"
docker ps --filter "name=nginx"
docker ps --filter "label=env=production"
docker ps --filter "ancestor=nginx"

# Sin truncar salida
docker ps --no-trunc

# Mostrar tamaño de contenedores
docker ps -s
```

### `docker start`
Inicia uno o más contenedores detenidos.

```bash
# Iniciar contenedor
docker start my-container

# Iniciar y adjuntar a output
docker start -a my-container

# Iniciar y adjuntar a output interactivo
docker start -ai my-container

# Iniciar múltiples contenedores
docker start container1 container2 container3

# Iniciar todos los contenedores detenidos
docker start $(docker ps -aq -f status=exited)
```

### `docker stop`
Detiene uno o más contenedores en ejecución.

```bash
# Detener contenedor (SIGTERM, luego SIGKILL después de 10s)
docker stop my-container

# Detener con timeout personalizado
docker stop -t 30 my-container

# Detener múltiples contenedores
docker stop container1 container2 container3

# Detener todos los contenedores
docker stop $(docker ps -q)
```

### `docker restart`
Reinicia uno o más contenedores.

```bash
# Reiniciar contenedor
docker restart my-container

# Reiniciar con timeout
docker restart -t 30 my-container

# Reiniciar múltiples contenedores
docker restart container1 container2 container3
```

### `docker kill`
Mata un contenedor enviando SIGKILL o señal específica.

```bash
# Matar contenedor (SIGKILL)
docker kill my-container

# Enviar señal específica
docker kill -s SIGTERM my-container
docker kill -s SIGHUP my-container

# Matar todos los contenedores
docker kill $(docker ps -q)
```

### `docker exec`
Ejecuta un comando en un contenedor en ejecución.

```bash
# Ejecutar comando simple
docker exec my-container ls /app

# Ejecutar comando interactivo con shell
docker exec -it my-container bash
docker exec -it my-container sh

# Ejecutar como usuario específico
docker exec -u root my-container apt-get update

# Ejecutar con variables de entorno
docker exec -e VAR=value my-container env

# Ejecutar en directorio específico
docker exec -w /app my-container npm test

# Ejecutar con privilegios
docker exec --privileged my-container command

# Ejecutar sin asignar TTY (útil en scripts)
docker exec -T my-container cat file.txt
```

### `docker logs`
Obtiene logs de un contenedor.

```bash
# Ver logs completos
docker logs my-container

# Seguir logs en tiempo real (follow)
docker logs -f my-container

# Mostrar últimas N líneas
docker logs --tail 100 my-container
docker logs --tail 50 -f my-container

# Mostrar logs con timestamps
docker logs -t my-container

# Ver logs desde un tiempo específico
docker logs --since 30m my-container
docker logs --since 2025-01-01T00:00:00 my-container

# Ver logs hasta un tiempo específico
docker logs --until 2025-01-02T00:00:00 my-container

# Ver logs entre dos tiempos
docker logs --since 2025-01-01 --until 2025-01-02 my-container

# Incluir stderr y stdout
docker logs my-container 2>&1

# Ver logs de todos los contenedores
docker ps -q | xargs -I {} docker logs {}
```

### `docker attach`
Adjunta entrada/salida/error estándar a un contenedor en ejecución.

```bash
# Adjuntar a contenedor
docker attach my-container

# Adjuntar sin proxy de señales
docker attach --sig-proxy=false my-container

# Adjuntar sin reenvío de stdin
docker attach --no-stdin my-container

# Nota: Para desconectar sin detener el contenedor usa: CTRL+P, CTRL+Q
```

### `docker rm`
Elimina uno o más contenedores.

```bash
# Eliminar contenedor detenido
docker rm my-container

# Forzar eliminación de contenedor en ejecución
docker rm -f my-container

# Eliminar múltiples contenedores
docker rm container1 container2 container3

# Eliminar contenedor y sus volúmenes anónimos
docker rm -v my-container

# Eliminar todos los contenedores detenidos
docker rm $(docker ps -aq -f status=exited)

# Eliminar todos los contenedores (forzar)
docker rm -f $(docker ps -aq)
```

### `docker pause`
Pausa todos los procesos dentro de un contenedor.

```bash
# Pausar contenedor
docker pause my-container

# Pausar múltiples contenedores
docker pause container1 container2
```

### `docker unpause`
Reanuda todos los procesos dentro de un contenedor pausado.

```bash
# Reanudar contenedor
docker unpause my-container

# Reanudar múltiples contenedores
docker unpause container1 container2
```

### `docker rename`
Renombra un contenedor.

```bash
# Renombrar contenedor
docker rename old-name new-name
```

### `docker cp`
Copia archivos/directorios entre contenedor y host.

```bash
# Copiar archivo del host al contenedor
docker cp /host/file.txt my-container:/container/path/

# Copiar archivo del contenedor al host
docker cp my-container:/container/file.txt /host/path/

# Copiar directorio completo
docker cp /host/directory my-container:/app/

# Copiar del contenedor al host con preservación de permisos
docker cp -a my-container:/app/logs /host/backup/

# Copiar desde contenedor detenido
docker cp stopped-container:/data ./backup/
```

### `docker create`
Crea un nuevo contenedor sin iniciarlo.

```bash
# Crear contenedor
docker create --name my-container nginx

# Crear con todas las opciones de run
docker create -p 8080:80 -e ENV=prod --name web nginx

# Crear e iniciar después
docker create --name db mysql
docker start db
```

### `docker wait`
Bloquea hasta que uno o más contenedores se detengan.

```bash
# Esperar a que contenedor termine
docker wait my-container

# Esperar múltiples contenedores (devuelve código de salida)
docker wait container1 container2

# Usar en scripts
EXIT_CODE=$(docker wait my-container)
echo "Exit code: $EXIT_CODE"
```

### `docker update`
Actualiza configuración de recursos de contenedores.

```bash
# Actualizar límites de memoria
docker update --memory="1g" my-container

# Actualizar CPU
docker update --cpus="2" my-container
docker update --cpu-shares=512 my-container

# Actualizar restart policy
docker update --restart=always my-container

# Actualizar múltiples contenedores
docker update --memory="512m" --cpus="1" container1 container2

# Actualizar límites de PIDs
docker update --pids-limit=200 my-container
```

### `docker port`
Lista mapeos de puertos o búsqueda específica para un contenedor.

```bash
# Ver todos los puertos mapeados
docker port my-container

# Ver mapeo de puerto específico
docker port my-container 80

# Ver puerto TCP específico
docker port my-container 80/tcp
```

### `docker top`
Muestra los procesos en ejecución de un contenedor.

```bash
# Ver procesos del contenedor
docker top my-container

# Ver procesos con formato ps completo
docker top my-container aux

# Ver procesos con formato personalizado
docker top my-container -eo pid,cmd
```

### `docker diff`
Inspecciona cambios en archivos o directorios en el filesystem de un contenedor.

```bash
# Ver cambios en el filesystem
docker diff my-container

# A = Añadido
# D = Eliminado
# C = Cambiado
```

### `docker export`
Exporta el filesystem de un contenedor como archivo tar.

```bash
# Exportar contenedor
docker export my-container > container-backup.tar

# Exportar con opción -o
docker export -o container-backup.tar my-container

# Exportar contenedor detenido
docker export stopped-container > backup.tar
```

### `docker commit`
Crea una nueva imagen desde los cambios de un contenedor.

```bash
# Crear imagen desde contenedor
docker commit my-container myimage:v1

# Con mensaje y autor
docker commit -m "Added config files" -a "DevOps Team" my-container myimage:v1

# Sin pausar el contenedor
docker commit --pause=false my-container myimage:v1

# Con cambios de configuración
docker commit --change='CMD ["nginx", "-g", "daemon off;"]' my-container myimage:v1
```

---

## Gestión de Volúmenes

### `docker volume create`
Crea un volumen.

```bash
# Crear volumen con nombre
docker volume create my-volume

# Crear con driver específico
docker volume create --driver local my-volume

# Crear con opciones de driver
docker volume create \
  --driver local \
  --opt type=nfs \
  --opt o=addr=192.168.1.100,rw \
  --opt device=:/path/to/dir \
  my-nfs-volume

# Crear con labels
docker volume create --label env=production --label backup=daily my-volume
```

### `docker volume ls`
Lista volúmenes.

```bash
# Listar todos los volúmenes
docker volume ls

# Filtrar volúmenes dangling
docker volume ls --filter "dangling=true"

# Filtrar por label
docker volume ls --filter "label=env=production"

# Filtrar por driver
docker volume ls --filter "driver=local"

# Formato personalizado
docker volume ls --format "{{.Name}}: {{.Driver}}"
docker volume ls --format "table {{.Name}}\t{{.Driver}}\t{{.Mountpoint}}"

# Listar solo nombres
docker volume ls -q
```

### `docker volume inspect`
Muestra información detallada de uno o más volúmenes.

```bash
# Inspeccionar volumen
docker volume inspect my-volume

# Inspeccionar múltiples volúmenes
docker volume inspect volume1 volume2

# Formato específico
docker volume inspect --format '{{.Mountpoint}}' my-volume
docker volume inspect --format '{{json .Labels}}' my-volume

# Ver solo el driver
docker volume inspect --format '{{.Driver}}' my-volume
```

### `docker volume rm`
Elimina uno o más volúmenes.

```bash
# Eliminar volumen
docker volume rm my-volume

# Eliminar múltiples volúmenes
docker volume rm volume1 volume2 volume3

# Eliminar todos los volúmenes dangling
docker volume rm $(docker volume ls -q --filter "dangling=true")

# Forzar eliminación (no disponible, debe detener contenedores primero)
```

### `docker volume prune`
Elimina volúmenes no utilizados.

```bash
# Eliminar volúmenes no usados (con confirmación)
docker volume prune

# Sin confirmación
docker volume prune -f

# Filtrar por label
docker volume prune --filter "label=temporary=true"

# Ver qué se eliminará sin hacerlo
docker volume prune --dry-run
```

---

## Gestión de Redes

### `docker network create`
Crea una red.

```bash
# Crear red bridge básica
docker network create my-network

# Crear con driver específico
docker network create --driver bridge my-bridge

# Crear con subnet personalizada
docker network create --subnet=172.20.0.0/16 my-network

# Crear con gateway
docker network create \
  --subnet=172.20.0.0/16 \
  --gateway=172.20.0.1 \
  my-network

# Crear con rango de IPs
docker network create \
  --subnet=172.20.0.0/16 \
  --ip-range=172.20.10.0/24 \
  my-network

# Crear red overlay (requiere Swarm)
docker network create --driver overlay my-overlay

# Crear con opciones personalizadas
docker network create \
  --driver bridge \
  --opt com.docker.network.bridge.name=my-bridge \
  --opt com.docker.network.bridge.enable_icc=true \
  my-network

# Crear con labels
docker network create --label env=production my-network

# Crear red interna (sin acceso externo)
docker network create --internal my-internal-net

# Crear con IPv6
docker network create --ipv6 --subnet=2001:db8::/64 my-ipv6-net
```

### `docker network ls`
Lista redes.

```bash
# Listar todas las redes
docker network ls

# Filtrar por driver
docker network ls --filter "driver=bridge"
docker network ls --filter "driver=overlay"

# Filtrar por nombre
docker network ls --filter "name=my"

# Filtrar por label
docker network ls --filter "label=env=production"

# Formato personalizado
docker network ls --format "{{.Name}}: {{.Driver}}"
docker network ls --format "table {{.Name}}\t{{.Driver}}\t{{.Scope}}"

# Sin truncar
docker network ls --no-trunc

# Listar solo IDs
docker network ls -q
```

### `docker network inspect`
Muestra información detallada de una o más redes.

```bash
# Inspeccionar red
docker network inspect my-network

# Inspeccionar múltiples redes
docker network inspect bridge host

# Ver contenedores conectados
docker network inspect --format='{{range .Containers}}{{.Name}} {{end}}' my-network

# Ver subnet y gateway
docker network inspect --format='{{range .IPAM.Config}}{{.Subnet}} {{.Gateway}}{{end}}' my-network

# Formato JSON pretty
docker network inspect my-network | jq
```

### `docker network connect`
Conecta un contenedor a una red.

```bash
# Conectar contenedor a red
docker network connect my-network my-container

# Conectar con IP específica
docker network connect --ip 172.20.0.10 my-network my-container

# Conectar con IPv6
docker network connect --ip6 2001:db8::10 my-network my-container

# Conectar con alias
docker network connect --alias db my-network mysql-container
docker network connect --alias web --alias www my-network web-container

# Conectar con link (legacy)
docker network connect --link other-container:alias my-network my-container
```

### `docker network disconnect`
Desconecta un contenedor de una red.

```bash
# Desconectar contenedor de red
docker network disconnect my-network my-container

# Forzar desconexión
docker network disconnect -f my-network my-container
```

### `docker network rm`
Elimina una o más redes.

```bash
# Eliminar red
docker network rm my-network

# Eliminar múltiples redes
docker network rm network1 network2 network3

# No se pueden eliminar redes predeterminadas (bridge, host, none)
```

### `docker network prune`
Elimina redes no utilizadas.

```bash
# Eliminar redes no usadas
docker network prune

# Sin confirmación
docker network prune -f

# Filtrar por tiempo
docker network prune --filter "until=24h"

# Filtrar por label
docker network prune --filter "label=temporary=true"
```

---

## Docker Compose

### `docker compose up`
Crea e inicia contenedores definidos en docker-compose.yml.

```bash
# Iniciar servicios
docker compose up

# Iniciar en modo detached (background)
docker compose up -d

# Reconstruir imágenes antes de iniciar
docker compose up --build

# Iniciar sin reconstruir imágenes
docker compose up --no-build

# Forzar recreación de contenedores
docker compose up --force-recreate

# No recrear contenedores existentes
docker compose up --no-recreate

# No iniciar servicios dependientes
docker compose up --no-deps web

# Escalar servicios
docker compose up -d --scale web=3 --scale worker=5

# Usar archivo compose específico
docker compose -f docker-compose.prod.yml up -d

# Múltiples archivos compose
docker compose -f docker-compose.yml -f docker-compose.override.yml up -d

# Timeout personalizado para shutdown
docker compose up -d --timeout 30

# Eliminar contenedores huérfanos
docker compose up -d --remove-orphans

# Iniciar servicios específicos
docker compose up -d web db
```

### `docker compose down`
Detiene y elimina contenedores, redes, volúmenes e imágenes.

```bash
# Detener y eliminar contenedores y redes
docker compose down

# Eliminar también volúmenes
docker compose down -v
docker compose down --volumes

# Eliminar también imágenes
docker compose down --rmi local  # Solo imágenes sin tag
docker compose down --rmi all    # Todas las imágenes

# Timeout personalizado
docker compose down -t 30
docker compose down --timeout 30

# Eliminar contenedores huérfanos
docker compose down --remove-orphans
```

### `docker compose ps`
Lista contenedores de servicios.

```bash
# Listar servicios activos
docker compose ps

# Listar todos los servicios (incluidos detenidos)
docker compose ps -a

# Listar solo IDs
docker compose ps -q

# Formato JSON
docker compose ps --format json

# Ver servicios específicos
docker compose ps web db

# Mostrar todos los contenedores (incluidos one-off)
docker compose ps --all
```

### `docker compose logs`
Muestra logs de servicios.

```bash
# Ver logs de todos los servicios
docker compose logs

# Seguir logs en tiempo real
docker compose logs -f

# Logs de servicio específico
docker compose logs web
docker compose logs web db

# Últimas N líneas
docker compose logs --tail=100
docker compose logs --tail=50 -f

# Con timestamps
docker compose logs -t

# Logs desde un tiempo específico
docker compose logs --since 30m
docker compose logs --since 2025-01-01T00:00:00

# Sin colores
docker compose logs --no-color

# Sin prefijo de nombre de servicio
docker compose logs --no-log-prefix
```

### `docker compose exec`
Ejecuta comando en un servicio en ejecución.

```bash
# Ejecutar comando en servicio
docker compose exec web ls /app

# Shell interactivo
docker compose exec web bash
docker compose exec web sh

# Como usuario específico
docker compose exec -u root web apt-get update

# Con variables de entorno
docker compose exec -e DEBUG=1 web npm test

# Sin asignar TTY (útil en scripts/CI)
docker compose exec -T web pytest

# En directorio específico
docker compose exec -w /app web npm install

# Especificar index de contenedor si hay réplicas
docker compose exec --index=2 web bash
```

### `docker compose build`
Construye o reconstruye servicios.

```bash
# Construir todos los servicios
docker compose build

# Construir servicio específico
docker compose build web

# Construir sin usar caché
docker compose build --no-cache

# Construir en paralelo
docker compose build --parallel

# Construir con argumentos
docker compose build --build-arg ENV=production web

# Construir siempre (pull latest images)
docker compose build --pull

# Construir con progreso detallado
docker compose build --progress plain

# Construir con memoria limitada
docker compose build --memory 2g
```

### `docker compose pull`
Descarga imágenes de servicios.

```bash
# Descargar todas las imágenes
docker compose pull

# Descargar imagen específica
docker compose pull web

# Ignorar errores de pull
docker compose pull --ignore-pull-failures

# Pull en paralelo
docker compose pull --parallel

# Incluir imágenes de build
docker compose pull --include-deps

# Pull silencioso
docker compose pull -q
```

### `docker compose push`
Sube imágenes de servicios a registry.

```bash
# Push de todas las imágenes
docker compose push

# Push de servicio específico
docker compose push web

# Ignorar errores de push
docker compose push --ignore-push-failures
```

### `docker compose start`
Inicia servicios existentes.

```bash
# Iniciar todos los servicios
docker compose start

# Iniciar servicio específico
docker compose start web

# Iniciar múltiples servicios
docker compose start web db redis
```

### `docker compose stop`
Detiene servicios en ejecución sin eliminarlos.

```bash
# Detener todos los servicios
docker compose stop

# Detener servicio específico
docker compose stop web

# Detener con timeout
docker compose stop -t 30
docker compose stop --timeout 30

# Detener múltiples servicios
docker compose stop web worker
```

### `docker compose restart`
Reinicia servicios.

```bash
# Reiniciar todos los servicios
docker compose restart

# Reiniciar servicio específico
docker compose restart web

# Reiniciar con timeout
docker compose restart -t 30

# Reiniciar múltiples servicios
docker compose restart web db
```

### `docker compose pause`
Pausa servicios.

```bash
# Pausar todos los servicios
docker compose pause

# Pausar servicio específico
docker compose pause web
```

### `docker compose unpause`
Reanuda servicios pausados.

```bash
# Reanudar todos los servicios
docker compose unpause

# Reanudar servicio específico
docker compose unpause web
```

### `docker compose kill`
Fuerza detención de servicios enviando SIGKILL.

```bash
# Matar todos los servicios
docker compose kill

# Matar servicio específico
docker compose kill web

# Enviar señal específica
docker compose kill -s SIGTERM web
docker compose kill -s SIGHUP nginx
```

### `docker compose rm`
Elimina contenedores detenidos.

```bash
# Eliminar contenedores detenidos
docker compose rm

# Forzar eliminación sin confirmación
docker compose rm -f

# Eliminar también volúmenes anónimos
docker compose rm -v

# Eliminar contenedores detenidos
docker compose rm -s

# Eliminar servicio específico
docker compose rm web
```

### `docker compose config`
Valida y muestra la configuración de Compose.

```bash
# Validar y mostrar configuración
docker compose config

# Validar sin mostrar
docker compose config -q

# Resolver variables e interpolar
docker compose config --resolve-image-digests

# Listar servicios
docker compose config --services

# Listar volúmenes
docker compose config --volumes

# Listar perfiles
docker compose config --profiles

# Output en formato JSON
docker compose config --format json

# Ver solo un servicio
docker compose config web
```

### `docker compose top`
Muestra procesos en ejecución.

```bash
# Ver procesos de todos los servicios
docker compose top

# Ver procesos de servicio específico
docker compose top web
```

### `docker compose port`
Muestra puerto público de un servicio.

```bash
# Ver puerto público para un servicio
docker compose port web 80

# Especificar protocolo
docker compose port web 80/tcp

# Ver con index de réplica
docker compose port --index=1 web 80
```

### `docker compose images`
Lista imágenes usadas por servicios.

```bash
# Listar imágenes de todos los servicios
docker compose images

# Listar imágenes de servicio específico
docker compose images web

# Formato JSON
docker compose images --format json
```

### `docker compose run`
Ejecuta comando one-off en un servicio.

```bash
# Ejecutar comando en nuevo contenedor
docker compose run web bash

# Sin iniciar servicios dependientes
docker compose run --no-deps web python script.py

# Eliminar contenedor después de ejecutar
docker compose run --rm web pytest

# Publicar puertos
docker compose run -p 8080:80 web

# Con variables de entorno
docker compose run -e DEBUG=1 web npm test

# Como usuario específico
docker compose run -u root web bash

# Sin asignar TTY
docker compose run -T web pytest

# Nombrar el contenedor
docker compose run --name test-container web pytest

# Con volumen adicional
docker compose run -v /host:/container web command
```

### `docker compose create`
Crea contenedores sin iniciarlos.

```bash
# Crear contenedores para todos los servicios
docker compose create

# Crear para servicio específico
docker compose create web

# Forzar recreación
docker compose create --force-recreate

# No recrear si ya existen
docker compose create --no-recreate

# Construir imágenes antes de crear
docker compose create --build
```

### `docker compose events`
Recibe eventos en tiempo real de contenedores.

```bash
# Ver eventos de todos los servicios
docker compose events

# Ver eventos de servicio específico
docker compose events web

# Formato JSON
docker compose events --json
```

### `docker compose version`
Muestra información de versión de Docker Compose.

```bash
# Ver versión completa
docker compose version

# Solo número de versión
docker compose version --short

# Formato JSON
docker compose version --format json
```

---

## Docker Swarm

### `docker swarm init`
Inicializa un swarm.

```bash
# Inicializar swarm simple
docker swarm init

# Especificar IP de anuncio
docker swarm init --advertise-addr 192.168.1.100

# Con puerto personalizado
docker swarm init --advertise-addr 192.168.1.100:2377

# Especificar listen address
docker swarm init --listen-addr 0.0.0.0:2377

# Con autolock habilitado
docker swarm init --autolock

# Forzar nueva cluster
docker swarm init --force-new-cluster
```

### `docker swarm join`
Une un nodo al swarm.

```bash
# Unirse como worker
docker swarm join --token SWMTKN-1-xxxxx 192.168.1.100:2377

# Unirse como manager
docker swarm join --token SWMTKN-1-xxxxx --advertise-addr 192.168.1.101 192.168.1.100:2377

# Con listen address específica
docker swarm join --token TOKEN --listen-addr 0.0.0.0:2377 HOST:2377
```

### `docker swarm join-token`
Gestiona tokens de unión.

```bash
# Obtener token para workers
docker swarm join-token worker

# Obtener token para managers
docker swarm join-token manager

# Mostrar solo el token
docker swarm join-token -q worker

# Rotar token de workers
docker swarm join-token --rotate worker

# Rotar token de managers
docker swarm join-token --rotate manager
```

### `docker swarm leave`
Abandona el swarm.

```bash
# Abandonar swarm (como worker)
docker swarm leave

# Forzar abandono (como manager)
docker swarm leave --force
```

### `docker swarm update`
Actualiza configuración del swarm.

```bash
# Actualizar certificados
docker swarm update --cert-expiry 720h

# Actualizar heartbeat
docker swarm update --dispatcher-heartbeat 10s

# Actualizar autolock
docker swarm update --autolock=true
docker swarm update --autolock=false
```

### `docker swarm unlock`
Desbloquea un swarm bloqueado.

```bash
# Desbloquear swarm
docker swarm unlock
# Luego ingresar la clave de desbloqueo
```

### `docker swarm unlock-key`
Gestiona clave de desbloqueo.

```bash
# Ver clave de desbloqueo actual
docker swarm unlock-key

# Mostrar solo la clave
docker swarm unlock-key -q

# Rotar clave de desbloqueo
docker swarm unlock-key --rotate
```

### `docker node ls`
Lista nodos en el swarm.

```bash
# Listar todos los nodos
docker node ls

# Filtrar por role
docker node ls --filter "role=manager"
docker node ls --filter "role=worker"

# Filtrar por nombre
docker node ls --filter "name=node1"

# Formato personalizado
docker node ls --format "{{.Hostname}}: {{.Status}}"
docker node ls --format "table {{.Hostname}}\t{{.Status}}\t{{.Availability}}"

# Sin truncar
docker node ls --no-trunc

# Listar solo IDs
docker node ls -q
```

### `docker node inspect`
Muestra información detallada de uno o más nodos.

```bash
# Inspeccionar nodo
docker node inspect node-name

# Inspeccionar múltiples nodos
docker node inspect node1 node2

# Formato específico
docker node inspect --format '{{.Status.State}}' node-name
docker node inspect --format '{{json .Spec.Labels}}' node-name

# Pretty print con jq
docker node inspect node-name | jq
```

### `docker node update`
Actualiza un nodo.

```bash
# Cambiar disponibilidad a drain (no acepta nuevas tareas)
docker node update --availability drain node-name

# Cambiar a active
docker node update --availability active node-name

# Cambiar a pause (no acepta nuevas tareas pero mantiene las existentes)
docker node update --availability pause node-name

# Agregar label
docker node update --label-add environment=production node-name
docker node update --label-add datacenter=dc1 node-name

# Eliminar label
docker node update --label-rm environment node-name

# Cambiar role a manager
docker node promote node-name

# Cambiar role a worker
docker node demote node-name
```

### `docker node promote`
Promueve uno o más nodos a manager.

```bash
# Promover nodo a manager
docker node promote node-name

# Promover múltiples nodos
docker node promote node1 node2 node3
```

### `docker node demote`
Degrada uno o más nodos a worker.

```bash
# Degradar nodo a worker
docker node demote node-name

# Degradar múltiples nodos
docker node demote node1 node2 node3
```

### `docker node rm`
Elimina uno o más nodos del swarm.

```bash
# Eliminar nodo (debe estar down o drained)
docker node rm node-name

# Forzar eliminación
docker node rm -f node-name

# Eliminar múltiples nodos
docker node rm node1 node2 node3
```

### `docker node ps`
Lista tareas ejecutándose en uno o más nodos.

```bash
# Ver tareas en un nodo
docker node ps node-name

# Ver tareas en nodo actual
docker node ps self

# Ver todas las tareas (incluidas detenidas)
docker node ps -a node-name

# Filtrar por estado
docker node ps --filter "desired-state=running" node-name

# Formato personalizado
docker node ps --format "{{.Name}}: {{.CurrentState}}" node-name
```

### `docker service create`
Crea un nuevo servicio.

```bash
# Crear servicio básico
docker service create --name web nginx

# Con réplicas
docker service create --name web --replicas 3 nginx

# Con puertos publicados
docker service create --name web -p 8080:80 nginx

# Con variables de entorno
docker service create --name db -e MYSQL_ROOT_PASSWORD=secret mysql

# Con volumen
docker service create --name web --mount type=volume,source=data,target=/data nginx

# Con bind mount
docker service create --name web --mount type=bind,source=/host/path,target=/container/path nginx

# Con secretos
docker service create --name db --secret db-password mysql

# Con configs
docker service create --name web --config source=nginx-config,target=/etc/nginx/nginx.conf nginx

# En red específica
docker service create --name web --network backend nginx

# Con constraints (solo en nodos con label específico)
docker service create --name web --constraint 'node.labels.environment==production' nginx

# Con límites de recursos
docker service create --name web \
  --limit-memory 512M \
  --limit-cpu 0.5 \
  --reserve-memory 256M \
  --reserve-cpu 0.25 \
  nginx

# Con update config
docker service create --name web \
  --update-delay 10s \
  --update-parallelism 2 \
  --update-failure-action rollback \
  nginx

# Con rollback config
docker service create --name web \
  --rollback-parallelism 1 \
  --rollback-delay 5s \
  nginx

# Con restart policy
docker service create --name web \
  --restart-condition on-failure \
  --restart-max-attempts 3 \
  --restart-delay 5s \
  nginx

# Con healthcheck
docker service create --name web \
  --health-cmd "curl -f http://localhost/ || exit 1" \
  --health-interval 30s \
  --health-timeout 10s \
  --health-retries 3 \
  nginx

# Con hostname
docker service create --name web --hostname myhost nginx

# Con labels
docker service create --name web \
  --label env=production \
  --label version=1.0 \
  nginx

# Modo global (una réplica por nodo)
docker service create --name monitoring --mode global prometheus
```

### `docker service ls`
Lista servicios.

```bash
# Listar todos los servicios
docker service ls

# Filtrar por nombre
docker service ls --filter "name=web"

# Filtrar por label
docker service ls --filter "label=env=production"

# Filtrar por mode
docker service ls --filter "mode=replicated"
docker service ls --filter "mode=global"

# Formato personalizado
docker service ls --format "{{.Name}}: {{.Replicas}}"
docker service ls --format "table {{.Name}}\t{{.Mode}}\t{{.Replicas}}"

# Sin truncar
docker service ls --no-trunc

# Listar solo IDs
docker service ls -q
```

### `docker service inspect`
Muestra información detallada de uno o más servicios.

```bash
# Inspeccionar servicio
docker service inspect web

# Inspeccionar múltiples servicios
docker service inspect web db cache

# Formato específico
docker service inspect --format '{{.Spec.Mode}}' web
docker service inspect --format '{{json .Spec.TaskTemplate}}' web | jq

# Pretty print
docker service inspect --pretty web
```

### `docker service ps`
Lista tareas de uno o más servicios.

```bash
# Ver tareas de un servicio
docker service ps web

# Ver todas las tareas (incluidas detenidas)
docker service ps -a web

# Filtrar por estado
docker service ps --filter "desired-state=running" web
docker service ps --filter "desired-state=shutdown" web

# Filtrar por nodo
docker service ps --filter "node=worker1" web

# Formato personalizado
docker service ps --format "{{.Name}}: {{.CurrentState}}" web

# Sin truncar
docker service ps --no-trunc web

# Sin resolver nombres
docker service ps --no-resolve web
```

### `docker service logs`
Obtiene logs de un servicio o tarea.

```bash
# Ver logs de servicio
docker service logs web

# Seguir logs en tiempo real
docker service logs -f web

# Últimas N líneas
docker service logs --tail 100 web

# Con timestamps
docker service logs -t web

# Desde un tiempo específico
docker service logs --since 30m web

# Logs de tarea específica
docker service logs web.1

# Sin truncar
docker service logs --no-trunc web

# Raw output (sin prefijos)
docker service logs --raw web
```

### `docker service update`
Actualiza un servicio.

```bash
# Actualizar imagen
docker service update --image nginx:1.21 web

# Actualizar réplicas (escalar)
docker service scale web=5
docker service update --replicas 5 web

# Actualizar variables de entorno
docker service update --env-add NEW_VAR=value web
docker service update --env-rm OLD_VAR web

# Actualizar puertos
docker service update --publish-add 8081:80 web
docker service update --publish-rm 8080:80 web

# Actualizar secretos
docker service update --secret-add new-secret web
docker service update --secret-rm old-secret web

# Actualizar configs
docker service update --config-add nginx-config web
docker service update --config-rm old-config web

# Actualizar constraints
docker service update --constraint-add 'node.role==worker' web
docker service update --constraint-rm 'node.labels.old==value' web

# Actualizar límites de recursos
docker service update --limit-memory 1g web
docker service update --reserve-cpu 1 web

# Actualizar update config
docker service update --update-delay 20s web
docker service update --update-parallelism 3 web

# Forzar actualización (recrear tareas)
docker service update --force web

# Rollback a versión anterior
docker service rollback web

# Actualizar con detach (no esperar convergencia)
docker service update --detach web
```

### `docker service scale`
Escala uno o más servicios.

```bash
# Escalar servicio
docker service scale web=5

# Escalar múltiples servicios
docker service scale web=5 worker=3 cache=2

# Con detach
docker service scale --detach web=10
```

### `docker service rollback`
Revierte cambios a un servicio.

```bash
# Rollback a versión anterior
docker service rollback web

# Con detach
docker service rollback --detach web
```

### `docker service rm`
Elimina uno o más servicios.

```bash
# Eliminar servicio
docker service rm web

# Eliminar múltiples servicios
docker service rm web worker cache

# Eliminar todos los servicios
docker service rm $(docker service ls -q)
```

### `docker stack deploy`
Despliega un nuevo stack o actualiza uno existente.

```bash
# Deploy stack desde compose file
docker stack deploy -c docker-compose.yml mystack

# Con múltiples compose files
docker stack deploy -c docker-compose.yml -c docker-compose.prod.yml mystack

# Con resolución de imágenes
docker stack deploy --resolve-image always -c docker-compose.yml mystack

# Con namespace específico
docker stack deploy --namespace custom -c docker-compose.yml mystack

# Con prune (eliminar servicios no definidos)
docker stack deploy --prune -c docker-compose.yml mystack

# Con detach
docker stack deploy --detach -c docker-compose.yml mystack
```

### `docker stack ls`
Lista stacks.

```bash
# Listar todos los stacks
docker stack ls

# Formato personalizado
docker stack ls --format "{{.Name}}: {{.Services}}"
```

### `docker stack ps`
Lista tareas de un stack.

```bash
# Ver tareas del stack
docker stack ps mystack

# Ver todas las tareas (incluidas detenidas)
docker stack ps -a mystack

# Filtrar por estado
docker stack ps --filter "desired-state=running" mystack

# Sin truncar
docker stack ps --no-trunc mystack

# Formato personalizado
docker stack ps --format "{{.Name}}: {{.CurrentState}}" mystack
```

### `docker stack services`
Lista servicios de un stack.

```bash
# Ver servicios del stack
docker stack services mystack

# Filtrar por nombre
docker stack services --filter "name=web" mystack

# Formato personalizado
docker stack services --format "{{.Name}}: {{.Replicas}}" mystack
```

### `docker stack rm`
Elimina uno o más stacks.

```bash
# Eliminar stack
docker stack rm mystack

# Eliminar múltiples stacks
docker stack rm stack1 stack2 stack3
```

### `docker secret create`
Crea un secret desde archivo o stdin.

```bash
# Crear secret desde archivo
docker secret create db-password ./password.txt

# Crear desde stdin
echo "mypassword" | docker secret create db-password -

# Con labels
docker secret create --label env=production db-password ./password.txt

# Con template driver
docker secret create --template-driver golang db-password ./password.txt
```

### `docker secret ls`
Lista secrets.

```bash
# Listar todos los secrets
docker secret ls

# Filtrar por nombre
docker secret ls --filter "name=db"

# Filtrar por label
docker secret ls --filter "label=env=production"

# Formato personalizado
docker secret ls --format "{{.Name}}: {{.CreatedAt}}"

# Listar solo IDs
docker secret ls -q
```

### `docker secret inspect`
Muestra información detallada de uno o más secrets.

```bash
# Inspeccionar secret (no muestra el valor)
docker secret inspect db-password

# Inspeccionar múltiples secrets
docker secret inspect secret1 secret2

# Formato específico
docker secret inspect --format '{{.Spec.Name}}' db-password

# Pretty print
docker secret inspect --pretty db-password
```

### `docker secret rm`
Elimina uno o más secrets.

```bash
# Eliminar secret
docker secret rm db-password

# Eliminar múltiples secrets
docker secret rm secret1 secret2 secret3
```

### `docker config create`
Crea una config desde archivo o stdin.

```bash
# Crear config desde archivo
docker config create nginx-config ./nginx.conf

# Crear desde stdin
cat nginx.conf | docker config create nginx-config -

# Con labels
docker config create --label version=1.0 nginx-config ./nginx.conf

# Con template driver
docker config create --template-driver golang app-config ./config.tmpl
```

### `docker config ls`
Lista configs.

```bash
# Listar todas las configs
docker config ls

# Filtrar por nombre
docker config ls --filter "name=nginx"

# Filtrar por label
docker config ls --filter "label=version=1.0"

# Formato personalizado
docker config ls --format "{{.Name}}: {{.CreatedAt}}"

# Listar solo IDs
docker config ls -q
```

### `docker config inspect`
Muestra información detallada de una o más configs.

```bash
# Inspeccionar config
docker config inspect nginx-config

# Inspeccionar múltiples configs
docker config inspect config1 config2

# Formato específico
docker config inspect --format '{{.Spec.Data}}' nginx-config

# Pretty print
docker config inspect --pretty nginx-config
```

### `docker config rm`
Elimina una o más configs.

```bash
# Eliminar config
docker config rm nginx-config

# Eliminar múltiples configs
docker config rm config1 config2 config3
```

---

## Registro y Repositorios

### `docker login`
Inicia sesión en un registro de Docker.

```bash
# Login a Docker Hub (interactivo)
docker login

# Login con usuario y contraseña
docker login -u username -p password

# Login a registro privado
docker login registry.company.com

# Login con stdin (seguro para CI/CD)
echo $PASSWORD | docker login -u username --password-stdin

# Login a registro con puerto
docker login registry.company.com:5000
```

### `docker logout`
Cierra sesión de un registro.

```bash
# Logout de Docker Hub
docker logout

# Logout de registro específico
docker logout registry.company.com

# Logout de todos los registros
docker logout --all
```

### `docker push`
Sube una imagen o repositorio a un registro.

```bash
# Push a Docker Hub
docker push username/myapp:1.0

# Push a registro privado
docker push registry.company.com/myapp:1.0

# Push de todas las tags de un repositorio
docker push --all-tags username/myapp

# Push con content trust deshabilitado
docker push --disable-content-trust username/myapp:1.0

# Push silencioso
docker push -q username/myapp:1.0
```

### `docker search`
Busca imágenes en Docker Hub.

```bash
# Buscar imagen
docker search nginx

# Limitar resultados
docker search --limit 10 nginx

# Filtrar solo imágenes oficiales
docker search --filter "is-official=true" nginx

# Filtrar por estrellas mínimas
docker search --filter "stars=100" nginx

# Filtrar por automated builds
docker search --filter "is-automated=true" nginx

# Sin truncar descripción
docker search --no-trunc nginx

# Formato personalizado
docker search --format "{{.Name}}: {{.StarCount}}" nginx
```

---

## Inspección y Monitoreo

### `docker inspect`
Devuelve información de bajo nivel sobre objetos Docker.

```bash
# Inspeccionar contenedor
docker inspect my-container

# Inspeccionar imagen
docker inspect nginx:latest

# Inspeccionar volumen
docker inspect my-volume

# Inspeccionar red
docker inspect bridge

# Inspeccionar múltiples objetos
docker inspect container1 container2 image1

# Formato específico - Estado del contenedor
docker inspect --format='{{.State.Status}}' my-container

# IP Address del contenedor
docker inspect --format='{{.NetworkSettings.IPAddress}}' my-container

# Variables de entorno
docker inspect --format='{{range .Config.Env}}{{println .}}{{end}}' my-container

# Mounts/Volúmenes
docker inspect --format='{{json .Mounts}}' my-container | jq

# Puertos mapeados
docker inspect --format='{{json .NetworkSettings.Ports}}' my-container | jq

# Labels
docker inspect --format='{{json .Config.Labels}}' my-container | jq

# Exit code
docker inspect --format='{{.State.ExitCode}}' my-container

# Tamaño de imagen
docker inspect --format='{{.Size}}' nginx:latest

# Tipo de objeto
docker inspect --type container my-container
docker inspect --type image nginx:latest
```

### `docker stats`
Muestra streaming de estadísticas de uso de recursos.

```bash
# Ver stats de todos los contenedores
docker stats

# Stats de contenedores específicos
docker stats container1 container2

# Sin streaming (una sola vez)
docker stats --no-stream

# Incluir todos los contenedores (incluidos detenidos)
docker stats --all

# Sin truncar nombres
docker stats --no-trunc

# Formato personalizado
docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"
docker stats --format "{{.Container}}: {{.CPUPerc}} CPU, {{.MemPerc}} MEM"

# Formato JSON
docker stats --format "{{json .}}"
```

### `docker events`
Obtiene eventos en tiempo real del servidor.

```bash
# Ver todos los eventos
docker events

# Filtrar por tipo de evento
docker events --filter 'event=start'
docker events --filter 'event=stop'
docker events --filter 'event=die'

# Filtrar por tipo de objeto
docker events --filter 'type=container'
docker events --filter 'type=image'
docker events --filter 'type=volume'
docker events --filter 'type=network'

# Filtrar por contenedor
docker events --filter 'container=my-container'

# Filtrar por imagen
docker events --filter 'image=nginx'

# Filtrar por label
docker events --filter 'label=env=production'

# Eventos desde tiempo específico
docker events --since '2025-01-01T00:00:00'
docker events --since '1h'

# Eventos hasta tiempo específico
docker events --until '2025-01-02T00:00:00'

# Formato personalizado
docker events --format '{{json .}}'
docker events --format '{{.Status}}: {{.Actor.Attributes.name}}'
```

### `docker info`
Muestra información del sistema Docker.

```bash
# Ver información completa del sistema
docker info

# Formato específico
docker info --format '{{.ServerVersion}}'
docker info --format '{{json .}}' | jq

# Ver número de contenedores
docker info --format '{{.Containers}}'

# Ver número de imágenes
docker info --format '{{.Images}}'

# Ver storage driver
docker info --format '{{.Driver}}'
```

### `docker version`
Muestra información de versión de Docker.

```bash
# Ver versión completa
docker version

# Solo versión del cliente
docker version --format '{{.Client.Version}}'

# Solo versión del servidor
docker version --format '{{.Server.Version}}'

# Formato JSON
docker version --format '{{json .}}'
```

---

## Limpieza y Mantenimiento

### `docker system df`
Muestra uso de disco de Docker.

```bash
# Ver uso de disco resumido
docker system df

# Vista detallada con información de cada objeto
docker system df -v

# Formato personalizado
docker system df --format "table {{.Type}}\t{{.TotalCount}}\t{{.Size}}"
```

### `docker system prune`
Elimina datos no utilizados (contenedores detenidos, redes no usadas, imágenes dangling, caché de build).

```bash
# Limpieza básica (con confirmación)
docker system prune

# Sin confirmación
docker system prune -f

# Incluir volúmenes no usados
docker system prune --volumes
docker system prune -f --volumes

# Eliminar también imágenes no usadas (no solo dangling)
docker system prune -a
docker system prune -af

# Filtrar por tiempo (más antiguo que)
docker system prune --filter "until=24h"
docker system prune --filter "until=168h"  # 7 días
docker system prune --filter "until=720h"  # 30 días

# Filtrar por label
docker system prune --filter "label=temporary=true"

# Combinado: todo excepto últimas 24h
docker system prune -af --volumes --filter "until=24h"
```

### `docker image prune`
Elimina imágenes no utilizadas.

```bash
# Eliminar solo imágenes dangling
docker image prune

# Sin confirmación
docker image prune -f

# Eliminar todas las imágenes no usadas por contenedores
docker image prune -a

# Sin confirmación, todas las no usadas
docker image prune -af

# Filtrar por tiempo
docker image prune -a --filter "until=168h"

# Filtrar por label
docker image prune --filter "label=stage=build"
```

### `docker container prune`
Elimina todos los contenedores detenidos.

```bash
# Eliminar contenedores detenidos (con confirmación)
docker container prune

# Sin confirmación
docker container prune -f

# Filtrar por tiempo
docker container prune --filter "until=24h"

# Filtrar por label
docker container prune --filter "label=temporary=true"
```

### `docker volume prune`
Elimina volúmenes no usados.

```bash
# Eliminar volúmenes no usados (con confirmación)
docker volume prune

# Sin confirmación
docker volume prune -f

# Filtrar por label
docker volume prune --filter "label=backup=false"

# Filtrar por tiempo
docker volume prune --filter "until=720h"
```

### `docker network prune`
Elimina redes no utilizadas.

```bash
# Eliminar redes no usadas (con confirmación)
docker network prune

# Sin confirmación
docker network prune -f

# Filtrar por tiempo
docker network prune --filter "until=24h"

# Filtrar por label
docker network prune --filter "label=env=dev"
```

### `docker builder prune`
Elimina caché de build.

```bash
# Eliminar caché de build (con confirmación)
docker builder prune

# Sin confirmación
docker builder prune -f

# Eliminar toda la caché (incluida caché en uso)
docker builder prune --all
docker builder prune -af

# Filtrar por tiempo
docker builder prune --filter "until=24h"

# Mantener cierta cantidad de caché (en bytes)
docker builder prune --keep-storage 10GB
```

---

## Docker Build

### `docker buildx`
Constructor extendido con capacidades adicionales.

```bash
# Crear builder instance
docker buildx create --name mybuilder

# Usar builder creado
docker buildx use mybuilder

# Iniciar builder
docker buildx inspect --bootstrap

# Listar builders disponibles
docker buildx ls

# Eliminar builder
docker buildx rm mybuilder

# Build multi-plataforma
docker buildx build --platform linux/amd64,linux/arm64 -t myapp:latest .

# Build y push directamente
docker buildx build --platform linux/amd64,linux/arm64 -t myapp:latest --push .

# Build con caché remoto
docker buildx build \
  --cache-from type=registry,ref=myapp:cache \
  --cache-to type=registry,ref=myapp:cache,mode=max \
  -t myapp:latest .

# Build con output personalizado
docker buildx build --output type=docker -t myapp:latest .
docker buildx build --output type=tar,dest=out.tar .
docker buildx build --output type=local,dest=./output .

# Build con secrets
docker buildx build --secret id=mysecret,src=./secret.txt -t myapp:latest .

# Build con SSH forwarding
docker buildx build --ssh default -t myapp:latest .

# Inspeccionar builder
docker buildx inspect mybuilder
```

### BuildKit Features

```bash
# Habilitar BuildKit
export DOCKER_BUILDKIT=1

# Build con BuildKit y progreso detallado
docker build --progress=plain -t myapp:latest .

# Build con progreso simple (default)
docker build --progress=auto -t myapp:latest .

# Build con progreso tty
docker build --progress=tty -t myapp:latest .

# Build con secrets (BuildKit)
docker build --secret id=aws,src=$HOME/.aws/credentials -t myapp:latest .

# Build con SSH agent forwarding
docker build --ssh default=$SSH_AUTH_SOCK -t myapp:latest .

# Build con output local
docker build --output type=local,dest=./output .

# Build con caché inline
docker build --cache-from myapp:cache -t myapp:latest .

# Build stages específicos
docker build --target production -t myapp:prod .

# Build con network específico
docker build --network=host -t myapp:latest .
```

---

## Seguridad

### `docker scan`
Escanea imágenes en busca de vulnerabilidades.

```bash
# Escanear imagen
docker scan myapp:latest

# Escanear con severidad mínima
docker scan --severity high myapp:latest
docker scan --severity medium myapp:latest

# Escanear y excluir base image
docker scan --exclude-base myapp:latest

# Formato JSON
docker scan --json myapp:latest

# Guardar reporte
docker scan --json myapp:latest > scan-report.json

# Escanear archivo Dockerfile
docker scan --file Dockerfile myapp:latest

# Aceptar términos automáticamente
docker scan --accept-license myapp:latest

# Mostrar dependencias
docker scan --dependency-tree myapp:latest
```

### Content Trust (Firma de Imágenes)

```bash
# Habilitar content trust
export DOCKER_CONTENT_TRUST=1

# Deshabilitar content trust
export DOCKER_CONTENT_TRUST=0

# Pull solo imágenes firmadas
DOCKER_CONTENT_TRUST=1 docker pull nginx:latest

# Push con firma automática
DOCKER_CONTENT_TRUST=1 docker push myapp:latest

# Verificar firmas
docker trust inspect myapp:latest

# Ver firmantes
docker trust inspect --pretty myapp:latest

# Generar keys para firmar
docker trust key generate mykey

# Cargar key
docker trust key load mykey.pem --name mykey

# Firmar imagen
docker trust sign myapp:latest

# Revocar firma
docker trust revoke myapp:latest
```

### Security Options

```bash
# Run con usuario no-root
docker run --user 1000:1000 nginx

# Run en modo read-only
docker run --read-only nginx

# Run con tmpfs para escrituras temporales
docker run --read-only --tmpfs /tmp nginx

# Eliminar capabilities
docker run --cap-drop ALL nginx
docker run --cap-drop NET_ADMIN --cap-drop SYS_ADMIN nginx

# Agregar capabilities específicas
docker run --cap-add NET_ADMIN nginx

# Sin nuevos privilegios
docker run --security-opt=no-new-privileges nginx

# Con AppArmor profile
docker run --security-opt apparmor=docker-default nginx

# Con SELinux labels
docker run --security-opt label=level:s0:c100,c200 nginx

# Deshabilitar SELinux
docker run --security-opt label=disable nginx

# Con Seccomp profile
docker run --security-opt seccomp=./profile.json nginx

# Sin Seccomp
docker run --security-opt seccomp=unconfined nginx
```

### Docker Bench Security

```bash
# Ejecutar audit de seguridad automático
docker run -it --net host --pid host --userns host --cap-add audit_control \
  -e DOCKER_CONTENT_TRUST=$DOCKER_CONTENT_TRUST \
  -v /etc:/etc:ro \
  -v /usr/bin/containerd:/usr/bin/containerd:ro \
  -v /usr/bin/runc:/usr/bin/runc:ro \
  -v /usr/lib/systemd:/usr/lib/systemd:ro \
  -v /var/lib:/var/lib:ro \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  --label docker_bench_security \
  docker/docker-bench-security

# Guardar resultados
docker run --rm --net host --pid host --cap-add audit_control \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  docker/docker-bench-security > security-audit.log
```

### Secrets Management

```bash
# Crear secret desde archivo
docker secret create api_key ./api_key.txt

# Crear secret desde stdin
echo "secret_value" | docker secret create api_key -

# Usar secret en contenedor (solo Swarm)
docker service create \
  --name api \
  --secret api_key \
  myapp:latest

# Secret estará montado en /run/secrets/api_key
```

---

## Troubleshooting

### Diagnóstico de Contenedores

```bash
# Ver logs detallados con timestamps
docker logs -t --tail 1000 my-container

# Ver último error de contenedor que falló
docker logs $(docker ps -lq)

# Ver exit code de contenedor
docker inspect --format='{{.State.ExitCode}}' my-container

# Ver razón de falla
docker inspect --format='{{.State.Status}}' my-container

# Ver última vez que corrió
docker inspect --format='{{.State.FinishedAt}}' my-container

# Ejecutar shell en contenedor con problemas
docker exec -it my-container sh
docker exec -it my-container bash

# Ver procesos del contenedor
docker top my-container

# Ver cambios en filesystem
docker diff my-container

# Copiar logs a archivo local
docker logs my-container > container.log 2>&1

# Ver health status
docker inspect --format='{{.State.Health.Status}}' my-container

# Ver historial de health checks
docker inspect --format='{{range .State.Health.Log}}{{.Output}}{{end}}' my-container
```

### Diagnóstico de Red

```bash
# Ver IP del contenedor
docker inspect --format='{{.NetworkSettings.IPAddress}}' my-container

# Ver todas las IPs (múltiples redes)
docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}} {{end}}' my-container

# Ver puertos expuestos
docker port my-container

# Ping entre contenedores
docker exec container1 ping container2

# Test DNS resolution
docker exec my-container nslookup google.com
docker exec my-container cat /etc/resolv.conf

# Ver tabla de routing
docker exec my-container ip route

# Ver interfaces de red
docker exec my-container ip addr

# Verificar conectividad a puerto
docker exec my-container nc -zv hostname 80
docker exec my-container telnet hostname 80

# Tcpdump en contenedor
docker run --rm --net container:my-container nicolaka/netshoot tcpdump -i any

# Herramientas de debugging de red
docker run --rm --net container:my-container nicolaka/netshoot
# Luego ejecutar: curl, dig, nslookup, netstat, etc.

# Ver estado de conexiones
docker exec my-container netstat -an

# Inspeccionar red
docker network inspect bridge
docker network inspect my-network
```

### Diagnóstico de Volúmenes

```bash
# Ver punto de montaje de volumen
docker volume inspect --format='{{.Mountpoint}}' my-volume

# Ver mounts de un contenedor
docker inspect --format='{{json .Mounts}}' my-container | jq

# Listar archivos en volumen
docker run --rm -v my-volume:/data alpine ls -la /data

# Ver tamaño de volumen
docker run --rm -v my-volume:/data alpine du -sh /data

# Backup de volumen
docker run --rm \
  -v my-volume:/source:ro \
  -v $(pwd):/backup \
  alpine tar czf /backup/volume-backup.tar.gz /source

# Restore de volumen
docker run --rm \
  -v my-volume:/target \
  -v $(pwd):/backup \
  alpine tar xzf /backup/volume-backup.tar.gz -C /target --strip 1

# Verificar permisos en volumen
docker run --rm -v my-volume:/data alpine ls -ln /data

# Copiar contenido de volumen a local
docker cp $(docker create -v my-volume:/data --name temp alpine):/data ./backup
docker rm temp
```

### Diagnóstico de Recursos

```bash
# Ver uso de recursos en tiempo real
docker stats

# Ver uso de recursos de contenedor específico
docker stats my-container --no-stream

# Ver límites de recursos
docker inspect --format='{{.HostConfig.Memory}}' my-container
docker inspect --format='{{.HostConfig.NanoCpus}}' my-container

# Ver uso de disco
docker system df -v

# Ver espacio usado por contenedor
docker ps -s

# Ver procesos con más CPU
docker top my-container -o %CPU

# Ver procesos con más memoria
docker top my-container -o %MEM

# Encontrar archivos grandes
docker exec my-container find / -type f -size +100M 2>/dev/null

# Ver espacio en disco dentro del contenedor
docker exec my-container df -h
```

### Diagnóstico de Build

```bash
# Build con output detallado
docker build --progress=plain --no-cache -t myapp:latest .

# Ver historial de capas
docker history myapp:latest

# Ver historial sin truncar
docker history --no-trunc myapp:latest

# Ver comandos que crearon cada capa
docker history --format "{{.CreatedBy}}" myapp:latest

# Inspeccionar tamaño de cada capa
docker history --human myapp:latest

# Build hasta capa específica
docker build --target builder -t myapp:debug .

# Ejecutar shell en build stage
docker run -it myapp:debug sh
```

### Recovery de Contenedores

```bash
# Commit contenedor antes de perderlo
docker commit failing-container backup-image:latest

# Exportar contenedor
docker export failing-container > container-backup.tar

# Crear imagen desde export
cat container-backup.tar | docker import - recovered-image:latest

# Copiar datos antes de eliminar
docker cp failing-container:/app/data ./backup/

# Restart automático de contenedores caídos
docker update --restart=unless-stopped my-container

# Ver intentos de restart
docker inspect --format='{{.RestartCount}}' my-container
```

### Debug de Docker Daemon

```bash
# Ver logs del daemon (Ubuntu/Debian)
sudo journalctl -u docker.service

# Ver logs del daemon (otros sistemas)
sudo tail -f /var/log/docker.log

# Ver configuración del daemon
cat /etc/docker/daemon.json

# Verificar estado del daemon
sudo systemctl status docker

# Reiniciar daemon
sudo systemctl restart docker

# Ver versión y configuración
docker info

# Habilitar debug mode en daemon
# Editar /etc/docker/daemon.json:
{
  "debug": true,
  "log-level": "debug"
}
# Luego: sudo systemctl restart docker
```

### Problemas Comunes

```bash
# Puerto ya en uso
# Encontrar qué lo usa:
docker ps --filter "publish=8080"
sudo lsof -i :8080
# Detener contenedor:
docker stop $(docker ps -q --filter "publish=8080")

# Espacio en disco lleno
docker system prune -af --volumes
docker builder prune -af

# Contenedor no se detiene
docker kill my-container

# Volumen en uso
# Ver qué contenedor lo usa:
docker ps -a --filter volume=my-volume

# Red en uso
# Ver qué contenedores están conectados:
docker network inspect my-network

# Imagen corrupta
docker rmi -f image-id
docker pull image:tag

# Cache de DNS
# Reiniciar contenedor:
docker restart my-container
# O recrear con --dns:
docker run --dns 8.8.8.8 nginx

# Permisos de volumen
# Cambiar owner dentro del contenedor:
docker exec -u root my-container chown -R 1000:1000 /data

# BuildKit cache corrupto
docker builder prune -af
```

---

## Comandos de Contexto

### `docker context`
Gestiona contextos para múltiples daemons.

```bash
# Listar contextos disponibles
docker context ls

# Crear contexto remoto vía SSH
docker context create remote-prod \
  --docker "host=ssh://user@prod-server.com"

# Crear contexto con TLS
docker context create remote-secure \
  --docker "host=tcp://remote:2376,ca=/path/ca.pem,cert=/path/cert.pem,key=/path/key.pem"

# Usar contexto específico
docker context use remote-prod

# Ver contexto actual
docker context show

# Inspeccionar contexto
docker context inspect remote-prod

# Actualizar contexto
docker context update remote-prod \
  --docker "host=ssh://user@new-server.com"

# Exportar contexto
docker context export remote-prod

# Importar contexto
docker context import remote-prod remote-prod.dockercontext

# Eliminar contexto
docker context rm remote-prod

# Ejecutar comando en contexto específico sin cambiarlo
docker --context remote-prod ps

# Volver a contexto default
docker context use default
```

---

## Plugins

### `docker plugin`
Gestiona plugins de Docker.

```bash
# Listar plugins instalados
docker plugin ls

# Instalar plugin
docker plugin install vieux/sshfs

# Instalar con opciones
docker plugin install vieux/sshfs DEBUG=1

# Habilitar plugin
docker plugin enable vieux/sshfs

# Deshabilitar plugin
docker plugin disable vieux/sshfs

# Inspeccionar plugin
docker plugin inspect vieux/sshfs

# Ver configuración de plugin
docker plugin inspect --format='{{json .Settings}}' vieux/sshfs | jq

# Actualizar plugin
docker plugin upgrade vieux/sshfs

# Push plugin (para desarrolladores)
docker plugin push myplugin:latest

# Eliminar plugin
docker plugin rm vieux/sshfs

# Forzar eliminación
docker plugin rm -f vieux/sshfs

# Crear plugin (para desarrolladores)
docker plugin create myplugin:latest ./plugin-dir
```

---

## Ejemplos Prácticos para DevOps

### Pipeline CI/CD Completo

```bash
#!/bin/bash
# deploy.sh - Script de deployment completo

set -e

IMAGE_NAME="myapp"
REGISTRY="registry.company.com"
VERSION="${CI_COMMIT_SHA:-latest}"
SERVICE_NAME="production_app"

echo "🏗️  Building image..."
docker build \
  --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
  --build-arg VERSION=$VERSION \
  -t $IMAGE_NAME:$VERSION \
  -t $IMAGE_NAME:latest \
  .

echo "🧪 Running tests..."
docker run --rm $IMAGE_NAME:$VERSION npm test

echo "🔍 Scanning for vulnerabilities..."
docker scan --severity high $IMAGE_NAME:$VERSION

echo "📦 Pushing to registry..."
docker tag $IMAGE_NAME:$VERSION $REGISTRY/$IMAGE_NAME:$VERSION
docker tag $IMAGE_NAME:latest $REGISTRY/$IMAGE_NAME:latest
docker push $REGISTRY/$IMAGE_NAME:$VERSION
docker push $REGISTRY/$IMAGE_NAME:latest

echo "🚀 Deploying to production..."
docker service update \
  --image $REGISTRY/$IMAGE_NAME:$VERSION \
  --update-parallelism 2 \
  --update-delay 10s \
  $SERVICE_NAME

echo "✅ Deployment completed!"
```

### Health Check y Monitoring

```bash
#!/bin/bash
# health-monitor.sh - Monitoreo de salud de contenedores

WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"

while true; do
  # Verificar contenedores unhealthy
  UNHEALTHY=$(docker ps -q --filter "health=unhealthy")
  
  if [ ! -z "$UNHEALTHY" ]; then
    for container_id in $UNHEALTHY; do
      NAME=$(docker inspect -f '{{.Name}}' $container_id | sed 's/\///')
      
      echo "⚠️  Container $NAME is unhealthy!"
      
      # Obtener logs
      docker logs --tail 50 $container_id > /tmp/${NAME}_logs.txt
      
      # Enviar alerta
      curl -X POST -H 'Content-type: application/json' \
        --data "{\"text\":\"🚨 Alert: Container $NAME is unhealthy\"}" \
        $WEBHOOK_URL
      
      # Intentar restart
      echo "🔄 Attempting restart..."
      docker restart $container_id
    done
  fi
  
  # Verificar uso de recursos
  HIGH_CPU=$(docker stats --no-stream --format "{{.Container}}:{{.CPUPerc}}" | \
    awk -F: '$2+0 > 80 {print $1}')
  
  if [ ! -z "$HIGH_CPU" ]; then
    echo "⚠️  High CPU usage detected: $HIGH_CPU"
  fi
  
  sleep 60
done
```

### Backup Automatizado

```bash
#!/bin/bash
# backup-all.sh - Backup completo de Docker

BACKUP_DIR="/backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p $BACKUP_DIR

echo "📦 Backing up volumes..."
for volume in $(docker volume ls -q); do
  echo "  - $volume"
  docker run --rm \
    -v ${volume}:/source:ro \
    -v ${BACKUP_DIR}:/backup \
    alpine tar czf /backup/${volume}.tar.gz /source
done

echo "💾 Backing up databases..."
# PostgreSQL
docker exec postgres pg_dumpall -U postgres > $BACKUP_DIR/postgres_backup.sql

# MySQL
docker exec mysql mysqldump -u root -p${MYSQL_ROOT_PASSWORD} --all-databases > $BACKUP_DIR/mysql_backup.sql

# MongoDB
docker exec mongo mongodump --archive=/backup/mongo_backup.archive
docker cp mongo:/backup/mongo_backup.archive $BACKUP_DIR/

echo "📋 Saving Docker configurations..."
docker inspect $(docker ps -aq) > $BACKUP_DIR/containers_config.json
docker network inspect $(docker network ls -q) > $BACKUP_DIR/networks_config.json

echo "✅ Backup completed in $BACKUP_DIR"

# Limpiar backups antiguos (más de 30 días)
find /backups -type d -mtime +30 -exec rm -rf {} +
```

### Log Aggregation

```bash
#!/bin/bash
# collect-logs.sh - Recolectar logs de todos los contenedores

LOG_DIR="/var/log/docker-containers/$(date +%Y%m%d)"
mkdir -p $LOG_DIR

for container in $(docker ps --format '{{.Names}}'); do
  echo "📝 Collecting logs from $container..."
  docker logs --since 24h $container > $LOG_DIR/${container}.log 2>&1
done

# Comprimir logs
tar czf $LOG_DIR.tar.gz $LOG_DIR
rm -rf $LOG_DIR

echo "✅ Logs collected and compressed to $LOG_DIR.tar.gz"
```

### Resource Cleanup

```bash
#!/bin/bash
# cleanup.sh - Limpieza inteligente de recursos

echo "🧹 Starting cleanup..."

# Eliminar contenedores stopped más de 7 días
echo "  Removing old containers..."
docker container prune --filter "until=168h" -f

# Eliminar imágenes no usadas más de 30 días
echo "  Removing old images..."
docker image prune -a --filter "until=720h" -f

# Eliminar volúmenes dangling
echo "  Removing dangling volumes..."
docker volume prune -f

# Eliminar redes no usadas
echo "  Removing unused networks..."
docker network prune -f

# Limpiar build cache manteniendo 5GB
echo "  Cleaning build cache..."
docker builder prune --keep-storage 5GB -f

# Reporte final
echo ""
echo "📊 Disk usage after cleanup:"
docker system df

echo "✅ Cleanup completed!"
```

### Multi-Environment Deploy

```bash
#!/bin/bash
# multi-deploy.sh - Deploy en múltiples ambientes

ENVIRONMENTS=("dev" "staging" "production")
IMAGE="myapp"
VERSION=$1

if [ -z "$VERSION" ]; then
  echo "Usage: $0 <version>"
  exit 1
fi

for ENV in "${ENVIRONMENTS[@]}"; do
  echo "🚀 Deploying to $ENV..."
  
  # Usar contexto del ambiente
  docker context use $ENV
  
  # Deploy con docker-compose
  docker-compose -f docker-compose.yml -f docker-compose.$ENV.yml \
    pull
  
  docker-compose -f docker-compose.yml -f docker-compose.$ENV.yml \
    up -d --remove-orphans
  
  # Esperar health check
  echo "⏳ Waiting for services to be healthy..."
  sleep 30
  
  # Verificar deployment
  UNHEALTHY=$(docker ps --filter "health=unhealthy" -q)
  if [ ! -z "$UNHEALTHY" ]; then
    echo "❌ Deployment to $ENV failed!"
    docker-compose -f docker-compose.yml -f docker-compose.$ENV.yml logs
    exit 1
  fi
  
  echo "✅ Deployment to $ENV successful!"
done

# Volver a contexto default
docker context use default
```

---

## Mejores Prácticas

### Dockerfile Optimizado

```dockerfile
# Multi-stage build optimizado
FROM node:18-alpine AS base
WORKDIR /app
ENV NODE_ENV=production

# Dependencies stage
FROM base AS dependencies
COPY package*.json ./
RUN npm ci --only=production && \
    npm cache clean --force

# Build stage
FROM base AS build
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build && \
    npm prune --production

# Final stage
FROM node:18-alpine AS production
WORKDIR /app

# Crear usuario no-root
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Copiar solo lo necesario
COPY --from=dependencies --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=build --chown=nodejs:nodejs /app/dist ./dist
COPY --from=build --chown=nodejs:nodejs /app/package.json ./

# Cambiar a usuario no-root
USER nodejs

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD node healthcheck.js

EXPOSE 3000

CMD ["node", "dist/server.js"]
```

### docker-compose.yml Producción

```yaml
version: '3.8'

services:
  web:
    image: myapp:latest
    deploy:
      replicas: 3
      update_config:
        parallelism: 1
        delay: 10s
        order: start-first
      rollback_config:
        parallelism: 1
        delay: 5s
      restart_policy:
        condition: on-failure
        max_attempts: 3
        delay: 5s
      resources:
        limits:
          cpus: '1'
          memory: 512M
        reservations:
          cpus: '0.5'
          memory: 256M
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    environment:
      - NODE_ENV=production
    secrets:
      - api_key
    configs:
      - source: app_config
        target: /app/config.json
    networks:
      - backend
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  db:
    image: postgres:15-alpine
    volumes:
      - db_data:/var/lib/postgresql/data
    environment:
      - POSTGRES_PASSWORD_FILE=/run/secrets/db_password
    secrets:
      - db_password
    networks:
      - backend
    deploy:
      placement:
        constraints:
          - node.labels.disk==ssd

networks:
  backend:
    driver: overlay
    attachable: true

volumes:
  db_data:
    driver: local

secrets:
  api_key:
    external: true
  db_password:
    external: true

configs:
  app_config:
    external: true
```

### .dockerignore Completo

```
# Git
.git
.gitignore
.gitattributes

# CI/CD
.gitlab-ci.yml
.github
.travis.yml
Jenkinsfile

# Documentation
README.md
CHANGELOG.md
LICENSE
docs/

# Dependencies
node_modules/
vendor/
bower_components/

# Build artifacts
dist/
build/
target/
*.log

# Tests
tests/
test/
**/__tests__/
*.test.js
*.spec.js
coverage/

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Environment
.env
.env.local
*.pem
*.key

# Docker
docker-compose*.yml
Dockerfile*
.dockerignore
```

---

## Cheat Sheet Rápido

```bash
# === CONTENEDORES ===
docker run -d -p 8080:80 --name web nginx
docker ps -a
docker stop web && docker rm web
docker exec -it web bash
docker logs -f web

# === IMÁGENES ===
docker build -t app:1.0 .
docker images
docker pull nginx:alpine
docker rmi app:1.0
docker push user/app:1.0

# === VOLÚMENES ===
docker volume create data
docker volume ls
docker run -v data:/app nginx
docker volume rm data

# === REDES ===
docker network create backend
docker network ls
docker network connect backend app
docker network rm backend

# === COMPOSE ===
docker compose up -d
docker compose down -v
docker compose logs -f
docker compose ps

# === LIMPIEZA ===
docker system prune -af --volumes
docker builder prune -af

# === SWARM ===
docker swarm init
docker service create --replicas 3 nginx
docker service scale web=5
docker service update --image nginx:latest web

# === DEBUG ===
docker stats
docker inspect container
docker logs --tail 100 -f container
docker top container

# === BACKUP ===
docker export container > backup.tar
docker save image > image.tar
docker run --rm -v vol:/data -v $(pwd):/backup alpine tar czf /backup/vol.tar.gz /data
```

---

## Recursos Adicionales

### Documentación Oficial
- Docker Docs: https://docs.docker.com
- Docker Hub: https://hub.docker.com
- Docker Compose: https://docs.docker.com/compose
- Docker Swarm: https://docs.docker.com/engine/swarm

### Herramientas Útiles
- **Portainer**: UI web para gestionar Docker
- **Lazydocker**: TUI para gestionar Docker desde terminal
- **Dive**: Analizar layers de imágenes
- **Hadolint**: Linter para Dockerfiles
- **Trivy**: Scanner de vulnerabilidades
- **ctop**: Top para contenedores
- **Docker Slim**: Optimizar imágenes

### Comandos para Instalar Herramientas

```bash
# Portainer
docker volume create portainer_data
docker run -d -p 9000:9000 --name portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce

# Lazydocker
docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock \
  -v ~/.config/lazydocker:/.config/jesseduffield/lazydocker \
  lazyteam/lazydocker

# Dive
docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock \
  wagoodman/dive:latest myimage:latest

# Trivy
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image myimage:latest
```

---

**Nota Final**: Esta guía cubre los comandos más importantes y útiles de Docker para DevOps. Todos los ejemplos son funcionales y pueden adaptarse a tus necesidades específicas. Recuerda siempre verificar la documentación oficial para las últimas actualizaciones y opciones disponibles.