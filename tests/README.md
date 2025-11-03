# Test Scripts

This folder contains all test and verification scripts for the Personal Finance Manager.

## Files

### test_sync.py
Quick synchronization test for all users.

**Usage:**
```bash
cd D:\DM2_CW\tests
python test_sync.py
```

**Purpose:**
- Tests SQLite to Oracle synchronization
- Syncs first user automatically
- Verifies sync functionality

### test_sync_extended.py
Extended synchronization test with longer timeout.

**Usage:**
```bash
cd D:\DM2_CW\tests
python test_sync_extended.py
```

**Purpose:**
- Tests sync with extended Oracle connection timeout
- Useful for slower network connections
- More detailed logging

### verify_database.py
Database verification and reporting script.

**Usage:**
```bash
cd D:\DM2_CW\tests
python verify_database.py
```

**Purpose:**
- Checks all tables exist
- Verifies data counts
- Lists all users
- Reports database statistics

## Requirements
- All scripts use relative paths
- Python 3.x required
- Dependencies from parent requirements.txt

## Notes
All test scripts now use relative paths and can be run from any location.
