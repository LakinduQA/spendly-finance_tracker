# Test Scripts

This folder contains test and verification scripts for Spendly.

## Files

### test_sync.py

Quick synchronization test.

**Usage:**

```bash
cd tests
python test_sync.py
```

Tests SQLite to Oracle synchronization for the first user.

### test_sync_extended.py

Extended synchronization test with longer timeout.

**Usage:**

```bash
cd tests
python test_sync_extended.py
```

For slower network connections with detailed logging.

### verify_database.py

Database verification and reporting.

**Usage:**

```bash
cd tests
python verify_database.py
```

Checks tables, verifies data counts, and reports statistics.

## Requirements

- Python 3.x
- Dependencies from parent requirements.txt
- All scripts use relative paths
