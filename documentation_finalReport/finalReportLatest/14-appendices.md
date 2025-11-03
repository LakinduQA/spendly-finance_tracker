# Section 14: Appendices

**Personal Finance Management System**  
**Supporting Documentation and Materials**

---

## Appendix A: Complete Schema Diagrams

### A.1 SQLite Entity-Relationship Diagram

```
┌─────────────────┐
│      USER       │
├─────────────────┤
│ user_id (PK)    │───┐
│ username        │   │
│ email           │   │
│ password_hash   │   │
│ full_name       │   │
│ created_at      │   │
│ modified_at     │   │
└─────────────────┘   │
                      │
        ┌─────────────┴───────────────────────────┐
        │                                         │
        │                                         │
┌───────▼─────────┐                    ┌─────────▼─────────┐
│    EXPENSE      │                    │      INCOME       │
├─────────────────┤                    ├───────────────────┤
│ expense_id (PK) │                    │ income_id (PK)    │
│ user_id (FK)    │                    │ user_id (FK)      │
│ category_id(FK) │───┐                │ category_id (FK)  │───┐
│ amount          │   │                │ amount            │   │
│ expense_date    │   │                │ income_date       │   │
│ description     │   │                │ description       │   │
│ payment_method  │   │                │ income_source     │   │
│ fiscal_year     │   │                │ fiscal_year       │   │
│ fiscal_month    │   │                │ fiscal_month      │   │
│ is_synced       │   │                │ is_synced         │   │
│ created_at      │   │                │ created_at        │   │
│ modified_at     │   │                │ modified_at       │   │
└─────────────────┘   │                └───────────────────┘   │
                      │                                        │
        ┌─────────────┴────────────────────────────────────────┘
        │
┌───────▼─────────┐
│    CATEGORY     │
├─────────────────┤
│ category_id(PK) │
│ category_name   │
│ category_type   │
│ description     │
│ icon            │
│ color           │
│ is_active       │
│ created_at      │
└─────────────────┘

        ┌────────────────────────────────────┐
        │                                    │
┌───────▼─────────┐              ┌──────────▼──────────┐
│     BUDGET      │              │   SAVINGS_GOAL      │
├─────────────────┤              ├─────────────────────┤
│ budget_id (PK)  │              │ goal_id (PK)        │
│ user_id (FK)    │              │ user_id (FK)        │
│ category_id(FK) │              │ goal_name           │
│ budget_amount   │              │ target_amount       │
│ start_date      │              │ current_amount      │
│ end_date        │              │ target_date         │
│ budget_status   │              │ goal_status         │
│ created_at      │              │ created_at          │
│ modified_at     │              │ modified_at         │
└─────────────────┘              └─────────────────────┘
                                           │
                                           │
                                 ┌─────────▼─────────────┐
                                 │ SAVINGS_CONTRIBUTION  │
                                 ├───────────────────────┤
                                 │ contribution_id (PK)  │
                                 │ goal_id (FK)          │
                                 │ contribution_amount   │
                                 │ contribution_date     │
                                 │ contribution_notes    │
                                 │ created_at            │
                                 └───────────────────────┘

┌─────────────────┐
│    SYNC_LOG     │
├─────────────────┤
│ sync_log_id(PK) │
│ user_id (FK)    │───────────────┐
│ sync_start_time │               │
│ sync_end_time   │               │ (back to USER)
│ records_synced  │               │
│ sync_status     │               │
│ error_message   │               │
│ sync_type       │               │
└─────────────────┘               │
                                  │
```

---

## Appendix B: SQL Script Reference

### B.1 SQLite Scripts

**Location**: `D:/DM2_CW/sqlite/`

| File | Lines | Purpose | Key Features |
|------|-------|---------|--------------|
| `01_ddl.sql` | 850 | Database schema | 9 tables, 28 indexes, 10 triggers, 5 views |
| `02_data.sql` | 200 | Initial data | 13 categories, sample data |
| `03_test_data_sri_lankan.sql` | 1,200 | Test data | 5 users, 1,350+ transactions |

### B.2 Oracle Scripts

