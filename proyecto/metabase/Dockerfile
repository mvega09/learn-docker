FROM metabase/metabase:latest

# Establecer variables de entorno por defecto
ENV MB_JETTY_HOST=0.0.0.0
ENV MB_JETTY_PORT=3000

# Exponer el puerto que Render usará
EXPOSE 3000

# Crear directorio para datos de Metabase
RUN mkdir -p /metabase-data

# Volumen para persistencia de datos
VOLUME /metabase-data

# El comando por defecto ya está configurado en la imagen base
# pero lo podemos especificar explícitamente si es necesario
CMD ["java", "-jar", "/app/metabase.jar"]