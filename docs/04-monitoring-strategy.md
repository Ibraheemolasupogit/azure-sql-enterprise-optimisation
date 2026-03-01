# Monitoring Strategy

This document describes how performance is monitored for the HCareOps Azure SQL workload using Query Store, Dynamic Management Views (DMVs), and execution plan analysis.

---

## Objectives

- Detect query regressions before they impact cancer pathway reporting.
- Identify top resource-consuming queries across OLTP and reporting workloads.
- Provide quantitative evidence for performance tuning changes.
- Align with DP-300 "Monitor and optimise performance" objectives.

---

## Query Store Configuration

Query Store is enabled at the database level to persist execution statistics and plan history.

**Configuration Script Location:**

```
optimisation/query-store/01-enable-query-store.sql
```

### Key Settings

- `OPERATION_MODE = READ_WRITE`  
  Enables active runtime capture.

- `STALE_QUERY_THRESHOLD_DAYS = 30`  
  Retains one month of historical query data.

- `INTERVAL_LENGTH_MINUTES = 60`  
  Aggregates metrics hourly for trend analysis.

- `MAX_STORAGE_SIZE_MB = 1024`  
  Caps storage usage (lab appropriate, production scalable).

- `QUERY_CAPTURE_MODE = AUTO`  
  Avoids noise from trivial queries.

In an enterprise deployment, this configuration would be applied via change control and infrastructure-as-code pipelines.

---

## DMV-Based Performance Baseline

For reproducible performance measurement, DMVs are used to capture average query resource consumption.

### Example: Identify Recent CANCER_62 Query Metrics

```sql
SELECT TOP 1
    qs.execution_count,
    qs.total_logical_reads / qs.execution_count AS avg_logical_reads,
    qs.total_worker_time / 1000 / qs.execution_count AS avg_cpu_ms,
    qs.total_elapsed_time / 1000 / qs.execution_count AS avg_elapsed_ms
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS qt
WHERE qt.text LIKE '%CANCER_62%'
ORDER BY qs.last_execution_time DESC;
```

### Purpose

This query is used to:

1. Capture baseline metrics.
2. Measure post-optimisation improvements.
3. Provide objective evidence in performance documentation.

---

## Execution Plan Analysis Workflow

Performance tuning follows a structured workflow:

1. Identify candidate query via DMV or Query Store.
2. Capture Actual Execution Plan.
3. Identify bottleneck operators:
   - Key Lookup
   - Hash Match
   - Parallelism imbalance
   - Sort spills
4. Design index or rewrite query.
5. Re-measure using same DMV pattern.
6. Document change in `docs/03-performance-strategy.md`.

This ensures optimisation decisions are evidence-based rather than speculative.

---

## Operational Use of Query Store

In production, Query Store supports:

- Regression detection across deployment windows.
- Comparison of query performance by time interval.
- Plan forcing when required.
- Historical performance auditing.

Although this project runs in a personal Azure subscription, the design patterns align with real-world NHS or healthcare estate practices.

---

## Integration with Performance Strategy

The performance case study in:

```
docs/03-performance-strategy.md
```

demonstrates:

- Key Lookup elimination using covering indexes.
- SARGable predicate design.
- Before/after DMV validation.
- Execution plan comparison with screenshots.

Together, these create a repeatable DBA tuning methodology.

---

## Future Enhancements

Potential monitoring improvements:

- Scheduled extraction of Query Store metrics.
- Export to Azure Log Analytics.
- Power BI dashboard for workload trending.
- Alerting on:
  - Query duration spikes
  - Logical read increases
  - Query Store storage pressure

These enhancements can extend the project toward enterprise observability patterns.