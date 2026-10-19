# Customer brief — Fedora Lane  
## Core Pack + Server/Cloud OS Expansion Pack

**Industry:** Style-conscious retail — boutiques + global e-commerce  

## Fleet scale (Expansion Pack)

| Location | Approx. count |
|---|---:|
| On-premise VMs | 900 |
| AWS + Azure instances | 600 |
| Boutique servers | 100 |
| **Total** | **~1,600** |

**OS mix today:** Rocky Linux, Ubuntu, CentOS Stream, Amazon Linux (AWS) — no single standard.

## Infrastructure (Core Pack)

- DCs: Virginia + Frankfurt (VMware, Dell/HPE, PowerStore/NetApp)  
- Boutiques: 2–3 server closets  
- Cloud: AWS primary e-commerce; Azure secondary  

## Apps

- SAP S/4HANA, PoS, PLM  
- E-commerce: Java monoliths + Python/Node microservices  
- This TDP gold image targets **e-commerce web server fleet**

## Compliance

PCI DSS, GDPR, CCPA; Critical/High CVEs within policy window (Expansion example uses 30-day miss story).

## Stakeholders

Anya Sharma (CIO), Alex Lee (Infra), Casey Novak (Linux), Ren Tanaka (Security), Cameron Shaw (App Dev).
