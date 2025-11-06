# Usar la imagen oficial de Metabase
FROM metabase/metabase:latest

# Información del mantenedor
LABEL maintainer="mvega100570@umanizales.edu.co"
LABEL description="Metabase para dashboards gerenciales SIACOM"

# Variables de entorno para la configuración de Metabase
ENV MB_JETTY_HOST="0.0.0.0" \
    MB_JETTY_PORT="3000" \
    JAVA_TIMEZONE="America/Bogota"

# Crear directorio para datos persistentes
RUN mkdir -p /metabase-data && \
    chmod 755 /metabase-data

# Establecer el directorio de datos
ENV MB_DB_FILE="/metabase-data/metabase.db"

# Puerto que expone la aplicación
EXPOSE 3000

# Comando de inicio
CMD ["sh", "-c", "java -jar /app/metabase.jar"]