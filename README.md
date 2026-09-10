# ducklake-helm 🦆

**Run DuckLake on Kubernetes with a single Helm install.**

`ducklake-helm` packages the core components needed to run DuckLake on Kubernetes.

Instead of manually configuring a catalog database, object storage, DuckLake initialization, and maintenance jobs, the chart wires them together for you.

## Install

```bash
helm install ducklake   oci://ghcr.io/v-hemish/charts/ducklake   --version 0.1.0   --namespace ducklake   --create-namespace
```

Check the deployment:

```bash
kubectl get pods -n ducklake
```

Once the components are ready, run the Helm smoke test:

```bash
helm test ducklake -n ducklake
```

## Query DuckLake

Open the DuckDB toolbox:

```bash
kubectl exec -it deploy/ducklake-toolbox   -n ducklake   -- /duckdb -init /opt/ducklake/connect.sql
```

Inside DuckDB:

```sql
SHOW TABLES;

SELECT * FROM helm_smoke_test;
```

Create and query your own table:

```sql
CREATE TABLE events AS
SELECT
    1 AS id,
    'hello from kubernetes' AS message;

SELECT * FROM events;
```

## Architecture

```text
                 Kubernetes
                     │
       ┌─────────────┴─────────────┐
       │                           │
    PostgreSQL                  RustFS
      Catalog               S3-compatible
                               Storage
       │                           │
       └─────────────┬─────────────┘
                     │
                  DuckLake
                     │
       ┌─────────────┴─────────────┐
       │                           │
  DuckDB Toolbox           Maintenance CronJob
```

DuckLake metadata is stored in PostgreSQL.

Table data is stored as Parquet files in S3-compatible object storage.

## What gets deployed

The default installation includes:

- PostgreSQL 16.x
- RustFS S3-compatible object storage
- S3 bucket initialization
- DuckLake bootstrap Job
- DuckDB toolbox Deployment
- DuckLake smoke-test table
- Helm smoke test
- scheduled DuckLake `CHECKPOINT` CronJob

## Maintenance

DuckLake provides:

```sql
CHECKPOINT;
```

to run maintenance operations.

The chart schedules this using a Kubernetes CronJob. The schedule can be configured through `values.yaml`.

## Status

The current `v0.1.0` release is designed as a simple DuckLake quick-start for Kubernetes.

The default PostgreSQL + RustFS configuration is intended for **development and evaluation**. Persistence is disabled by default.

For production environments, use appropriately operated PostgreSQL and object storage.

## Uninstall

```bash
helm uninstall ducklake -n ducklake
```

## License

Apache-2.0