**Location**: `D:/DM2_CW/oracle/`

| File | Lines | Purpose | Key Features |
|------|-------|---------|--------------|
| `01_ddl.sql` | 650 | Oracle schema | Tables, sequences, tablespaces |
| `02_plsql_crud_package.sql` | 818 | CRUD operations | 31 procedures/functions |
| `03_reports_package.sql` | 720 | Reporting | 5 comprehensive reports |

### B.3 Synchronization Scripts

**Location**: `D:/DM2_CW/synchronization/`

| File | Lines | Purpose | Key Features |
|------|-------|---------|--------------|
| `sync_manager.py` | 620 | Bidirectional sync | Conflict resolution, logging |
| `config.ini` | 20 | Configuration | Database credentials |
| `test_sync_auto.py` | 150 | Automated tests | Sync validation |

---

## Appendix C: Installation and Setup Guide

### C.1 Prerequisites

```bash
# Python 3.9+
python --version

# SQLite 3.35+
sqlite3 --version

# Oracle Database 21c XE
sqlplus -version

# Required Python packages
pip install flask cx_Oracle werkzeug configparser
```

### C.2 Database Setup

**SQLite Setup**:
```bash
cd D:/DM2_CW/sqlite
sqlite3 finance_local.db < 01_ddl.sql
sqlite3 finance_local.db < 02_data.sql
sqlite3 finance_local.db < 03_test_data_sri_lankan.sql
```

**Oracle Setup**:
```bash
sqlplus finance_user/password@localhost:1521/xe
@D:/DM2_CW/oracle/01_ddl.sql
@D:/DM2_CW/oracle/02_plsql_crud_package.sql
@D:/DM2_CW/oracle/03_reports_package.sql
```

### C.3 Application Setup

```bash
cd D:/DM2_CW/webapp
python app.py
# Access at http://localhost:5000
```

### C.4 Configuration

**File**: `synchronization/config.ini`
```ini
[sqlite]
database_path = D:/DM2_CW/sqlite/finance_local.db

[oracle]
username = finance_user
password = your_password
host = 172.20.10.4
port = 1521
service_name = xe
```

---

## Appendix D: Sample Reports Output

### D.1 Monthly Expenditure Report

```
========================================
MONTHLY EXPENDITURE ANALYSIS
User: dilini.fernando
Period: October 2025
========================================

FINANCIAL SUMMARY:
Total Income:      $150,000.00
Total Expenses:    $135,000.00
Net Savings:       $15,000.00
Savings Rate:      10.00%

CATEGORY BREAKDOWN:
Food & Dining      $45,000.00    33.33%  ████████████████████
Transportation     $36,000.00    26.67%  ████████████████
Shopping           $24,000.00    17.78%  ███████████
Entertainment      $15,000.00    11.11%  ███████
Healthcare         $9,000.00     6.67%   ████
Other              $6,000.00     4.44%   ███
```

### D.2 Budget Adherence Report

```
========================================
BUDGET ADHERENCE TRACKING
========================================

Category           Budget        Actual        Variance    Status
Food & Dining      $50,000       $45,000       $5,000      ✓ Under
Transportation     $30,000       $36,000       -$6,000     ✗ Over
Shopping           $25,000       $24,000       $1,000      ⚠ Near Limit
Entertainment      $20,000       $15,000       $5,000      ✓ Under

Overall: 96% of total budget utilized
```

### D.3 Savings Progress Report

```
========================================
SAVINGS GOAL PROGRESS
========================================

Emergency Fund     $500,000      $135,000      27.00%      67 days left
New Laptop         $250,000      $90,000       36.00%      67 days left
Vacation Fund      $300,000      $300,000      100.00%     ✓ Completed
Home Deposit       $1,000,000    $250,000      25.00%      365 days left
```

---

## Appendix E: Test Data Details

### E.1 Test Users

