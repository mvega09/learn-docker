FROM python:3.11-slim

# Evitar buffers en logs
ENV PYTHONUNBUFFERED=1 \
    POETRY_VIRTUALENVS_CREATE=false

WORKDIR /app

# instalar dependencias del sistema necesarias para mysql connector y bcrypt
RUN apt-get update \
 && apt-get install -y --no-install-recommends gcc libmariadb-dev-compat libmariadb-dev \
 && rm -rf /var/lib/apt/lists/*

# copiar requirements y instalarlas
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

# copiar el código
COPY . /app

# Exponer puerto uvicorn
EXPOSE 8000

# Comando por defecto (sin --reload en producción)
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
