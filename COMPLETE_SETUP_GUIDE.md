# 🚀 Complete Setup Guide for Non-Technical Users

**Personal Finance Management System**  
**For Windows Users**

---

## 📝 What You Need

This guide will help you set up EVERYTHING from scratch, even if you have NOTHING installed.

**Time Required:** 30-45 minutes  
**Difficulty:** Easy (just follow the steps!)

---

## ⚡ SUPER QUICK SETUP (For the Lazy 😅)

If you already have Python installed:

1. **Download the project**
2. **Double-click `SETUP.bat`**
3. **Done!** 🎉

The script does everything automatically.

---

## 📋 COMPLETE STEP-BY-STEP GUIDE

Follow these steps if you're starting from zero:

---

### STEP 1: Install VS Code (Optional but Recommended)

**What is it?** A code editor to view and edit files.

1. **Download VS Code:**
   - Go to: https://code.visualstudio.com/
   - Click the big "Download for Windows" button
   - File will be something like: `VSCodeUserSetup-x64-1.XX.X.exe`

2. **Install VS Code:**
   - Double-click the downloaded file
   - Accept the license agreement
   - ✅ **CHECK** "Add to PATH" (important!)
   - ✅ **CHECK** "Create desktop icon" (optional)
   - Click "Next" and "Install"
   - Wait for installation to complete
   - Click "Finish"

**Time:** 5 minutes

---

### STEP 2: Install Python

**What is it?** The programming language that runs the app.

1. **Download Python:**
   - Go to: https://www.python.org/downloads/
   - Click "Download Python 3.XX.X" (latest version)
   - File will be: `python-3.XX.X-amd64.exe`

2. **Install Python:**
   - Double-click the downloaded file
   - ⚠️ **IMPORTANT:** CHECK "Add Python to PATH" (at the bottom!)
   - Click "Install Now"
   - Wait for installation (2-3 minutes)
   - Click "Close"

3. **Verify Python is installed:**
   - Press `Win + R`
   - Type: `cmd`
   - Press Enter (black window opens)
   - Type: `python --version`
   - Press Enter
   - Should show: `Python 3.XX.X`

**Time:** 5-10 minutes

---

### STEP 3: Download the Project

**Option A: If you have Git installed**
```bash
git clone https://github.com/LakinduQA/DM2_CW.git
cd DM2_CW
```

**Option B: If you DON'T have Git (easier)**
1. Go to: https://github.com/LakinduQA/DM2_CW
2. Click the green "Code" button
3. Click "Download ZIP"
4. Extract the ZIP file to a folder (e.g., `D:\DM2_CW`)

**Time:** 2-5 minutes

---

### STEP 4: Run the Setup Script (AUTOMATIC!)

This is where the magic happens! One script does EVERYTHING.

1. **Open the project folder:**
   - Navigate to where you extracted/cloned the project
   - Example: `D:\DM2_CW`

2. **Run the setup script:**
   - Find the file: `SETUP.bat`
   - Double-click it
   - A black window will open

3. **What the script does:**
   - ✅ Checks if Python is installed
   - ✅ Installs Flask (web framework)
   - ✅ Installs cx_Oracle (database connector)
   - ✅ Verifies project structure
   - ✅ Tests database connection
   - ✅ Gives you options to launch the app

4. **Choose what to do:**
   ```
   1. Start Web Application          ← Choose this to run the app
   2. Populate Sample Data           ← Choose this first if database is empty
   3. Sync to Oracle Database        ← Choose this after adding data
   4. Exit
   ```

5. **First time? Choose option 2 first:**
   - This adds sample data (367 expenses, 8 income, 8 budgets, 5 goals)
   - Then it automatically launches the app

**Time:** 5-10 minutes

---

### STEP 5: Use the App!

1. **After setup, browser opens automatically:**
   - URL: http://127.0.0.1:5000

