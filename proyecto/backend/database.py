# database.py
import os
import mysql.connector
from mysql.connector import Error

class DatabaseManager:
    def __init__(self):
        # Lee la configuración desde las variables de entorno
        self.db_config = {
            "host": os.getenv("DB_HOST", "db4free.net"),
            "user": os.getenv("DB_USER", "siacom_user"),
            "password": os.getenv("DB_PASSWORD", "admin123"),
            "database": os.getenv("DB_NAME", "siacom_db"),
            "port": int(os.getenv("DB_PORT", 3306))
        }

    def get_connection(self):
        """Crea una nueva conexión para cada solicitud"""
        try:
            conn = mysql.connector.connect(**self.db_config)
            if conn.is_connected():
                return conn
        except Error as e:
            print(f"❌ Error al conectar con la base de datos: {e}")
            return None

# Inicializa el gestor de base de datos
db_manager = DatabaseManager()
