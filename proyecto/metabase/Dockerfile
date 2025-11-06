# Usar la imagen oficial de Metabase
FROM metabase/metabase:latest

LABEL maintainer="mvega100570@umanizales.edu.co"
LABEL description="Metabase para dashboards gerenciales SIACOM"

# Configuración básica
ENV MB_JETTY_HOST=0.0.0.0 \
    MB_JETTY_PORT=3000 \
    JAVA_TIMEZONE=America/Bogota

# Puerto que expone la aplicación
EXPOSE 3000

# Usa el ENTRYPOINT original de Metabase (no sobreescribas CMD)
