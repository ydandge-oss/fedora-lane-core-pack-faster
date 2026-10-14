# Customer brief — Fedora Lane  
## Source: FASTER Core Pack (CY26/27)

**Industry:** Style-conscious retail — flagship boutiques + global e-commerce  
**Cities:** Paris, London, New York, Tokyo (and worldwide online)  
**Brand priority:** High-quality, seamless customer experience across all touchpoints  

---

## Who they are

Fedora Lane is an internationally recognized name in style-conscious retail. They operate prestigious flagship boutiques in major fashion capitals, complemented by a sophisticated global e-commerce platform. Expanding global operations have introduced significant technical challenges. Their technology landscape is a **hybrid and multi-cloud** model supporting international retail and e-commerce.

---

## Infrastructure snapshot

| Area | Today |
|---|---|
| On-prem DCs | Virginia (NA) + Frankfurt (EMEA) for DR and regional performance |
| Hardware | Dell PowerEdge (14th/15th gen primary); some HPE ProLiant |
| Virtualization | VMware vSphere 7.x (exclusive hypervisor in DCs) |
| Storage | Dell EMC PowerStore (block SAN); NetApp FAS (NAS / user directories) |
| Boutiques | Small independently managed server closets (2–3 Dell servers) at flagships/hubs |
| Primary cloud | AWS multi-region (e.g. us-east-1, eu-central-1, ap-northeast-1): EC2, RDS/PostgreSQL, S3 |
| Secondary cloud | Azure — EMEA marketing analytics + some COTS with favorable licensing |
| Connectivity | Private DC–DC link; dedicated connections to AWS/Azure; centrally managed boutique WAN; global remote access; mix of on-prem and native cloud load balancing |

### Network notes (Core Pack)

- VLANs isolate corporate user traffic from production apps and sensitive payment systems  
- Cloud workloads sit in logically isolated virtual networks, interconnected and linked to on-prem  
- Enterprise firewalls at DC edge and as virtual appliances in cloud  

---

## Application portfolio

### COTS

- **SAP S/4HANA** — finance, global supply chain, HR (on-prem in primary DCs)  
- **PLM** suite for design / product development  
- **Point-of-Sale** commercial solution in all boutiques; backends centralized in regional DCs  

### Custom

- **Global e-commerce platform** (“crown jewel”): legacy Java monoliths (JBoss EAP / Apache Tomcat) + newer Python and Node.js microservices; Oracle on-prem for legacy + Amazon Aurora (PostgreSQL-compatible) on AWS for modern services  
- **Customer Loyalty & Analytics** platform  
- **Boutique Inventory Sync Tool** — synchronizes inventory between central SAP ERP and local PoS systems  

---

## Security & compliance

| Mandate / policy | Implication |
|---|---|
| PCI DSS | Systems that store, process, or transmit cardholder data |
| GDPR | EU citizen data — boutiques and e-commerce |
| CCPA/CPRA | Significant California customer base |
| Critical / High CVE patch | Must be patched **within days** of discovery |
| Access | Least privilege on all production systems |
| Encryption | Customer data encrypted at rest and in transit |
| Audits | Quarterly vulnerability scanning and compliance audits; **unified reporting across the diverse estate is a major challenge** |

---

## Stakeholders (Core Pack)

| Name | Role | Orientation |
|---|---|---|
| **Anya Sharma** | CIO | Digital transformation; IT as competitive value and CX — not just “keep lights on” |
| **Alex Lee** | VP Global IT Infrastructure & Operations | Stability + cloud support; skeptical of silver bullets; wants proven, manageable Day-2 |
| **Ren Tanaka** | Head of Information Security & Compliance | Risk lens; wants provable centralized control and less audit toil |
| **Casey Novak** | Head of Linux Engineering (reports to Alex) | Standards and baselines across hybrid Linux fleet; less ticket firefighting |
| **Cameron Shaw** | VP Application Development | Build-over-buy culture; CI/CD and Kubernetes ambition blocked by legacy debt and peer resistance |

---

## One-sentence situation

Fedora Lane’s hybrid/multi-cloud estate is too fragmented to manage consistently, automate safely, modernize e-commerce cleanly, or prove security/compliance efficiently — and that threatens experience, agility, and trust.
