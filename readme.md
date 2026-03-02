# Azure SQL Database – Enterprise Administration Project

## Overview

This project demonstrates a full lifecycle administration of an Azure SQL Database supporting a mixed OLTP and operational reporting workload (HCareOps scenario).

It covers:

- Database architecture
- Performance tuning & execution plan analysis
- Index optimisation
- Query Store usage
- Monitoring strategy
- High Availability & Disaster Recovery
- Cost awareness
- Enterprise-grade security design

The objective is to showcase practical Azure SQL Database administration aligned with production standards.

---

## Architecture

The solution models a healthcare operational database with:

- Core transactional schemas (`core`)
- Reference schemas (`ref`)
- Reporting schema (`reporting`)
- Join-heavy breach monitoring queries (e.g., CANCER_62 pathway)

See:  
`docs/01-architecture.md`

---

## Performance Engineering

A breach monitoring query was identified as a bottleneck due to:

- Non-SARGable predicates
- Key Lookup amplification
- High logical I/O

Optimisations implemented:

1. Covering index to eliminate Key Lookup
2. Predicate rewrite to improve SARGability
3. DMV-based performance validation

### Measured Improvement

| Metric | Before | After |
|--------|--------|--------|
| Logical Reads | ~144,000 | ~48,900 |
| CPU Time | ~213 ms | ~73–77 ms |
| Elapsed Time | ~793 ms | ~82–150 ms |

Approx. 66% reduction in logical reads.

Execution plans included in:

```
docs/images/performance/
```

See:  
`docs/03-performance-strategy.md`

---

## Monitoring & Query Store

- Query Store enabled for plan tracking
- DMV-based workload analysis
- Top resource-consuming query identification
- Structured monitoring strategy documented

See:  
`docs/04-monitoring-strategy.md`

---

## Backup, High Availability & Disaster Recovery

- Built-in Azure SQL automatic backups (PITR)
- Long-Term Retention (LTR) strategy
- Active geo-replication design (documented)
- Failover and testing approach

See:  
`docs/05-backup-ha-dr.md`

---

## Security Architecture

Security is implemented using an enterprise RBAC model.

### Identity & Authentication
- Microsoft Entra ID integration
- No SQL authentication for production model
- Group-based database access

### Authorization
- Custom database roles
- Schema-level permissions
- Least privilege enforcement

### Data Protection
- Transparent Data Encryption (TDE)
- TLS-encrypted connections

### Network & Auditing
- Firewall and private access model (documented)
- Azure SQL auditing strategy
- Defender for SQL considerations

Implementation script:

```
security/01-aad-integration-and-rbac.sql
```

Design documentation:

```
docs/06-security-strategy.md
```

---

## Key Skills Demonstrated

- Azure SQL Database administration
- Execution plan analysis
- Index design & covering indexes
- SARGability optimisation
- DMV analysis (`sys.dm_exec_query_stats`)
- Role-based security modelling
- HA/DR design for PaaS databases
- Production-safe performance tuning
- Enterprise documentation practices

---

## Design Philosophy

This project reflects:

- Production-ready thinking
- Cost awareness (resources deprovisioned after testing)
- Separation of control plane and data plane
- Documentation-driven architecture
- Security-first design principles

---

## Author

Azure SQL Database Administration Project  
Designed as an enterprise-grade demonstration of PaaS database management capability.