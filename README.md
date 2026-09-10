# ducklake-helm 🦆

**One-command DuckLake quick-start for Kubernetes.**

This project packages a usable DuckLake architecture behind a Helm install: a PostgreSQL catalog, S3-compatible storage, DuckLake bootstrap, an interactive DuckDB toolbox, and scheduled DuckLake maintenance.

> **Status:** v0.1 development. The bundled PostgreSQL + RustFS path is for evaluation. Production guidance will use external managed/operated PostgreSQL and object storage.

## Target experience

```bash
helm install my-ducklake ./charts/ducklake
kubectl get pods
kubectl logs job/my-ducklake-ducklake-bootstrap
kubectl exec -it deploy/my-ducklake-ducklake-toolbox -- duckdb -init /opt/ducklake/connect.sql
```

Inside DuckDB:

```sql
SHOW TABLES;
SELECT * FROM helm_smoke_test;

CREATE TABLE events AS
SELECT 1 AS id, 'hello from kubernetes' AS message;

SELECT * FROM events;
```

## What v0.1 deploys

```text
                 Kubernetes
                     │
       ┌─────────────┴─────────────┐
       │                           │
 PostgreSQL catalog          RustFS (S3 API)
       │                           │
       └─────────────┬─────────────┘
                     │
                DuckLake
                     │
       ┌─────────────┴─────────────┐
       │                           │
 DuckDB toolbox            CHECKPOINT CronJob
```

DuckLake metadata lives in PostgreSQL. Parquet data lives under the configured `s3://<bucket>/<prefix>/` path.

## Why a CronJob?

DuckLake recommends periodic maintenance for workloads that accumulate small files, old snapshots, delete files, and orphaned files. `CHECKPOINT` bundles DuckLake's maintenance operations, so Kubernetes CronJob is a natural operational primitive for it.

## Defaults

The defaults prioritize a zero-dependency Kubernetes demo:

- PostgreSQL 16.x is bundled.
- RustFS is bundled as an S3-compatible evaluation store.
- Persistence is **off** by default so the chart does not require a StorageClass.
- Credentials are generated when values are left blank.
- A bootstrap Job initializes DuckLake and inserts a smoke-test row.
- A toolbox Deployment gives you an interactive DuckDB client.
- A daily `CHECKPOINT` CronJob is enabled.

Do not treat the defaults as production settings.

## Roadmap

### v0.1 — zero-to-DuckLake
- [x] PostgreSQL catalog
- [x] bundled S3-compatible quick-start storage
- [x] bucket initialization
- [x] DuckLake bootstrap Job
- [x] interactive DuckDB toolbox
- [x] scheduled `CHECKPOINT`
- [x] Helm smoke test
- [ ] run successfully in Kind/minikube
- [ ] GitHub Actions Kind integration test

### v0.2 — bring your own infrastructure
- [x] external PostgreSQL connection + existing Secret
- [x] external S3-compatible endpoint + Secret
- [x] existing Kubernetes Secrets
- [ ] persistence examples

### v0.3 — production-shaped cloud setup
- [ ] AWS workload identity / IRSA
- [ ] GCS
- [ ] Azure Blob
- [ ] network policies
- [ ] pod security hardening
- [ ] monitoring/metrics guidance

## License

Apache-2.0.
