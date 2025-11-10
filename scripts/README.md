# Utility Scripts

This folder contains utility scripts for database population and maintenance.

## Subfolders

### utilities/
Contains one-time migration scripts and diagnostic utilities. See `utilities/README.md` for details.

## Files

### populate_sample_data.py
Populates the SQLite database with realistic Sri Lankan test data.

**Usage:**
```bash
cd D:\DM2_CW\scripts
python populate_sample_data.py
```

**Creates:**
- 5 Sri Lankan users (password: fs123)
- 90 days of expense transactions
- Income records
- Budget plans
- Savings goals with contributions

### populate_sample_data_backup.py
Backup of the original populate script (for reference only).

## Requirements
- Python 3.x
- werkzeug (for password hashing)
- sqlite3 (built-in)

## Database Location
Scripts connect to: `../sqlite/finance_local.db` (relative path)