| User ID | Username | Email | Full Name | Expenses | Income |
|---------|----------|-------|-----------|----------|--------|
| 2 | dilini.fernando | dilini.fernando@email.lk | Dilini Fernando | 180 | 54 |
| 3 | kasun.silva | kasun.silva@email.lk | Kasun Silva | 180 | 54 |
| 4 | thilini.perera | thilini.perera@email.lk | Thilini Perera | 180 | 54 |
| 5 | nuwan.rajapaksa | nuwan.rajapaksa@email.lk | Nuwan Rajapaksa | 180 | 54 |
| 6 | sachini.wijesinghe | sachini.wijesinghe@email.lk | Sachini Wijesinghe | 180 | 54 |

### E.2 Data Distribution

```
EXPENSE DISTRIBUTION (per user, 6 months):
- Food & Dining:       30 transactions
- Transportation:      30 transactions
- Shopping:            30 transactions
- Entertainment:       30 transactions
- Healthcare:          30 transactions
- Utilities:           30 transactions

INCOME DISTRIBUTION (per user, 6 months):
- Salary:             6 transactions (monthly)
- Freelance:          24 transactions (weekly)
- Investment:         12 transactions (bi-weekly)
- Gift/Other:         12 transactions (occasional)

BUDGET ALLOCATION (per user):
- 8 budgets (4 monthly, 4 quarterly)

SAVINGS GOALS (per user):
- 4 goals (Emergency Fund, Vacation, Purchase, Long-term)
```

---

## Appendix F: Performance Benchmarks

### F.1 Query Performance

| Query | Without Index | With Index | Improvement |
|-------|--------------|------------|-------------|
| User expenses (month) | 145ms | 6ms | 24.2× |
| Budget utilization | 98ms | 4ms | 24.5× |
| Goal progress | 76ms | 3ms | 25.3× |
| Category totals | 112ms | 5ms | 22.4× |
| Monthly summary | 203ms | 8ms | 25.4× |

### F.2 Synchronization Performance

| Records | Duration | Records/sec |
|---------|----------|-------------|
| 10 | 0.05s | 200 |
| 100 | 0.35s | 286 |
| 500 | 1.42s | 352 |
| 1000 | 2.68s | 373 |
| 1350 | 3.50s | 386 |

### F.3 Report Generation Times

| Report | PL/SQL Execution | CSV Export | Total |
|--------|-----------------|------------|-------|
| Monthly Expenditure | 0.12s | 0.08s | 0.20s |
| Budget Adherence | 0.15s | 0.10s | 0.25s |
| Savings Progress | 0.08s | 0.05s | 0.13s |
| Category Distribution | 0.18s | 0.12s | 0.30s |
| Savings Forecast | 0.22s | 0.15s | 0.37s |

---

## Appendix G: Security Audit Checklist

### G.1 Authentication & Authorization

- [✅] Password hashing with PBKDF2-SHA256
- [✅] 600,000 iterations for key derivation
- [✅] 16-byte random salt per password
- [✅] Session timeout (30 minutes)
- [✅] Secure cookie flags (HTTPONLY, SECURE, SAMESITE)
- [✅] User-based data filtering
- [✅] Authorization checks before operations

### G.2 SQL Injection Prevention

- [✅] Parameterized queries in SQLite
- [✅] Bind variables in Oracle
- [✅] Input validation (type, range, format)
- [✅] Enum validation for categorical data
- [✅] No dynamic SQL construction
- [✅] ORM usage where applicable

### G.3 Data Protection

- [✅] HTTPS in production (TLS 1.3)
- [✅] Database file permissions (SQLite)
- [✅] Oracle user privileges (least privilege)
- [✅] Backup encryption
- [✅] Audit logging enabled
- [✅] GDPR compliance (data export/erasure)

---

## Appendix H: Deployment Checklist

### H.1 Pre-Deployment

- [ ] Code review completed
- [ ] All tests passing (65/65)
- [ ] Documentation updated
- [ ] Security audit passed
- [ ] Performance benchmarks met
- [ ] Backup procedures tested
- [ ] Rollback plan documented

### H.2 Deployment Steps

