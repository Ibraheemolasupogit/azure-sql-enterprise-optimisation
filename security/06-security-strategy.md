# Security Strategy

This section describes how security is applied to the `HCareOps` Azure SQL Database from an enterprise DBA perspective.

---

## 1. Identity & Authentication

### Control Plane (Azure / Server Level)

- **Identity provider:** Microsoft Entra ID is the single source of identity.
- **Azure SQL logical server:** Configured with an **Entra admin** (AAD group or user) rather than a SQL login.
- **Access model:** Admins connect using Azure AD authentication (MFA-capable), not SQL logins.

> *Note:* In this lab the logical server has been deprovisioned to control cost, but the configuration is captured as part of the design.

### Data Plane (Database Level)

- All database principals are backed by **Entra ID groups**, not individual users.
- Groups are created in Entra ID and then surfaced into the database using:
  - `CREATE USER [GroupName] FROM EXTERNAL PROVIDER;`
- This ensures:
  - Centralised lifecycle (joiners/movers/leavers handled in Entra).
  - Audit trail via Entra sign-in logs.
  - MFA / Conditional Access policies apply to all DB access.

---

## 2. Authorization & Role Design

Authorization is implemented using a **role-based access control (RBAC)** pattern.

### Administrative Access

- **Entra group:** `AAD-HCareOps-DBA`
- **Database mapping:**
  - `CREATE USER [AAD-HCareOps-DBA] FROM EXTERNAL PROVIDER;`
  - `ALTER ROLE db_owner ADD MEMBER [AAD-HCareOps-DBA];`
- **Use case:** Senior DBAs responsible for maintenance, deployments, and troubleshooting.

### Reporting Access

- **Entra group:** `AAD-HCareOps-Reporting`
- **Database role:** `db_reporting`
- **Permissions:**
  - `GRANT SELECT ON SCHEMA::[reporting] TO [db_reporting];`
- **Use case:** Analysts and BI workloads that require read-only access to curated reporting tables.

### Principles Applied

- **Least privilege:** Reporting role is restricted to the `reporting` schema; no write or admin permissions.
- **Separation of duties:** Administrative and reporting capabilities are split into separate Entra groups and DB roles.
- **Group-based assignment:** No direct grants to individual users.

---

## 3. Data Protection

- **At rest:** Azure SQL Database uses **Transparent Data Encryption (TDE)** by default to protect database files and backups.
- **In transit:** All connections are forced over **TLS/SSL**, with `Encrypt=True` in connection strings.
- **Backups:** Automated backups inherit TDE protection and are covered by the HA/DR strategy described in `05-backup-ha-dr.md`.

(If this were a production workload, customer-managed keys in Azure Key Vault could be used for TDE.)

---

## 4. Network Controls

- **Perimeter:** Access to Azure SQL is restricted via **firewall rules / private access** at the logical server level.
- **Admin access:** Limited to specific trusted locations or via private connectivity (e.g., VPN/ExpressRoute) in a real deployment.
- **Service endpoints / private endpoints:** Recommended for production to avoid exposing the database to the public internet.

In this lab environment, network configuration is minimised to keep costs low, but the design assumes private access for production deployments.

---

## 5. Auditing & Monitoring

- **Auditing:** Azure SQL Database auditing is used to capture:
  - Logins and failed login attempts.
  - Permission changes (GRANT/REVOKE).
  - Data access to sensitive schemas.
- **Log destination:** Azure Monitor / Log Analytics workspace (or Storage Account) for long-term retention and reporting.
- **Integration with monitoring:** Security-relevant signals (failed logins, permission changes) can be surfaced alongside performance metrics in the monitoring strategy (`04-monitoring-strategy.md`).

---

## 6. Summary

The security model for `HCareOps` is built around:

- **Microsoft Entra ID for identity and authentication**
- **Role-based access control inside the database**
- **Least-privilege, group-based authorisation**
- **Encrypted data at rest and in transit**
- **Auditable, monitorable access patterns**

The `01-aad-integration-and-rbac.sql` script provides an executable example of how Entra groups are mapped into Azure SQL Database roles to implement this design.