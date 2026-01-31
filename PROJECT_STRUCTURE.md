# Project Structure

An overview of the Spendly project organization.

## 📁 Folder Structure

```
spendly-finance_tracker/
├── webapp/                 # Flask web application
├── sqlite/                 # SQLite database & SQL scripts
├── oracle/                 # Oracle PL/SQL scripts
├── synchronization/        # Database sync module
├── scripts/                # Utility & batch scripts
├── tests/                  # Test scripts
├── database_designs/       # Design documentation
├── docs/                   # User & developer guides
├── backups/                # Database backups
├── reports/                # Generated reports
└── logs/                   # Application logs
```

---

## Folder Details

### `/webapp`
Flask web application with Bootstrap 5 UI.

**Key Files:**
- `app.py` - Main Flask application
- `templates/` - Jinja2 HTML templates
- `static/` - CSS, JavaScript, images

### `/sqlite`
SQLite database and schema scripts.

**Key Files:**
- `finance_local.db` - SQLite database
- `01_create_database.sql` - Schema creation
- `02_crud_operations.sql` - SQL operations

### `/oracle`
Oracle database scripts for advanced features.

**Key Files:**
- `01_create_database.sql` - Schema creation
- `02_plsql_crud_package.sql` - CRUD operations
- `03_reports_package.sql` - Financial reports

### `/synchronization`
SQLite ↔ Oracle bidirectional synchronization.

**Key Files:**
- `sync_manager.py` - Sync logic
- `config.example.ini` - Configuration template

### `/scripts`
Utility scripts and automation tools.

**Subfolders:**
- `batch/` - Windows batch scripts (setup, start, stop)
- `utilities/` - Migration and diagnostic tools

**Key Files:**
- `populate_sample_data.py` - Generate sample data

### `/tests`
Testing and verification scripts.

**Key Files:**
- `test_sync.py` - Synchronization test
- `verify_database.py` - Database verification

### `/database_designs`
Database design documentation.

**Files:**
- `01_requirements.md` - Requirements analysis
- `02_logical_design.md` - ER diagrams
- `03_physical_design_sqlite.md` - SQLite design
- `04_physical_design_oracle.md` - Oracle design

### `/docs`
Project documentation organized by category.

**Subfolders:**
- `setup/` - Installation guides
- `user-guide/` - Quick start guide
- `guides/` - Detailed how-to guides
- `troubleshooting/` - Common issues and fixes

---

## Quick Reference

| I want to... | Location |
|--------------|----------|
| Start the app | `scripts/batch/setup.bat` or `cd webapp && python app.py` |
| Add sample data | `python scripts/populate_sample_data.py` |
| View the database | Open `sqlite/finance_local.db` with DB Browser |
| Test sync | `python tests/test_sync.py` |
| Read setup guide | `docs/setup/COMPLETE_SETUP_GUIDE.md` |
| Troubleshoot | `docs/troubleshooting/` |

---

## Notes

- All scripts use relative paths
- Logs are stored in `/logs`
- Database backups go in `/backups`
- Generated reports go in `/reports`
