# Scripts

This folder contains utility scripts and automation tools for Spendly.

## Subfolders

### batch/

Windows batch scripts for application management:
- `setup.bat` - Complete setup wizard
- `start.bat` - Start the application
- `stop.bat` - Stop the application
- `restart.bat` - Restart the application
- `install.bat` - Quick dependency installation

See [batch/README.md](batch/README.md) for details.

### utilities/

One-time migration scripts and diagnostic utilities.

## Files

### populate_sample_data.py

Populates the SQLite database with sample test data.

**Usage:**

```bash
cd scripts
python populate_sample_data.py
```

**Creates:**

- 5 sample users with Sri Lankan names
- 90 days of expense transactions
- Income records
- Budget plans
- Savings goals with contributions

**Demo Login:** `dilini.fernando` / `Password123!`

## Requirements

- Python 3.x
- werkzeug (for password hashing)
- sqlite3 (built-in)

## Database Location

Scripts connect to: `../sqlite/finance_local.db`
