# Project Organization Overview

Last Updated: November 4, 2025

## 📁 Folder Structure

### Root Level Files
```
start_app.bat          - Launch Flask application
stop_app.bat           - Stop Flask application  
restart_app.bat        - Restart Flask application
install_dependencies.bat - Install Python packages
organize_docs.bat      - Organize documentation
README.md              - Main project documentation
requirements.txt       - Global Python dependencies
```

### `/webapp` - Web Application
**Purpose:** Flask web application and UI

**Key Files:**
- `app.py` - Main Flask application (800+ lines)
- `templates/` - HTML templates (8 files)
- `static/` - CSS, JavaScript, images
- `requirements.txt` - Web app dependencies

**Run From:** Root directory using `start_app.bat`

---

### `/sqlite` - Local Database
**Purpose:** SQLite database and schema scripts

**Key Files:**
- `finance_local.db` - SQLite database file
- `01_create_database.sql` - Schema creation (500+ lines)
- `02_crud_operations.sql` - SQL operations

**Access:** Use DB Browser for SQLite

---

### `/oracle` - Cloud Database Scripts
**Purpose:** Oracle database SQL scripts

**Key Files:**
- `01_create_database.sql` - Schema creation
- `02_plsql_crud_package.sql` - CRUD operations (1,400 lines)
- `03_reports_package.sql` - Financial reports (718 lines)
- `04_fix_*.sql` - Maintenance scripts

**Run:** Execute in Oracle SQL Developer

---

### `/synchronization` - Sync Module
**Purpose:** SQLite ↔ Oracle synchronization

**Key Files:**
- `sync_manager.py` - Main sync logic (600+ lines)
- `config.ini` - Database connection settings
- `requirements.txt` - Sync dependencies

**Usage:** Auto-runs from webapp, or run tests from `/tests`

---

### `/scripts` - Utility Scripts
**Purpose:** Database population and maintenance

**Key Files:**
- `populate_sample_data.py` - Create 5 test users with 90 days of data
- `README.md` - Script documentation

**Run:**
```bash
cd scripts
python populate_sample_data.py
```

---

### `/tests` - Test Scripts
**Purpose:** Testing and verification

**Key Files:**
- `test_sync.py` - Quick sync test
- `test_sync_extended.py` - Extended sync test with timeout
- `verify_database.py` - Database verification report
- `README.md` - Test documentation

**Run:**
```bash
cd tests
python test_sync.py
```

**Note:** All tests use relative paths and can run from any location

---

### `/logs` - Log Files
**Purpose:** Application and sync logs

**Files:**
- `sync_log.txt` - Main synchronization log
- `sync_log_webapp.txt` - Webapp sync log

**Maintenance:** Can be cleared periodically

---

### `/archived` - Deprecated Files
**Purpose:** Historical reference only

**Contents:**
- Old scripts (convert_to_lkr.py, set_passwords.py)
- Deprecated SQL files (test_users.sql)
- Backup files (populate_sample_data_backup.py)
- Temporary files (user1_hash.txt)

**Safe to delete:** Yes, but kept for coursework review

---

### `/docs` - Documentation
**Purpose:** All project documentation organized by category

#### `/docs/setup`
- Complete setup guides
- Installation instructions

#### `/docs/user-guide`
- Quickstart guide
- User manual

#### `/docs/development`
- Developer documentation
- Coursework requirements (cw.md)
- File reference guide

#### `/docs/checklists`
- Testing checklists
- Submission checklists

#### `/docs/guides`
- Oracle setup
- Report generation
- UI design overview
- Demonstration guide

#### `/docs/analysis`
- Requirements analysis
- Project analysis

#### `/docs/summaries`
- Status reports
- Project summaries

#### `/docs/troubleshooting`
- Common issues
- Fixes applied

---

### `/database_designs` - Design Documents
**Purpose:** Database design documentation

**Files:**
- `requirements.md` - Requirements analysis
- `logical_design.md` - ER diagrams
- `physical_design_sqlite.md` - SQLite design
- `physical_design_oracle.md` - Oracle design

---

### `/backups` - Database Backups
**Purpose:** SQLite database backups

**Created by:** Manual backups or backup scripts

---

### `/reports` - Generated Reports
**Purpose:** PDF/HTML reports generated from Oracle

**Created by:** Report generation scripts

---

## 🎯 Where to Find Things

### I want to...

**Start the application**
→ Double-click `start_app.bat` in root

**Create test data**
→ Run `scripts/populate_sample_data.py`

**Test synchronization**
→ Run `tests/test_sync.py`

**View the database**
→ Open `sqlite/finance_local.db` with DB Browser

**Check database structure**
→ See `sqlite/01_create_database.sql`

**Run Oracle reports**
→ Execute scripts in `oracle/03_reports_package.sql`

**Read setup instructions**
→ See `docs/setup/COMPLETE_SETUP_GUIDE.md`

**Troubleshoot issues**
→ Check `docs/troubleshooting/`

**Review requirements**
→ See `docs/development/cw.md`

---

## 🔄 Recent Changes (Nov 4, 2025)

### Reorganization
✅ Created new folders: `/tests`, `/logs`, `/scripts`, `/archived`  
✅ Moved test scripts to `/tests`  
✅ Moved log files to `/logs`  
✅ Moved utilities to `/scripts`  
✅ Archived old files to `/archived`  
✅ Organized documentation in `/docs` subfolders  
✅ Updated all file paths to use relative references  
✅ Added README.md to each folder explaining contents  

### Path Updates
✅ `test_sync.py` - Now uses relative paths  
✅ `test_sync_extended.py` - Now uses relative paths  
✅ `verify_database.py` - Now uses relative paths  
✅ `populate_sample_data.py` - Already had relative paths  

### Benefits
- ✅ Cleaner root directory
- ✅ Easier to navigate
- ✅ Professional structure
- ✅ Better maintainability
- ✅ Industry standard organization

---

## 📝 Notes

1. **All scripts now use relative paths** - Can be run from any directory
2. **Archived files are safe to delete** - Kept for reference during coursework review
3. **Each folder has a README.md** - Explains contents and usage
4. **No breaking changes** - Application still works exactly the same
5. **Version control friendly** - Clean .gitignore structure

---

## 🚀 Quick Commands

```powershell
# Start application
start_app.bat

# Populate test data
cd scripts
python populate_sample_data.py

# Test sync
cd tests
python test_sync.py

# Verify database
cd tests
python verify_database.py

# View logs
notepad logs\sync_log.txt
```

---

**For more details on any folder, see the README.md inside that folder.**
