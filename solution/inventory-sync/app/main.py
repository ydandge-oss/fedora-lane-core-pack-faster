"""Boutique Inventory Sync — Fedora Lane Core Pack practice service.

Represents the custom tool that synchronizes inventory between central SAP ERP
and local PoS systems (Core Pack). Demo-only; no real SAP/PoS connectivity.
"""

from __future__ import annotations

import os
from datetime import datetime, timezone

from fastapi import FastAPI, Header, HTTPException

app = FastAPI(
    title="Fedora Lane Boutique Inventory Sync",
    version="0.1.0",
    description="Practice microservice for FASTER Junior Consultant Core Pack deliverables.",
)

SYNC_API_TOKEN = os.getenv("SYNC_API_TOKEN", "demo-not-a-real-secret")
FL_ENV = os.getenv("FL_ENV", "pilot")
SAP_SYSTEM = os.getenv("SAP_SYSTEM", "S4HANA-FL-NA")
POS_REGION = os.getenv("POS_REGION", "multi")

# In-memory demo state
_STATE = {
    "last_sync_at": None,
    "last_status": "never_run",
    "boutiques_synced": ["paris", "london", "new_york", "tokyo"],
    "records_processed": 0,
}


@app.get("/health")
def health() -> dict:
    return {
        "status": "ok",
        "service": "fl-boutique-inventory-sync",
        "env": FL_ENV,
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }


@app.get("/api/v1/sync/status")
def sync_status() -> dict:
    return {
        "sap_system": SAP_SYSTEM,
        "pos_region": POS_REGION,
        "last_sync_at": _STATE["last_sync_at"],
        "last_status": _STATE["last_status"],
        "boutiques": _STATE["boutiques_synced"],
        "records_processed": _STATE["records_processed"],
        "notes": "Demo service — SAP and PoS are simulated per Core Pack narrative.",
    }


@app.post("/api/v1/sync/run")
def run_sync(x_api_token: str | None = Header(default=None)) -> dict:
    if x_api_token != SYNC_API_TOKEN:
        raise HTTPException(status_code=401, detail="Invalid or missing X-Api-Token")

    now = datetime.now(timezone.utc).isoformat()
    _STATE["last_sync_at"] = now
    _STATE["last_status"] = "success"
    _STATE["records_processed"] += 42

    return {
        "status": "success",
        "synced_at": now,
        "boutiques": _STATE["boutiques_synced"],
        "records_processed": 42,
        "message": "Simulated SAP → PoS inventory sync completed.",
    }
