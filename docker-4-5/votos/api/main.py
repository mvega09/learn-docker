from fastapi import FastAPI, WebSocket, WebSocketDisconnect, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import psycopg2
import redis
import json
import os
from typing import List
import asyncio

app = FastAPI(title="Encuesta en Tiempo Real")

# Permitir CORS para frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Variables de entorno
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://polls_user:polls_pass@db:5432/polls_db")
REDIS_URL = os.getenv("REDIS_URL", "redis://redis:6379/0")

# Conexión a Redis
redis_client = redis.from_url(REDIS_URL, decode_responses=True)

class VoteRequest(BaseModel):
    option: str

class ConnectionManager:
    def __init__(self):
        self.active_connections: List[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)

    def disconnect(self, websocket: WebSocket):
        self.active_connections.remove(websocket)

    async def broadcast(self, message: str):
        for connection in self.active_connections:
            try:
                await connection.send_text(message)
            except:
                self.active_connections.remove(connection)

manager = ConnectionManager()

def get_db_connection():
    return psycopg2.connect(DATABASE_URL)

# Cargar resultados desde PostgreSQL a Redis al iniciar
def load_results_into_cache():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT option_name, vote_count FROM poll_options")
    for option, count in cur.fetchall():
        redis_client.hset("poll_results", option, count)
    cur.close()
    conn.close()

# Sincronizar resultados Redis → PostgreSQL cada cierto tiempo
async def sync_cache_to_db():
    while True:
        await asyncio.sleep(10)  # Cada 10 segundos
        conn = get_db_connection()
        cur = conn.cursor()
        results = redis_client.hgetall("poll_results")
        for option, count in results.items():
            cur.execute(
                "UPDATE poll_options SET vote_count = %s WHERE option_name = %s",
                (count, option)
            )
        conn.commit()
        cur.close()
        conn.close()
        print("🔄 Resultados sincronizados desde Redis a PostgreSQL")

@app.on_event("startup")
async def startup_event():
    load_results_into_cache()
    asyncio.create_task(sync_cache_to_db())

# Obtener resultados directamente desde Redis
def get_results_from_cache():
    results = redis_client.hgetall("poll_results")
    return {option: int(count) for option, count in results.items()}

@app.post("/vote")
async def vote(vote_request: VoteRequest):
    option = vote_request.option
    valid_options = ["Computer Vision", "Data", "ML", "Web"]

    if option not in valid_options:
        raise HTTPException(status_code=400, detail="Opción inválida")

    # 🔥 Incrementa el voto directamente en Redis (sin tocar PostgreSQL)
    redis_client.hincrby("poll_results", option, 1)

    # 🔥 Obtiene resultados actualizados desde Redis
    results = get_results_from_cache()

    await broadcast_results(results)
    return {"message": "Voto registrado", "results": results}

@app.get("/results")
async def get_results():
    return {"results": get_results_from_cache()}

async def broadcast_results(results):
    message = json.dumps({"type": "results_update", "data": results})
    await manager.broadcast(message)

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await manager.connect(websocket)
    results = get_results_from_cache()
    await websocket.send_text(json.dumps({"type": "results_update", "data": results}))

    try:
        while True:
            await websocket.receive_text()
    except WebSocketDisconnect:
        manager.disconnect(websocket)

@app.get("/")
async def root():
    return {"message": "API de Encuesta en Tiempo Real con Redis funcionando!"}
