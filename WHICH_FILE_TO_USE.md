# 📋 Quick Reference - Which File Do I Use?

**Personal Finance Management System**

---

## 🎯 I Just Want to Run the App!

**👉 Double-click:** `SETUP.bat`

This does EVERYTHING:
- ✅ Checks Python
- ✅ Installs dependencies
- ✅ Verifies database
- ✅ Launches app
- ✅ Gives you options

**Super easy!** ✨

---

## 📚 Different Files, Different Purposes

### 🚀 Setup & Launch

| File | What It Does | When to Use |
|------|-------------|-------------|
| **SETUP.bat** | Complete setup + launch | **First time** or anytime you want to run the app |
| **install_dependencies.bat** | Just installs Python packages | If you only need to install/update packages |
| **webapp/start.bat** | Quick start (no checks) | If everything is already set up |
| **webapp/run.bat** | Full start with checks | Alternative launcher with more checks |

**Recommended:** Just use `SETUP.bat` - it's smart and does everything! 🧠

---

### 📖 Documentation

| File/Folder | What's Inside | When to Read |
|------------|--------------|-------------|
| **COMPLETE_SETUP_GUIDE.md** | Step-by-step setup for beginners | Having trouble? Start here! |
| **README.md** | Project overview | Quick intro to the project |
| **docs/guides/** | All setup guides | Need detailed instructions |
| **docs/checklists/** | Testing checklists | Before submission |
| **docs/analysis/** | Requirements analysis | See what's completed |

---

### 🗄️ Database Files

| Location | What's There | Don't Touch Unless... |
|----------|-------------|---------------------|
| **sqlite/finance_local.db** | Your local database (367 expenses!) | You know what you're doing |
| **sqlite/*.sql** | SQL scripts to create database | Database is corrupted |
| **oracle/*.sql** | Oracle database scripts | Setting up Oracle |

---

### 🐍 Python Scripts

| File | What It Does | How to Run |
|------|-------------|-----------|
| **webapp/app.py** | Main Flask application | `python app.py` (from webapp folder) |
| **webapp/populate_sample_data.py** | Adds sample data | `python populate_sample_data.py` |
| **test_sync_extended.py** | Syncs to Oracle | `python test_sync_extended.py` |
| **verify_database.py** | Checks database | `python verify_database.py` |

---

## 🎓 For Different User Types

### 👶 Complete Beginner (Never Used Python)
**Read this:**
1. `COMPLETE_SETUP_GUIDE.md` - Start here!
2. `README.md` - Quick overview

**Run this:**
1. Install Python (guide shows how)
2. Double-click `SETUP.bat`
3. Choose option 2 (sample data)
4. Explore!

---

### 🧑‍💻 Developer (Reviewing Code)
**Read this:**
1. `README.md` - Overview
2. `docs/analysis/REQUIREMENTS_COMPLETION_ANALYSIS.md` - What's done
3. `docs/guides/REPORT_GENERATION_GUIDE.md` - How reports work

**Check this:**
1. `webapp/app.py` - Flask backend
2. `oracle/03_reports_package.sql` - PL/SQL reports
3. `synchronization/sync_manager.py` - Sync logic

---

### 🧪 Tester (Testing the App)
**Read this:**
1. `docs/checklists/FULL_TESTING_CHECKLIST.md` - Complete testing guide

**Run this:**
1. `SETUP.bat` → Option 2 (sample data)
2. Test everything in checklist
3. Report bugs!

---

### 📊 Grader/Evaluator (Checking for Coursework)
**Read this:**
1. `FINAL_PROJECT_REPORT.md` - Main deliverable
2. `docs/analysis/REQUIREMENTS_COMPLETION_ANALYSIS.md` - Completion status
3. `cw.md` - Original requirements

**Check this:**
- SQLite database: 9 tables, 367 transactions
- Oracle database: PL/SQL packages (1,400+ lines)
- Web app: http://127.0.0.1:5000
- Documentation: 50,000+ words

---

## 🆘 Common Questions

### "Which file do I click first?"
**Answer:** `SETUP.bat` - It's the master script!

### "I only want to install packages, not run anything"
**Answer:** `install_dependencies.bat`

### "How do I start the app after setup?"
**Answer:** `SETUP.bat` again, or `cd webapp && python app.py`

### "Where's the documentation?"
**Answer:** `docs/` folder - everything organized!

### "I broke something, how do I reset?"
**Answer:** Delete `sqlite/finance_local.db` and run `SETUP.bat` → Option 2

### "How do I stop the app?"
**Answer:** Press `Ctrl + C` in the black window

---

## 🗂️ Folder Organization

```
DM2_CW/
│
├── 🚀 SETUP.bat              ← START HERE!
├── 📦 install_dependencies.bat
│
├── 📖 COMPLETE_SETUP_GUIDE.md  ← Help for beginners
├── 📋 README.md
├── 📄 THIS_FILE.md
│
├── 📂 docs/
│   ├── checklists/         ← Testing guides
│   ├── guides/             ← How-to guides  
│   ├── analysis/           ← What's completed
│   ├── summaries/          ← Status reports
│   └── troubleshooting/    ← Fix issues
│
├── 📂 webapp/              ← Flask web app
│   ├── start.bat           ← Quick start
│   └── app.py              ← Main app
│
├── 📂 sqlite/              ← Local database
├── 📂 oracle/              ← Oracle scripts
└── 📂 synchronization/     ← Sync module
```

---

## ⚡ Ultra Quick Cheat Sheet

```bash
# First time setup
SETUP.bat → Choose 2 (sample data)

# Run app later
SETUP.bat → Choose 1 (start app)

# Just install packages
install_dependencies.bat

# Manual start
cd webapp
python app.py

# Sync to Oracle
python test_sync_extended.py

# Verify database
python verify_database.py
```

---

## 🎯 TL;DR

**Just use `SETUP.bat` for everything!** 🚀

It's smart enough to:
- Check what you have
- Install what you need
- Fix what's broken
- Launch what works

**One script to rule them all!** 💍

---

**Still confused?** Read `COMPLETE_SETUP_GUIDE.md` - it explains EVERYTHING! 📖

---

**Last Updated:** November 2, 2025
