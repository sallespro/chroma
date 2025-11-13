"""ChromaDB FastAPI Application"""
import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(
    title="ChromaDB",
    description="ChromaDB API Server",
    version="0.4.22"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {"message": "ChromaDB Server", "version": "0.4.22"}

@app.get("/health")
async def health():
    return {"status": "healthy"}

@app.get("/api/v1/heartbeat")
async def heartbeat():
    return {"nanos": 0}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)