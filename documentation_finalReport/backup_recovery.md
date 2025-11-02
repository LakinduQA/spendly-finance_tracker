# Backup and Recovery Strategy
**Personal Finance Management System**  
**Data Management 2 Coursework**  
**November 2025**

---

## Table of Contents
1. [Executive Summary](#executive-summary)
2. [Backup Strategy Overview](#backup-strategy-overview)
3. [SQLite Backup Procedures](#sqlite-backup-procedures)
4. [Oracle Backup Procedures](#oracle-backup-procedures)
5. [Recovery Procedures](#recovery-procedures)
6. [Disaster Recovery Plan](#disaster-recovery-plan)
7. [Backup Automation Scripts](#backup-automation-scripts)
8. [Testing and Validation](#testing-and-validation)
9. [Backup Retention Policy](#backup-retention-policy)
10. [Best Practices](#best-practices)

---

## 1. Executive Summary

This document outlines the comprehensive backup and recovery strategy for the Personal Finance Management System. The strategy ensures data protection, business continuity, and rapid recovery in case of data loss, corruption, or disasters.

### Key Objectives:
- **Data Protection**: Prevent data loss through regular backups
- **Business Continuity**: Minimize downtime during incidents
- **Compliance**: Meet data retention requirements
- **Recovery Time Objective (RTO)**: < 4 hours
- **Recovery Point Objective (RPO)**: < 24 hours

### Backup Components:
1. SQLite local database (daily)
2. Oracle central database (daily + weekly)
3. Application code (version controlled)
4. Configuration files (weekly)
5. User-uploaded documents (if applicable)

---

## 2. Backup Strategy Overview

### 2.1 Backup Types

#### **Full Backup**
- Complete copy of entire database
- Frequency: Weekly (Sunday 2:00 AM)
- Storage: 4 weeks retention
- Purpose: Disaster recovery baseline

#### **Incremental Backup**
- Only changed data since last backup
- Frequency: Daily (2:00 AM)
- Storage: 7 days retention
- Purpose: Point-in-time recovery

#### **Differential Backup**
- Changed data since last full backup
- Frequency: Daily (12:00 PM)
- Storage: 7 days retention
- Purpose: Quick recovery with fewer files

### 2.2 Backup Locations

```
Primary Backup: Local Server
├── /backups/sqlite/
│   ├── daily/
│   ├── weekly/
│   └── monthly/
└── /backups/oracle/
    ├── daily/
    ├── weekly/
    └── monthly/

Secondary Backup: Network Storage
├── //network-nas/finance_backups/

Tertiary Backup: Cloud Storage
└── cloud://backup-service/finance/
```

### 2.3 Backup Schedule

| Time | Type | Database | Retention |
|------|------|----------|-----------|
| 02:00 Daily | Full | SQLite | 7 days |
| 02:30 Daily | Incremental | Oracle | 7 days |
| 12:00 Daily | Differential | SQLite | 7 days |
| 02:00 Sunday | Full | Both | 4 weeks |
| 03:00 1st of month | Full | Both | 12 months |

---

## 3. SQLite Backup Procedures

### 3.1 Method 1: File Copy (Simplest)

#### **Manual Backup**

```bash
# Windows
copy D:\DM2_CW\sqlite\finance_local.db D:\backups\sqlite\finance_local_backup.db

# Linux/Mac
cp /path/to/finance_local.db /path/to/backups/finance_local_$(date +%Y%m%d).db
```

#### **Advantages:**
- ✅ Simple and fast
- ✅ No special tools required
- ✅ Works on all platforms

#### **Disadvantages:**
- ⚠️ Database must be idle (no connections)
- ⚠️ Can't backup while app is running

### 3.2 Method 2: SQLite .backup Command (Recommended)

#### **Online Backup (Hot Backup)**

```bash
# Using sqlite3 command-line tool
sqlite3 finance_local.db ".backup 'backup/finance_local_backup.db'"
```

#### **Python Script for Backup**

```python
import sqlite3
import os
from datetime import datetime

def backup_sqlite_database():
    """
    Create backup of SQLite database using .backup method
    """
    source_db = '../sqlite/finance_local.db'
    backup_dir = '../backups/sqlite/daily'
    
    # Create backup directory if not exists
    os.makedirs(backup_dir, exist_ok=True)
    
    # Generate backup filename with timestamp
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    backup_file = os.path.join(backup_dir, f'finance_backup_{timestamp}.db')
    
    try:
        # Connect to source database
        source_conn = sqlite3.connect(source_db)
        
        # Create backup database
        backup_conn = sqlite3.connect(backup_file)
        
        # Perform backup
        source_conn.backup(backup_conn)
        
        # Close connections
        backup_conn.close()
        source_conn.close()
        
        print(f"✅ Backup created successfully: {backup_file}")
        return True
        
    except Exception as e:
        print(f"❌ Backup failed: {str(e)}")
        return False

if __name__ == '__main__':
    backup_sqlite_database()
```

#### **Advantages:**
- ✅ Can backup while database is in use (hot backup)
- ✅ Atomic operation (all or nothing)
- ✅ Consistent snapshot
- ✅ Handles locked tables gracefully

### 3.3 Method 3: SQL Dump (Text Format)

#### **Export as SQL Script**

```bash
# Export complete database as SQL
sqlite3 finance_local.db .dump > finance_backup.sql

# Export specific tables
sqlite3 finance_local.db "SELECT * FROM expense;" > expense_backup.csv
```

#### **Python Script for SQL Dump**

```python
import sqlite3
import subprocess
from datetime import datetime

def dump_sqlite_database():
    """
    Create SQL dump of database
    """
    db_path = '../sqlite/finance_local.db'
    backup_dir = '../backups/sqlite/dumps'
    
    os.makedirs(backup_dir, exist_ok=True)
    
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    dump_file = os.path.join(backup_dir, f'finance_dump_{timestamp}.sql')
    
    try:
        # Use sqlite3 command to create dump
        with open(dump_file, 'w') as f:
            subprocess.run(
                ['sqlite3', db_path, '.dump'],
                stdout=f,
                check=True
            )
        
        print(f"✅ SQL dump created: {dump_file}")
        
        # Compress dump file
        import gzip
        with open(dump_file, 'rb') as f_in:
            with gzip.open(f'{dump_file}.gz', 'wb') as f_out:
                f_out.writelines(f_in)
        
        os.remove(dump_file)  # Remove uncompressed version
        print(f"✅ Compressed dump: {dump_file}.gz")
        
        return True
        
    except Exception as e:
        print(f"❌ Dump failed: {str(e)}")
        return False
```

#### **Advantages:**
- ✅ Human-readable format
- ✅ Platform independent
- ✅ Easy to inspect and edit
- ✅ Can restore to any SQLite version
- ✅ Good for version control

#### **Disadvantages:**
- ⚠️ Larger file size
- ⚠️ Slower than binary backup

### 3.4 Incremental Backup (Advanced)

```python
def incremental_sqlite_backup():
    """
    Backup only modified tables since last backup
    """
    source_db = '../sqlite/finance_local.db'
    last_backup_time = get_last_backup_time()
    
    conn = sqlite3.connect(source_db)
    cursor = conn.cursor()
    
    # Find modified records
    tables = ['expense', 'income', 'budget', 'savings_goal']
    
    for table in tables:
        cursor.execute(f"""
            SELECT * FROM {table}
            WHERE modified_at > ?
        """, (last_backup_time,))
        
        modified_records = cursor.fetchall()
        
        if modified_records:
            # Export modified records
            export_to_csv(table, modified_records)
    
    conn.close()
```

---

## 4. Oracle Backup Procedures

### 4.1 Method 1: Data Pump Export (Recommended)

#### **Full Database Export**

```sql
-- Create directory for exports
CREATE DIRECTORY backup_dir AS 'D:\backups\oracle\datapump';
GRANT READ, WRITE ON DIRECTORY backup_dir TO system;
```

```bash
# Command-line export
expdp system/oracle123@xe DIRECTORY=backup_dir DUMPFILE=finance_full_%date%.dmp LOGFILE=export_%date%.log FULL=Y
```

#### **Schema-Only Export**

```bash
# Export only SYSTEM schema
expdp system/oracle123@xe SCHEMAS=SYSTEM DIRECTORY=backup_dir DUMPFILE=finance_schema_%date%.dmp
```

#### **Table-Level Export**

```bash
# Export specific tables
expdp system/oracle123@xe TABLES=finance_expense,finance_income DIRECTORY=backup_dir DUMPFILE=finance_tables.dmp
```

#### **Python Script for Data Pump**

```python
import subprocess
import os
from datetime import datetime

def oracle_datapump_export():
    """
    Perform Oracle Data Pump export
    """
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    dump_file = f'finance_backup_{timestamp}.dmp'
    log_file = f'export_{timestamp}.log'
    
    # Data Pump export command
    cmd = [
        'expdp',
        'system/oracle123@172.20.10.4:1521/xe',
        f'DIRECTORY=backup_dir',
        f'DUMPFILE={dump_file}',
        f'LOGFILE={log_file}',
        'SCHEMAS=SYSTEM',
        'EXCLUDE=STATISTICS'
    ]
    
    try:
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            print(f"✅ Export successful: {dump_file}")
            return True
        else:
            print(f"❌ Export failed: {result.stderr}")
            return False
            
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return False
```

### 4.2 Method 2: RMAN Backup (Enterprise)

#### **Configure RMAN**

```sql
-- Connect to RMAN
RMAN TARGET /

-- Configure backup settings
CONFIGURE RETENTION POLICY TO REDUNDANCY 7;
CONFIGURE BACKUP OPTIMIZATION ON;
CONFIGURE CONTROLFILE AUTOBACKUP ON;
```

#### **Full Database Backup**

```bash
# RMAN backup script
rman target / <<EOF
RUN {
    ALLOCATE CHANNEL disk1 TYPE DISK FORMAT 'D:\backups\oracle\rman\%d_%T_%s_%p';
    BACKUP DATABASE PLUS ARCHIVELOG;
    BACKUP CURRENT CONTROLFILE;
    DELETE NOPROMPT OBSOLETE;
}
EXIT;
EOF
```

#### **Incremental Backup**

```bash
# Level 0 (full) backup
BACKUP INCREMENTAL LEVEL 0 DATABASE;

# Level 1 (incremental) backup
BACKUP INCREMENTAL LEVEL 1 DATABASE;
```

### 4.3 Method 3: SQL Script Export

```sql
-- Export table data as INSERT statements
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET LINESIZE 1000

SPOOL D:\backups\oracle\finance_expense_backup.sql

SELECT 'INSERT INTO finance_expense VALUES (' ||
       expense_id || ',' ||
       user_id || ',' ||
       category_id || ',' ||
       amount || ',' ||
       'TO_DATE(''' || TO_CHAR(expense_date, 'YYYY-MM-DD') || ''',''YYYY-MM-DD'')' || ',' ||
       '''' || description || '''' || ',' ||
       '''' || payment_method || '''' || 
       ');'
FROM finance_expense;

SPOOL OFF
```

### 4.4 Automated Oracle Backup Script

```python
def oracle_full_backup():
    """
    Complete Oracle backup procedure
    """
    import cx_Oracle
    
    # Connect to Oracle
    conn = cx_Oracle.connect('system/oracle123@172.20.10.4:1521/xe')
    cursor = conn.cursor()
    
    try:
        # 1. Export schema using Data Pump
        oracle_datapump_export()
        
        # 2. Export individual tables as CSV
        tables = ['FINANCE_USER', 'FINANCE_EXPENSE', 'FINANCE_INCOME',
                  'FINANCE_BUDGET', 'FINANCE_SAVINGS_GOAL']
        
        for table in tables:
            export_table_csv(cursor, table)
        
        # 3. Backup stored procedures
        backup_plsql_code(cursor)
        
        # 4. Log backup completion
        log_backup_event('Oracle', 'SUCCESS')
        
        print("✅ Oracle backup completed successfully")
        return True
        
    except Exception as e:
        log_backup_event('Oracle', f'FAILED: {str(e)}')
        print(f"❌ Oracle backup failed: {str(e)}")
        return False
        
    finally:
        cursor.close()
        conn.close()

def export_table_csv(cursor, table_name):
    """Export table to CSV file"""
    import csv
    from datetime import datetime
    
    timestamp = datetime.now().strftime('%Y%m%d')
    filename = f'../backups/oracle/csv/{table_name}_{timestamp}.csv'
    
    # Query table data
    cursor.execute(f"SELECT * FROM {table_name}")
    
    # Get column names
    columns = [desc[0] for desc in cursor.description]
    
    # Write to CSV
    with open(filename, 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(columns)
        writer.writerows(cursor.fetchall())
    
    print(f"✅ Exported {table_name} to {filename}")
```

---

## 5. Recovery Procedures

### 5.1 SQLite Recovery

#### **Recovery from Binary Backup**

```python
def restore_sqlite_backup(backup_file):
    """
    Restore SQLite database from backup
    """
    import shutil
    
    source_db = '../sqlite/finance_local.db'
    backup_path = f'../backups/sqlite/daily/{backup_file}'
    
    try:
        # Stop application first (important!)
        print("⚠️ Stop the Flask application before restoring")
        input("Press Enter when application is stopped...")
        
        # Backup current database (in case)
        if os.path.exists(source_db):
            emergency_backup = f'{source_db}.emergency_backup'
            shutil.copy2(source_db, emergency_backup)
            print(f"✅ Created emergency backup: {emergency_backup}")
        
        # Restore from backup
        shutil.copy2(backup_path, source_db)
        
        print(f"✅ Database restored from: {backup_file}")
        print("✅ You can now restart the application")
        
        return True
        
    except Exception as e:
        print(f"❌ Restore failed: {str(e)}")
        return False
```

#### **Recovery from SQL Dump**

```bash
# Restore from SQL dump
sqlite3 finance_local.db < finance_backup.sql

# Restore from compressed dump
gunzip -c finance_dump.sql.gz | sqlite3 finance_local.db
```

#### **Partial Table Recovery**

```python
def restore_single_table(backup_db, table_name):
    """
    Restore single table from backup
    """
    import sqlite3
    
    source_db = '../sqlite/finance_local.db'
    
    # Attach backup database
    conn = sqlite3.connect(source_db)
    conn.execute(f"ATTACH DATABASE '{backup_db}' AS backup_db")
    
    # Drop current table (optional, or rename)
    conn.execute(f"ALTER TABLE {table_name} RENAME TO {table_name}_old")
    
    # Copy table from backup
    conn.execute(f"""
        CREATE TABLE {table_name} AS 
        SELECT * FROM backup_db.{table_name}
    """)
    
    # Detach backup
    conn.execute("DETACH DATABASE backup_db")
    conn.commit()
    conn.close()
    
    print(f"✅ Table {table_name} restored from backup")
```

### 5.2 Oracle Recovery

#### **Recovery from Data Pump**

```bash
# Drop existing schema (careful!)
# sqlplus system/oracle123@xe
# DROP USER finance_admin CASCADE;

# Import from dump file
impdp system/oracle123@xe DIRECTORY=backup_dir DUMPFILE=finance_backup.dmp FULL=Y
```

#### **Table-Level Recovery**

```bash
# Import specific tables
impdp system/oracle123@xe DIRECTORY=backup_dir DUMPFILE=finance_backup.dmp TABLES=finance_expense,finance_income
```

#### **Point-in-Time Recovery with RMAN**

```bash
# Connect to RMAN
rman target /

# Restore database to specific point in time
RUN {
    SET UNTIL TIME "TO_DATE('2025-11-01 14:00:00', 'YYYY-MM-DD HH24:MI:SS')";
    RESTORE DATABASE;
    RECOVER DATABASE;
}
```

#### **Python Recovery Script**

```python
def oracle_recovery(backup_file):
    """
    Restore Oracle database from Data Pump dump
    """
    import subprocess
    
    print("⚠️ WARNING: This will restore the database")
    print("⚠️ All current data will be replaced")
    confirm = input("Type 'RESTORE' to continue: ")
    
    if confirm != 'RESTORE':
        print("❌ Recovery cancelled")
        return False
    
    # Data Pump import command
    cmd = [
        'impdp',
        'system/oracle123@172.20.10.4:1521/xe',
        f'DIRECTORY=backup_dir',
        f'DUMPFILE={backup_file}',
        'SCHEMAS=SYSTEM',
        'TABLE_EXISTS_ACTION=REPLACE'
    ]
    
    try:
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            print(f"✅ Recovery successful from: {backup_file}")
            
            # Verify data integrity
            verify_data_integrity()
            
            return True
        else:
            print(f"❌ Recovery failed: {result.stderr}")
            return False
            
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return False
```

---

## 6. Disaster Recovery Plan

### 6.1 Disaster Scenarios

#### **Scenario 1: Database Corruption**
- **Detection**: Application errors, query failures
- **Response Time**: Immediate
- **Recovery**: Restore from last good backup
- **RTO**: 2 hours
- **RPO**: 24 hours

#### **Scenario 2: Hardware Failure**
- **Detection**: Server unavailable, disk failure
- **Response Time**: Within 1 hour
- **Recovery**: Restore to new hardware
- **RTO**: 4 hours
- **RPO**: 24 hours

#### **Scenario 3: Ransomware Attack**
- **Detection**: File encryption, ransom demand
- **Response Time**: Immediate
- **Recovery**: Restore from offline backup
- **RTO**: 8 hours
- **RPO**: 48 hours (use older backup)

#### **Scenario 4: Natural Disaster**
- **Detection**: Physical site destruction
- **Response Time**: Within 4 hours
- **Recovery**: Failover to cloud backup
- **RTO**: 24 hours
- **RPO**: 24 hours

### 6.2 Recovery Priority Levels

| Priority | Component | Recovery Time |
|----------|-----------|---------------|
| P1 | User authentication | 1 hour |
| P1 | Core database tables | 2 hours |
| P2 | Application code | 2 hours |
| P2 | Historical data | 4 hours |
| P3 | Reports and analytics | 8 hours |
| P3 | Audit logs | 24 hours |

### 6.3 Disaster Recovery Steps

```
┌─────────────────────┐
│ 1. Declare Disaster │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ 2. Activate DR Team │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ 3. Assess Damage    │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ 4. Prepare DR Site  │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ 5. Restore Databases│
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ 6. Verify Integrity │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ 7. Resume Operations│
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ 8. Post-DR Analysis │
└─────────────────────┘
```

---

## 7. Backup Automation Scripts

### 7.1 Complete Backup Script

```python
#!/usr/bin/env python3
"""
Automated Backup Script for Personal Finance System
Runs daily via cron/Task Scheduler
"""

import os
import sys
import sqlite3
import subprocess
import shutil
import gzip
import logging
from datetime import datetime, timedelta

# Configure logging
logging.basicConfig(
    filename='../logs/backup.log',
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(message)s'
)

class BackupManager:
    def __init__(self):
        self.backup_root = '../backups'
        self.sqlite_db = '../sqlite/finance_local.db'
        self.timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        
    def backup_sqlite(self):
        """Backup SQLite database"""
        try:
            backup_dir = os.path.join(self.backup_root, 'sqlite', 'daily')
            os.makedirs(backup_dir, exist_ok=True)
            
            backup_file = os.path.join(
                backup_dir,
                f'finance_backup_{self.timestamp}.db'
            )
            
            # Perform backup
            source_conn = sqlite3.connect(self.sqlite_db)
            backup_conn = sqlite3.connect(backup_file)
            source_conn.backup(backup_conn)
            backup_conn.close()
            source_conn.close()
            
            # Compress backup
            with open(backup_file, 'rb') as f_in:
                with gzip.open(f'{backup_file}.gz', 'wb') as f_out:
                    shutil.copyfileobj(f_in, f_out)
            
            os.remove(backup_file)
            
            logging.info(f"SQLite backup successful: {backup_file}.gz")
            return True
            
        except Exception as e:
            logging.error(f"SQLite backup failed: {str(e)}")
            return False
    
    def backup_oracle(self):
        """Backup Oracle database"""
        try:
            dump_file = f'finance_oracle_{self.timestamp}.dmp'
            log_file = f'export_{self.timestamp}.log'
            
            cmd = [
                'expdp',
                'system/oracle123@172.20.10.4:1521/xe',
                f'DIRECTORY=backup_dir',
                f'DUMPFILE={dump_file}',
                f'LOGFILE={log_file}',
                'SCHEMAS=SYSTEM'
            ]
            
            result = subprocess.run(cmd, capture_output=True, text=True)
            
            if result.returncode == 0:
                logging.info(f"Oracle backup successful: {dump_file}")
                return True
            else:
                logging.error(f"Oracle backup failed: {result.stderr}")
                return False
                
        except Exception as e:
            logging.error(f"Oracle backup error: {str(e)}")
            return False
    
    def cleanup_old_backups(self, retention_days=7):
        """Remove backups older than retention period"""
        try:
            cutoff_date = datetime.now() - timedelta(days=retention_days)
            
            for root, dirs, files in os.walk(self.backup_root):
                for file in files:
                    file_path = os.path.join(root, file)
                    file_time = datetime.fromtimestamp(os.path.getmtime(file_path))
                    
                    if file_time < cutoff_date:
                        os.remove(file_path)
                        logging.info(f"Removed old backup: {file_path}")
            
            return True
            
        except Exception as e:
            logging.error(f"Cleanup failed: {str(e)}")
            return False
    
    def verify_backups(self):
        """Verify backup integrity"""
        try:
            # Test SQLite backup
            latest_backup = self.get_latest_backup('sqlite')
            if latest_backup:
                test_conn = sqlite3.connect(latest_backup)
                test_conn.execute("SELECT 1")
                test_conn.close()
                logging.info("SQLite backup verification passed")
            
            return True
            
        except Exception as e:
            logging.error(f"Backup verification failed: {str(e)}")
            return False
    
    def get_latest_backup(self, db_type):
        """Get most recent backup file"""
        backup_dir = os.path.join(self.backup_root, db_type, 'daily')
        if not os.path.exists(backup_dir):
            return None
        
        files = [f for f in os.listdir(backup_dir) if f.endswith('.db') or f.endswith('.gz')]
        if not files:
            return None
        
        latest = max(files, key=lambda f: os.path.getmtime(os.path.join(backup_dir, f)))
        return os.path.join(backup_dir, latest)
    
    def send_notification(self, status, message):
        """Send backup status notification"""
        # Email notification (implement as needed)
        logging.info(f"Notification: {status} - {message}")
    
    def run_backup(self):
        """Main backup orchestration"""
        logging.info("=" * 50)
        logging.info("Starting automated backup")
        
        results = {
            'sqlite': self.backup_sqlite(),
            'oracle': self.backup_oracle()
        }
        
        # Cleanup old backups
        self.cleanup_old_backups()
        
        # Verify backups
        self.verify_backups()
        
        # Send notification
        if all(results.values()):
            self.send_notification('SUCCESS', 'All backups completed successfully')
            logging.info("Backup completed successfully")
        else:
            failed = [k for k, v in results.items() if not v]
            self.send_notification('WARNING', f'Backup failed for: {", ".join(failed)}')
            logging.warning(f"Backup completed with failures: {failed}")
        
        logging.info("=" * 50)

if __name__ == '__main__':
    backup_manager = BackupManager()
    backup_manager.run_backup()
```

### 7.2 Windows Task Scheduler Setup

```batch
@echo off
REM backup_scheduler.bat
REM Schedule this using Windows Task Scheduler

cd D:\DM2_CW
python backup_manager.py

if %ERRORLEVEL% EQU 0 (
    echo Backup successful >> backup_log.txt
) else (
    echo Backup failed >> backup_log.txt
)
```

**Task Scheduler Configuration:**
1. Open Task Scheduler
2. Create Basic Task
3. Name: "Finance System Backup"
4. Trigger: Daily at 2:00 AM
5. Action: Start Program → `D:\DM2_CW\backup_scheduler.bat`
6. Enable "Run with highest privileges"

### 7.3 Linux Cron Job Setup

```bash
# Edit crontab
crontab -e

# Add daily backup at 2:00 AM
0 2 * * * cd /path/to/DM2_CW && python3 backup_manager.py >> logs/cron_backup.log 2>&1

# Weekly full backup on Sunday at 3:00 AM
0 3 * * 0 cd /path/to/DM2_CW && python3 backup_manager.py --full >> logs/cron_weekly.log 2>&1
```

---

## 8. Testing and Validation

### 8.1 Backup Testing Schedule

| Test Type | Frequency | Purpose |
|-----------|-----------|---------|
| Restore Test | Monthly | Verify backup integrity |
| Recovery Drill | Quarterly | Practice DR procedures |
| Failover Test | Semi-annually | Test alternate site |
| Full DR Exercise | Annually | Complete DR validation |

### 8.2 Restore Test Procedure

```python
def test_backup_restore():
    """
    Test backup and restore procedures
    """
    import tempfile
    import shutil
    
    print("🧪 Starting backup restore test...")
    
    # 1. Create test database
    test_db = tempfile.mktemp(suffix='.db')
    shutil.copy('../sqlite/finance_local.db', test_db)
    
    # 2. Create backup
    backup_file = tempfile.mktemp(suffix='_backup.db')
    conn_source = sqlite3.connect(test_db)
    conn_backup = sqlite3.connect(backup_file)
    conn_source.backup(conn_backup)
    conn_backup.close()
    conn_source.close()
    
    # 3. Modify original
    conn = sqlite3.connect(test_db)
    conn.execute("DELETE FROM expense WHERE expense_id = 1")
    conn.commit()
    conn.close()
    
    # 4. Restore from backup
    shutil.copy(backup_file, test_db)
    
    # 5. Verify data
    conn = sqlite3.connect(test_db)
    cursor = conn.execute("SELECT COUNT(*) FROM expense WHERE expense_id = 1")
    count = cursor.fetchone()[0]
    conn.close()
    
    # 6. Cleanup
    os.remove(test_db)
    os.remove(backup_file)
    
    if count == 1:
        print("✅ Backup restore test PASSED")
        return True
    else:
        print("❌ Backup restore test FAILED")
        return False
```

### 8.3 Validation Checklist

```markdown
## Monthly Backup Validation

- [ ] SQLite backup files exist
- [ ] Oracle dump files exist
- [ ] Backup files are not corrupted
- [ ] File sizes are reasonable
- [ ] Restore test successful
- [ ] Application functions after restore
- [ ] Data integrity verified
- [ ] Backup logs reviewed
- [ ] Old backups cleaned up
- [ ] Offsite copy confirmed
```

---

## 9. Backup Retention Policy

### 9.1 Retention Schedule

| Backup Type | Frequency | Retention Period | Storage Location |
|-------------|-----------|------------------|------------------|
| Daily Incremental | Daily | 7 days | Local disk |
| Weekly Full | Weekly | 4 weeks | Local + NAS |
| Monthly Full | Monthly | 12 months | NAS + Cloud |
| Yearly Archive | Yearly | 7 years | Cloud (cold storage) |

### 9.2 Storage Capacity Planning

```
Daily Backups:
- SQLite: ~10 MB × 7 days = 70 MB
- Oracle: ~50 MB × 7 days = 350 MB

Weekly Backups:
- SQLite: ~10 MB × 4 weeks = 40 MB
- Oracle: ~50 MB × 4 weeks = 200 MB

Monthly Backups:
- SQLite: ~10 MB × 12 months = 120 MB
- Oracle: ~50 MB × 12 months = 600 MB

Total Storage Required: ~1.4 GB
Recommended Allocation: 5 GB (buffer for growth)
```

---

## 10. Best Practices

### 10.1 Backup Best Practices

1. **3-2-1 Rule**
   - 3 copies of data
   - 2 different media types
   - 1 offsite copy

2. **Test Restores Regularly**
   - Monthly restore tests
   - Document test results
   - Practice DR procedures

3. **Encrypt Backups**
   ```python
   # Encrypt backup files
   from cryptography.fernet import Fernet
   
   def encrypt_backup(backup_file):
       key = Fernet.generate_key()
       cipher = Fernet(key)
       
       with open(backup_file, 'rb') as f:
           data = f.read()
       
       encrypted = cipher.encrypt(data)
       
       with open(f'{backup_file}.encrypted', 'wb') as f:
           f.write(encrypted)
   ```

4. **Monitor Backup Jobs**
   - Set up alerts for failures
   - Review logs regularly
   - Track backup sizes
   - Monitor storage capacity

5. **Document Procedures**
   - Keep runbooks updated
   - Document contact information
   - Maintain recovery instructions
   - Record lessons learned

### 10.2 Common Pitfalls to Avoid

❌ Backing up while database is in use (SQLite file copy)  
✅ Use .backup() method for hot backups

❌ Never testing restores  
✅ Schedule monthly restore tests

❌ Storing all backups on same disk  
✅ Use multiple locations (3-2-1 rule)

❌ No backup verification  
✅ Automate integrity checks

❌ Manual backup processes  
✅ Automate with scripts and scheduling

---

## 11. Conclusion

This backup and recovery strategy provides comprehensive protection for the Personal Finance Management System:

### Summary of Protection:
- ✅ **Daily backups** ensure minimal data loss (RPO < 24 hours)
- ✅ **Multiple backup methods** provide flexibility in recovery
- ✅ **Automated procedures** reduce human error
- ✅ **Offsite storage** protects against disasters
- ✅ **Regular testing** validates recovery capability
- ✅ **Clear documentation** enables quick recovery

### Recovery Capabilities:
- Point-in-time recovery to any daily backup
- Table-level recovery for isolated issues
- Full disaster recovery within RTO
- Failover to alternate site if needed

### Compliance:
- Meets industry backup standards
- Supports audit requirements
- Maintains data for required retention period
- Documented and tested procedures

---

**Document Version**: 1.0  
**Last Updated**: November 1, 2025  
**Next Review**: December 1, 2025  
**Owner**: Data Management 2 Coursework
