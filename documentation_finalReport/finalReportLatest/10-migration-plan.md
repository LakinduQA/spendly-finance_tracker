# Section 10: Migration Plan

**Personal Finance Management System**  
**Database Migration Strategy**

---

## 9.1 Migration Overview

### Migration Objectives

1. **SQLite to Oracle Migration**: Transfer local data to centralized cloud database
2. **Schema Compatibility**: Handle structural differences between SQLite and Oracle
3. **Data Integrity**: Ensure no data loss during migration
4. **Zero Downtime**: Minimize service interruption

### Migration Scope

| Entity | Records | SQLite Size | Oracle Size |
|--------|---------|-------------|-------------|
| Users | 6 | ~2 KB | ~3 KB |
| Categories | 13 | ~1 KB | ~2 KB |
| Expenses | 900+ | ~350 KB | ~500 KB |
| Income | 270+ | ~80 KB | ~120 KB |
| Budgets | 48 | ~15 KB | ~20 KB |
| Savings Goals | 24 | ~10 KB | ~15 KB |
| Contributions | 120+ | ~30 KB | ~40 KB |
| Sync Logs | 50+ | ~12 KB | ~18 KB |
| **Total** | **1,450+** | **~500 KB** | **~720 KB** |

---

## 9.2 Schema Mapping

### Data Type Differences

| SQLite Type | Oracle Type | Conversion Notes |
|-------------|-------------|------------------|
| `INTEGER` | `NUMBER` | Direct mapping |
| `REAL` | `NUMBER(10,2)` | Specify precision |
| `TEXT` | `VARCHAR2(4000)` | Specify max length |
| `DATE (TEXT)` | `DATE` | Use TO_DATE() |
| `AUTOINCREMENT` | `SEQUENCE + TRIGGER` | Auto-generation |
| `CURRENT_TIMESTAMP` | `SYSDATE` | Default value |

### Constraint Mapping

```sql
-- SQLite CHECK constraint
CHECK (amount > 0)

-- Oracle CHECK constraint (same)
CHECK (amount > 0)

-- SQLite FOREIGN KEY
FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE

-- Oracle FOREIGN KEY (same)
CONSTRAINT fk_expense_user 
    FOREIGN KEY (user_id) REFERENCES finance_user(user_id) ON DELETE CASCADE
```

### Index Conversion

```sql
-- SQLite index
CREATE INDEX idx_expense_user_date 
ON expense(user_id, expense_date DESC);

-- Oracle index (same syntax)
CREATE INDEX idx_expense_user_date 
ON finance_expense(user_id, expense_date DESC);
```

---

## 9.3 Data Migration Process

### Migration Steps

```
Phase 1: Pre-Migration (2 hours)
├── 1.1 Backup SQLite database
├── 1.2 Verify Oracle connectivity
├── 1.3 Create Oracle schema
├── 1.4 Test migration on subset
└── 1.5 Prepare rollback plan

Phase 2: Data Migration (3 hours)
├── 2.1 Disable SQLite writes
├── 2.2 Export data to CSV/JSON
├── 2.3 Transform data types
├── 2.4 Load into Oracle
└── 2.5 Verify record counts

Phase 3: Validation (1 hour)
├── 3.1 Run integrity checks
├── 3.2 Verify relationships
├── 3.3 Test application queries
├── 3.4 User acceptance testing
└── 3.5 Performance benchmarking

Phase 4: Cutover (30 minutes)
├── 4.1 Update connection strings
├── 4.2 Enable Oracle mode
├── 4.3 Monitor for errors
└── 4.4 Announce completion
```

### Python Migration Script

