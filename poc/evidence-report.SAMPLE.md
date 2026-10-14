# Sample evidence report (regenerate with `./poc/run-poc.sh`)

This file is a static sample. Your live PoC writes `poc/output/evidence-report.md`.

## Challenges → proof

| Challenge | Proof in this PoC |
|---|---|
| Configuration drift / snowflake hosts | Snowflake vs baseline profile comparison + Git-tracked blueprint |
| Unpredictable environments block modernization | Boutique Inventory Sync API healthy on baseline runtime |
| Security posture / audit difficulty | Simulated Insights registration evidence |
| CVE patching within days | Day-2 runbook (`dnf` security updates) |
| Hybrid / multi-cloud inconsistency | Same baseline for VA, Frankfurt, boutique, cloud |

## How to regenerate

```bash
./poc/run-poc.sh
cat poc/output/evidence-report.md
```
