from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI(title="PredMaCC API")


class EchoRequest(BaseModel):
    message: str


@app.get("/api/health")
def health():
    return {"status": "ok"}


@app.get("/api/hello")
def hello():
    return {"message": "Hello from FastAPI running on SPCS!"}


@app.post("/api/echo")
def echo(payload: EchoRequest):
    return {"echo": payload.message}