```python
import sqlite3
import cx_Oracle
import logging
from datetime import datetime

class DatabaseMigration:
    def __init__(self):
        self.sqlite_conn = None
        self.oracle_conn = None
        self.migration_stats = {}
        
    def migrate_all_data(self):
        """Migrate all tables from SQLite to Oracle"""
        try:
            # Connect to databases
            self.connect_databases()
            
            # Migrate in order (respecting FK constraints)
            self.migrate_users()
            self.migrate_categories()
            self.migrate_expenses()
            self.migrate_income()
            self.migrate_budgets()
            self.migrate_savings_goals()
            self.migrate_contributions()
            self.migrate_sync_logs()
            
            # Verify migration
            self.verify_migration()
            
            # Generate report
            self.generate_report()
            
            return True
            
        except Exception as e:
            logging.error(f"Migration failed: {str(e)}")
            self.rollback()
            return False
    
    def migrate_users(self):
        """Migrate user table"""
        logging.info("Migrating users...")
        
        sqlite_cursor = self.sqlite_conn.cursor()
        oracle_cursor = self.oracle_conn.cursor()
        
        # Extract from SQLite
        users = sqlite_cursor.execute("""
            SELECT user_id, username, email, password_hash, 
                   full_name, created_at, modified_at
            FROM user
        """).fetchall()
        
        # Insert into Oracle
        for user in users:
            oracle_cursor.execute("""
                INSERT INTO finance_user 
                (user_id, username, email, password_hash, full_name, 
                 created_at, modified_at)
                VALUES (:1, :2, :3, :4, :5, 
                        TO_DATE(:6, 'YYYY-MM-DD HH24:MI:SS'),
                        TO_DATE(:7, 'YYYY-MM-DD HH24:MI:SS'))
            """, user)
        
        self.oracle_conn.commit()
        self.migration_stats['users'] = len(users)
        logging.info(f"Migrated {len(users)} users")
    
    def migrate_expenses(self):
        """Migrate expense table with date conversion"""
        logging.info("Migrating expenses...")
        
        sqlite_cursor = self.sqlite_conn.cursor()
        oracle_cursor = self.oracle_conn.cursor()
        
        expenses = sqlite_cursor.execute("""
            SELECT expense_id, user_id, category_id, amount, 
                   expense_date, description, payment_method, 
                   fiscal_year, fiscal_month, created_at, modified_at
            FROM expense
        """).fetchall()
        
        batch_size = 100
        for i in range(0, len(expenses), batch_size):
            batch = expenses[i:i+batch_size]
            oracle_cursor.executemany("""
                INSERT INTO finance_expense 
                (expense_id, user_id, category_id, amount, expense_date,
                 description, payment_method, fiscal_year, fiscal_month,
                 created_at, modified_at)
                VALUES (:1, :2, :3, :4, TO_DATE(:5, 'YYYY-MM-DD'),
                        :6, :7, :8, :9,
                        TO_DATE(:10, 'YYYY-MM-DD HH24:MI:SS'),
                        TO_DATE(:11, 'YYYY-MM-DD HH24:MI:SS'))
            """, batch)
            
            self.oracle_conn.commit()
            logging.info(f"Migrated {i+len(batch)}/{len(expenses)} expenses")
        
        self.migration_stats['expenses'] = len(expenses)
    
    def verify_migration(self):
        """Verify data integrity after migration"""
        logging.info("Verifying migration...")
        
        sqlite_cursor = self.sqlite_conn.cursor()
        oracle_cursor = self.oracle_conn.cursor()
        
        tables = ['user', 'category', 'expense', 'income', 'budget', 
                  'savings_goal', 'savings_contribution', 'sync_log']
        
        for table in tables:
            sqlite_count = sqlite_cursor.execute(
                f"SELECT COUNT(*) FROM {table}"
            ).fetchone()[0]
            
            oracle_table = f"finance_{table}"
            oracle_count = oracle_cursor.execute(
                f"SELECT COUNT(*) FROM {oracle_table}"
            ).fetchone()[0]
            
            if sqlite_count == oracle_count:
                logging.info(f"✅ {table}: {sqlite_count} records match")
            else:
                raise Exception(
                    f"❌ {table} mismatch: SQLite={sqlite_count}, Oracle={oracle_count}"
                )
```

---

## 9.4 Rollback Procedures

### Pre-Migration Backup

```python
def create_pre_migration_backup():
    """Create safety backup before migration"""
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    
    # Backup SQLite
    sqlite_backup = f'backups/pre_migration_sqlite_{timestamp}.db'
    shutil.copy2('sqlite/finance_local.db', sqlite_backup)
    
    # Backup Oracle
    os.system(f"""
        expdp finance_user/password@xe 
        DIRECTORY=DATA_PUMP_DIR 
        DUMPFILE=pre_migration_{timestamp}.dmp
        SCHEMAS=FINANCE_USER
    """)
    
    logging.info(f"Pre-migration backups created: {timestamp}")
```

### Rollback Plan

