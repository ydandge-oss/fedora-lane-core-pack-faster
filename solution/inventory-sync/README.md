# Boutique Inventory Sync API

Sample service for the Fedora Lane Core Pack custom application:  
*synchronizes inventory data between central SAP ERP and local PoS systems*.

## Run (Docker)

```bash
docker compose up --build -d
curl -s http://localhost:8080/health | jq .
curl -s http://localhost:8080/api/v1/sync/status | jq .
curl -s -X POST http://localhost:8080/api/v1/sync/run \
  -H "X-Api-Token: demo-not-a-real-secret" | jq .
```

## Run (local Python — no Docker)

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
export SYNC_API_TOKEN=demo-not-a-real-secret
uvicorn app.main:app --host 127.0.0.1 --port 8080
# other terminal:
curl -s http://127.0.0.1:8080/health | jq .
```

## Design notes

- Stateless container; token via environment (not baked into the image layers as a build ARG secret).  
- Does not connect to real SAP/PoS — safe for FASTER practice demos.  
- Maps to Core Pack challenges: modernization, portability, coexistence with COTS.  
