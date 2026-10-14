# Technical solution — Platform Consistency Pilot

Runnable practice build for the **Fedora Lane Core Pack** challenges.

## Components

| Path | Purpose |
|---|---|
| [ansible/](./ansible/) | Inventory model + baseline playbooks |
| [inventory-sync/](./inventory-sync/) | Boutique Inventory Sync sample API (Docker Compose) |
| [requirements.txt](./requirements.txt) | Python deps for Ansible control node |

## Demo A — Ansible (Casey / Alex)

```bash
cd ansible
python3 -m venv .venv && source .venv/bin/activate
pip install -r ../requirements.txt

ansible-inventory -i inventory/hosts.yml --graph
ansible-playbook -i inventory/hosts.yml playbooks/site.yml --check
```

By default the inventory points `ansible_connection=local` at a single demo host so you can run without Fedora Lane servers. See comments in `inventory/hosts.yml` for how you would map real groups later.

## Demo B — Inventory Sync API (Cameron / Ren)

```bash
cd inventory-sync
docker compose up --build -d
curl -s http://localhost:8080/health
curl -s http://localhost:8080/api/v1/sync/status
docker compose down
```

## Cleanup

```bash
# Ansible venv
rm -rf ansible/.venv

# Containers
cd inventory-sync && docker compose down --rmi local
```

## Secrets

- Do not put BMC passwords, API tokens, or cloud keys in Git.  
- The sync API reads `SYNC_API_TOKEN` from the environment / Compose file (demo default is clearly fake).  