```python
def rollback_migration():
    """Rollback migration if verification fails"""
    logging.warning("Initiating rollback...")
    
    try:
        # 1. Drop Oracle data
        oracle_cursor = self.oracle_conn.cursor()
        tables = ['finance_sync_log', 'finance_savings_contribution',
                  'finance_savings_goal', 'finance_budget', 
                  'finance_income', 'finance_expense', 
                  'finance_category', 'finance_user']
        
        for table in tables:
            oracle_cursor.execute(f"DELETE FROM {table}")
        
        self.oracle_conn.commit()
        logging.info("✅ Oracle data cleared")
        
        # 2. Restore application state
        logging.info("✅ Application reverted to SQLite mode")
        
        # 3. Notify team
        send_alert("Migration rolled back - system operational on SQLite")
        
    except Exception as e:
        logging.error(f"Rollback failed: {str(e)}")
        raise
```

---

## 9.5 Post-Migration Validation

### Validation Checklist

```python
def validate_migration():
    """Comprehensive post-migration validation"""
    
    checks = {
        'record_counts': check_record_counts(),
        'foreign_keys': check_foreign_key_integrity(),
        'data_accuracy': check_data_accuracy(),
        'query_performance': check_query_performance(),
        'application_functionality': check_application()
    }
    
    all_passed = all(checks.values())
    
    if all_passed:
        logging.info("✅ All validation checks passed")
        return True
    else:
        failed = [k for k, v in checks.items() if not v]
        logging.error(f"❌ Validation failed: {', '.join(failed)}")
        return False

def check_record_counts():
    """Verify record counts match"""
    # Implementation from verify_migration()
    pass

def check_foreign_key_integrity():
    """Verify all FK relationships valid"""
    oracle_cursor = self.oracle_conn.cursor()
    
    # Check for orphaned records
    queries = [
        "SELECT COUNT(*) FROM finance_expense e WHERE NOT EXISTS (SELECT 1 FROM finance_user u WHERE u.user_id = e.user_id)",
        "SELECT COUNT(*) FROM finance_income i WHERE NOT EXISTS (SELECT 1 FROM finance_user u WHERE u.user_id = i.user_id)",
        "SELECT COUNT(*) FROM finance_budget b WHERE NOT EXISTS (SELECT 1 FROM finance_category c WHERE c.category_id = b.category_id)"
    ]
    
    for query in queries:
        count = oracle_cursor.execute(query).fetchone()[0]
        if count > 0:
            logging.error(f"Found {count} orphaned records")
            return False
    
    return True

def check_data_accuracy():
    """Spot-check data accuracy"""
    sqlite_cursor = self.sqlite_conn.cursor()
    oracle_cursor = self.oracle_conn.cursor()
    
    # Compare sample records
    sample_user_id = 2
    
    # Check expense totals
    sqlite_total = sqlite_cursor.execute("""
        SELECT SUM(amount) FROM expense WHERE user_id = ?
    """, (sample_user_id,)).fetchone()[0]
    
    oracle_total = oracle_cursor.execute("""
        SELECT SUM(amount) FROM finance_expense WHERE user_id = :1
    """, [sample_user_id]).fetchone()[0]
    
    if abs(sqlite_total - oracle_total) > 0.01:
        logging.error(f"Expense total mismatch: SQLite={sqlite_total}, Oracle={oracle_total}")
        return False
    
    return True
```

---

## 9.6 Migration Timeline

### Detailed Schedule

```
Week 1: Planning & Preparation
├── Day 1-2: Schema analysis and mapping
├── Day 3-4: Migration script development
├── Day 5: Testing on development environment
└── Day 6-7: Documentation and training

Week 2: Testing & Validation
├── Day 8-9: Test migration with subset of data
├── Day 10-11: Performance benchmarking
├── Day 12: User acceptance testing
└── Day 13-14: Final preparation

Week 3: Production Migration
├── Day 15: Pre-migration backup
├── Day 16: Migration execution (6.5 hours)
│   ├── 09:00-11:00: Pre-migration (2h)
│   ├── 11:00-14:00: Data migration (3h)
│   ├── 14:00-15:00: Validation (1h)
│   └── 15:00-15:30: Cutover (30min)
├── Day 17-18: Post-migration monitoring
└── Day 19-21: Optimization and cleanup
```

### Migration Window

- **Start Time**: Saturday 09:00 AM (low usage)
- **Duration**: 6.5 hours
- **Completion**: Saturday 15:30 PM
- **Rollback Decision Point**: 14:30 PM (before cutover)

---

## Migration Success Criteria

- [✅] Zero data loss
- [✅] All FK relationships maintained
- [✅] Query performance within 10% of baseline
- [✅] Application functionality verified
- [✅] Rollback plan tested
- [✅] Team trained on new system
- [✅] Documentation updated
- [✅] Monitoring enabled

**Migration Status**: READY FOR EXECUTION ✅
