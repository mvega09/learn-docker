# database.py
import mysql.connector
from mysql.connector import Error

class DatabaseManager:
    def __init__(self, host, user, password, database):
        self.db_config = {
            "host": host,
            "user": user,
            "password": password,
            "database": database
        }

    def get_connection(self):
        """Crea una nueva conexión en cada solicitud."""
        try:
            conn = mysql.connector.connect(**self.db_config)
            if conn.is_connected():
                return conn
        except Error as e:
            print(f"❌ Error al conectar con la base de datos: {e}")
            return None

# Configuración para Docker
db_manager = DatabaseManager(
    host="db",  # nombre del servicio Docker
    user="root",
    password="superrootpassword",
    database="siacom_db"
)