2. **Login:**
   - Username: `john_doe` or `jane_smith`
   - No password needed (it's a demo!)

3. **Explore:**
   - 📊 Dashboard - See your financial overview
   - 💰 Expenses - View and add expenses
   - 💵 Income - Track your income
   - 🎯 Budgets - Set and monitor budgets
   - 🏆 Goals - Create savings goals
   - 📈 Reports - View charts and analytics

4. **Stop the app:**
   - Go back to the black window
   - Press `Ctrl + C`
   - Type `Y` and press Enter

**Time:** As long as you want!

---

## 🔧 MANUAL SETUP (If Script Doesn't Work)

If the automatic script fails, do this:

### Step 1: Open PowerShell/Command Prompt
- Press `Win + R`
- Type: `cmd`
- Press Enter

### Step 2: Navigate to Project Folder
```bash
cd D:\DM2_CW
# (or wherever you extracted the project)
```

### Step 3: Install Dependencies
```bash
pip install Flask
pip install cx_Oracle
```

### Step 4: Populate Sample Data (Optional)
```bash
cd webapp
python populate_sample_data.py
cd ..
```

### Step 5: Start the App
```bash
cd webapp
python app.py
```

### Step 6: Open Browser
- Go to: http://127.0.0.1:5000

---

## 🎯 WHAT IF SOMETHING BREAKS?

### Problem 1: "Python is not recognized"
**Solution:**
- Python is not in PATH
- Reinstall Python and CHECK "Add Python to PATH"
- OR add Python manually to PATH:
  1. Search "Environment Variables" in Windows
  2. Click "Environment Variables"
  3. Under "System Variables", find "Path"
  4. Click "Edit"
  5. Click "New"
  6. Add: `C:\Users\YourUsername\AppData\Local\Programs\Python\Python3XX`
  7. Click OK everywhere
  8. Restart Command Prompt

---

### Problem 2: "Flask not found" or "No module named flask"
**Solution:**
```bash
pip install Flask --upgrade
```

---

### Problem 3: "Port 5000 is already in use"
**Solution:**
- Another app is using port 5000
- Option A: Close other apps using port 5000
- Option B: Change the port in `webapp/app.py`:
  ```python
  # Line 625 (bottom of file)
  app.run(debug=True, port=5001)  # Change 5000 to 5001
  ```

---

### Problem 4: "Database not found"
**Solution:**
```bash
cd sqlite
python create_db.py
cd ..
```

---

### Problem 5: "Nothing happens when I run SETUP.bat"
**Solution:**
- Right-click `SETUP.bat`
- Click "Run as administrator"
- If still doesn't work, follow Manual Setup above

---

## 📸 Screenshots (What You Should See)

### 1. After Running SETUP.bat:
```
========================================
  Personal Finance Management System
  Complete Setup Script
========================================

[STEP 1/6] Checking Python installation...
Python 3.11.0
Python is installed!

[STEP 2/6] Upgrading pip...
pip upgraded successfully!

[STEP 3/6] Installing required packages...
Installing Flask...
Installing cx_Oracle...
All packages installed successfully!

[STEP 4/6] Verifying project structure...
SQLite database found!
Flask app found!
Oracle config found!

[STEP 5/6] Testing database connection...
Database connection successful!

[STEP 6/6] Setup complete!

========================================
  Launch Options
========================================

1. Start Web Application
2. Populate Sample Data
3. Sync to Oracle Database
4. Exit

Enter your choice (1-4):
```

### 2. After Choosing Option 1 (Launch App):
```
========================================
  Starting Flask Application...
========================================

 * Serving Flask app 'app'
 * Debug mode: on
WARNING: This is a development server.
 * Running on http://127.0.0.1:5000
Press CTRL+C to quit
```

### 3. In Your Browser:
- You should see a login page
- Clean design with Bootstrap
- Login form with username field

---

## 🎓 FOR YOUR FRIENDS (THE NON-TECHNICAL ONES)

Send them this message:

---

**Hey! Here's how to run my project:**

1. **Install Python** (if you don't have it):
   - Go to: https://www.python.org/downloads/
   - Download and install
   - ⚠️ **CHECK "Add Python to PATH"** during installation!

2. **Download the project:**
   - Download ZIP from GitHub
   - Extract to a folder (e.g., Desktop)

3. **Run it:**
   - Open the folder
   - Double-click `SETUP.bat`
   - Choose option 2 (to load sample data)
   - Browser will open automatically

4. **Login:**
   - Username: `john_doe`
   - Explore the app!

5. **Stop it:**
   - Press `Ctrl + C` in the black window

**That's it! 🎉**

If something breaks, check `COMPLETE_SETUP_GUIDE.md` for troubleshooting.

---

## 📦 WHAT THE SETUP.BAT SCRIPT DOES

For the curious, here's what happens behind the scenes:

```bash
# 1. Check if Python is installed
python --version

# 2. Upgrade pip (package manager)
python -m pip install --upgrade pip

# 3. Install Flask (web framework)
pip install Flask

# 4. Install cx_Oracle (Oracle database connector)
pip install cx_Oracle

# 5. Verify project structure
# - Checks if sqlite/finance_local.db exists
# - Checks if webapp/app.py exists
# - Checks if synchronization/config.ini exists

# 6. Test database connection
python verify_database.py

# 7. Launch options
# - Option 1: Start web app
# - Option 2: Populate sample data
# - Option 3: Sync to Oracle
```

All of this is automated! Just double-click and go! ☕

---

## 🚀 ADVANCED: Manual Commands

If you prefer doing things manually (for learning):

### Install Dependencies Only:
```bash
pip install Flask cx_Oracle
```

### Populate Sample Data:
```bash
cd webapp
python populate_sample_data.py
```

### Start Web App:
```bash
cd webapp
python app.py
```

### Sync to Oracle:
```bash
python test_sync_extended.py
```

### Verify Database:
```bash
python verify_database.py
```

---

## 📁 PROJECT STRUCTURE

After setup, you'll have:

```
DM2_CW/
├── SETUP.bat                 ← DOUBLE-CLICK THIS TO START!
├── README.md                 ← Overview
├── COMPLETE_SETUP_GUIDE.md   ← This file
│
├── sqlite/
│   └── finance_local.db      ← Local database (367 expenses, 8 income, etc.)
│
├── webapp/
│   ├── app.py                ← Main Flask application
│   ├── templates/            ← HTML pages
│   ├── static/               ← CSS, JavaScript
│   └── populate_sample_data.py  ← Adds sample data
│
├── oracle/
│   ├── 01_create_database.sql   ← Oracle setup
│   ├── 02_plsql_crud_package.sql
│   └── 03_reports_package.sql
│
├── synchronization/
│   ├── sync_manager.py       ← Sync SQLite ↔ Oracle
│   └── config.ini            ← Oracle connection settings
│
└── docs/
    ├── checklists/           ← Testing checklists
    ├── guides/               ← Setup and usage guides
    ├── analysis/             ← Requirements analysis
    └── summaries/            ← Status reports
```

---

## ✅ CHECKLIST

Before running the app, make sure you have:

- [ ] Windows 10/11 (64-bit)
- [ ] Python 3.8+ installed
- [ ] Python added to PATH
- [ ] Internet connection (for downloading packages)
- [ ] At least 500 MB free disk space
- [ ] Admin rights (if installing software)

---

## 🎉 YOU'RE DONE!

You now have:
- ✅ Python installed
- ✅ All dependencies installed
- ✅ Project structure verified
- ✅ Sample data loaded
- ✅ Web app running

**Next Steps:**
1. Explore the app (http://127.0.0.1:5000)
2. Add your own expenses
3. Create budgets
4. Set savings goals
5. View reports

**Have fun! 🚀**

---

## 📞 NEED HELP?

Check these files:
- `README.md` - Quick overview
- `docs/guides/` - Detailed guides
- `docs/troubleshooting/` - Common issues and fixes
- `docs/checklists/FULL_TESTING_CHECKLIST.md` - Testing guide

Or contact the developer! 😊

---

**Last Updated:** November 2, 2025  
**Made with ❤️ for non-technical friends**