- [ ] Create production database backups
- [ ] Deploy SQLite database
- [ ] Deploy Oracle schema
- [ ] Configure production settings
- [ ] Deploy web application
- [ ] Configure web server (nginx/Apache)
- [ ] Enable SSL certificates
- [ ] Configure firewall rules
- [ ] Set up monitoring (Prometheus/Grafana)
- [ ] Configure log rotation

### H.3 Post-Deployment

- [ ] Smoke testing completed
- [ ] Performance monitoring active
- [ ] Error tracking enabled (Sentry)
- [ ] Backup automation verified
- [ ] User acceptance testing
- [ ] Documentation accessible
- [ ] Support procedures established

---

## Appendix I: Troubleshooting Guide

### I.1 Common Issues

**Issue**: Sync fails with "Oracle connection refused"
**Solution**: 
1. Verify Oracle listener running: `lsnrctl status`
2. Check firewall rules: `telnet 172.20.10.4 1521`
3. Verify credentials in config.ini

**Issue**: SQLite database locked
**Solution**:
1. Close all connections
2. Enable WAL mode: `PRAGMA journal_mode=WAL;`
3. Check file permissions

**Issue**: Reports not generating
**Solution**:
1. Verify PL/SQL packages compiled: `SELECT object_name, status FROM user_objects WHERE object_type='PACKAGE';`
2. Check UTL_FILE permissions
3. Verify DATA_PUMP_DIR directory exists

### I.2 Debug Mode

```python
# Enable Flask debug mode
app.config['DEBUG'] = True
app.config['EXPLAIN_TEMPLATE_LOADING'] = True

# Enable SQL logging (SQLite)
sqlite3.enable_callback_tracebacks(True)

# Enable Oracle tracing
os.environ['TNS_ADMIN'] = '/path/to/tnsnames.ora'
```

---

## Appendix J: Project Structure

```
D:/DM2_CW/
├── sqlite/                      # SQLite database files
│   ├── finance_local.db        # Main database (524 KB)
│   ├── 01_ddl.sql              # Schema (850 lines)
│   ├── 02_data.sql             # Initial data
│   └── 03_test_data_sri_lankan.sql  # Test data (1,200 lines)
│
├── oracle/                      # Oracle scripts
│   ├── 01_ddl.sql              # Schema (650 lines)
│   ├── 02_plsql_crud_package.sql    # CRUD (818 lines)
│   └── 03_reports_package.sql       # Reports (720 lines)
│
├── synchronization/             # Sync module
│   ├── sync_manager.py         # Main sync (620 lines)
│   ├── config.ini              # Configuration
│   └── test_sync_auto.py       # Tests (150 lines)
│
├── webapp/                      # Web application
│   ├── app.py                  # Flask app (2,220 lines)
│   ├── templates/              # HTML templates
│   ├── static/                 # CSS, JS, images
│   └── requirements.txt        # Dependencies
│
├── tests/                       # Test files
│   ├── test_sqlite_schema.py
│   ├── test_plsql_procedures.sql
│   ├── test_sync.py
│   ├── test_webapp.py
│   └── test_performance.py
│
├── backups/                     # Database backups
│   ├── sqlite/
│   └── oracle/
│
├── logs/                        # Application logs
│   ├── sync_log.txt
│   ├── app.log
│   └── error.log
│
├── scripts/                     # Utility scripts
│   ├── backup_sqlite.py
│   ├── backup_oracle.sh
│   └── generate_test_data.py
│
└── documentation_finalReport/   # Documentation
    └── finalReportLatest/      # Modular report
        ├── 00-README.md
        ├── 01-toc.md
        ├── 02-introduction.md
        ├── 03-database-design.md
        ├── 04-sqlite-implementation.md
        ├── 05-oracle-plsql.md
        ├── 06-synchronization.md
        ├── 07-generated-reports.md
        ├── 08-security-privacy.md
        ├── 09-backup-recovery.md
        ├── 10-migration-plan.md
        ├── 11-testing.md
        ├── 12-conclusion.md
        ├── 13-references.md
        └── 14-appendices.md
```

**Total Project Size**: ~12 MB (code + database + documentation)  
**Total Files**: 60+  
**Total Lines of Code**: 10,000+

---

**END OF APPENDICES**
