-- File: 04-top-resource-consuming-queries.sql
-- Purpose: Identify recent high-cost queries by average resource usage

SELECT TOP 10
    qs.execution_count,
    qs.total_logical_reads / qs.execution_count AS avg_logical_reads,
    qs.total_worker_time / 1000 / qs.execution_count AS avg_cpu_ms,
    qs.total_elapsed_time / 1000 / qs.execution_count AS avg_elapsed_ms,
    qs.last_execution_time,
    qt.text
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS qt
ORDER BY avg_logical_reads DESC;