# 💰 Personal Finance Management System - MVP

**Data Management 2 Coursework**  
**Status**: 🚧 **MVP Ready for Review**

---

## 🚀 QUICK START (For the Impatient!)

**Don't want to read? Just want to run it?**

1. **Install Python** (if you don't have it): https://www.python.org/downloads/
   - ⚠️ **CHECK "Add Python to PATH"** during installation!
2. **Download this project** (ZIP or clone)
3. **Double-click `SETUP.bat`** in the project folder
4. **Choose option 2** (Populate Sample Data)
5. **Browser opens** → Login as `john_doe` → Explore!

**That's it!** ✨

👉 **Having issues?** Read the [**Complete Setup Guide**](COMPLETE_SETUP_GUIDE.md) (for non-technical users)

---


**This is basically the first working version** - got all the core features done according to the coursework requirements (check `cw.md`), but I know it probably needs some polish and optimization. That's where you guys come in! 

Please clone this, run it on your machine, and **give me your honest feedback**. What works? What's broken? What can be improved? I'm totally open to suggestions and will refine this based on your reviews.

⚠️ **Fair warning**: I haven't done extensive testing yet, so there might be bugs I haven't caught. If something breaks, let me know!

---

## ✅ What I've Built So Far

Based on the coursework requirements in `cw.md`, here's what's done:

### 1. ✅ Dual Database Setup (SQLite + Oracle)
- **SQLite**: Local database for offline use
- **Oracle**: Central database for analytics
- Both databases have the same schema (9 tables each)
- Justification written in `database_designs/requirements.md`

### 2. ✅ Full Database Design
- Requirements analysis (functional + non-functional)
- ER diagrams and entity descriptions
- Physical designs for both databases
- Everything normalized to 3NF

### 3. ✅ SQLite Implementation
- 9 tables created (user, expense, income, budget, savings_goal, etc.)
- All constraints (PK, FK, NOT NULL, UNIQUE, CHECK)
- 28 indexes for performance
- 10 triggers for automation
- 5 views for reporting
- **367 sample expenses** already loaded for testing!

### 4. ✅ Oracle Implementation
- Same 9 tables with Oracle-specific features
- Sequences for auto-increment
- Advanced constraints (CHECK, DEFAULT)
- **1,400+ lines of PL/SQL CRUD package** (create, read, update, delete operations)
- **718 lines of PL/SQL Reports package** (5 financial reports)

### 5. ✅ Five Financial Reports (PL/SQL)
All using GROUP BY, HAVING, ORDER BY, CASE statements, and loops:
- Monthly expenditure analysis
- Budget adherence tracking
- Savings goal progress
- Category-wise expense distribution
- Forecasted savings trends

### 6. ✅ Synchronization Module
- Python script to sync SQLite ↔ Oracle
- Handles conflict resolution
- Bidirectional sync capability
- Already tested with 390 records!

### 7. ✅ Web Application
- Flask backend (617 lines)
- Bootstrap 5 UI (clean and responsive)
- 8 pages (login, register, dashboard, expenses, income, budgets, goals, reports)
- Chart.js for visualizations
- User authentication

### 8. ✅ Security Documentation
- 32,000 characters covering:
  - Password hashing (PBKDF2)
  - Database encryption
  - SQL injection prevention
  - GDPR compliance
  - Access control

### 9. ✅ Backup & Recovery Strategy
- 40,000 characters covering:
  - SQLite backup procedures
  - Oracle RMAN backup strategy
  - Disaster recovery plan
  - Automated backup scripts

### 10. ✅ Comprehensive Documentation
- 25-page final report (8,000+ words)
- 13 documentation files total
- 50,000+ words across all docs

---

## 🚀 How to Run This on Your Machine

### ⚡ SUPER QUICK (Recommended)

**Just 3 steps:**

1. **Install Python** (if needed): https://www.python.org/downloads/
   - ⚠️ Check "Add Python to PATH"!
2. **Download/Clone this project**
3. **Double-click `SETUP.bat`** → Choose option 2 → Done! ✨

### 📖 Need More Help?

Choose your path:

| I am... | Read this... |
|---------|-------------|
| 🆕 Complete beginner | [**COMPLETE_SETUP_GUIDE.md**](COMPLETE_SETUP_GUIDE.md) - Everything from zero |
| 🤔 Confused about files | [**WHICH_FILE_TO_USE.md**](WHICH_FILE_TO_USE.md) - Quick reference |
| 🐛 Having issues | [**docs/troubleshooting/**](docs/troubleshooting/) - Common fixes |
| 🧪 Want to test | [**docs/checklists/FULL_TESTING_CHECKLIST.md**](docs/checklists/FULL_TESTING_CHECKLIST.md) - Testing guide |
| 📊 Want to see reports | [**docs/guides/REPORT_GENERATION_GUIDE.md**](docs/guides/REPORT_GENERATION_GUIDE.md) - How reports work |

### 🛠️ Manual Setup (If You Prefer)

**Prerequisites:**
- Python 3.8+ installed
- Oracle Database (optional - for Oracle features)
- DB Browser for SQLite (optional - to view database)
- SQL Developer (optional - to run Oracle reports)

**Step 1: Clone the Repo**
```bash
git clone https://github.com/LakinduQA/DM2_CW.git
cd DM2_CW
```

**Step 2: Install Python Dependencies**
```bash
pip install -r requirements.txt
# OR manually:
pip install Flask cx_Oracle
```

**Step 3: Run the Web App**
```bash
cd webapp
python app.py
```

Then open your browser to: **http://127.0.0.1:5000**

### Step 4: Login / Register
- The app has sample users already: `john_doe` and `jane_smith`
- Or just register a new account (it saves to SQLite)
- **No password required** for now (simplified for testing)

### Step 5: Explore the App
- **Dashboard**: See your financial overview with charts
- **Expenses**: View/add your expenses (367 already there!)
- **Income**: Track your income
- **Budgets**: Set monthly budgets with progress bars
- **Goals**: Create savings goals
- **Reports**: View 5 financial reports

---

## 📂 Project Structure

```
DM2_CW/
│
├── 🚀 start_app.bat               ← DOUBLE-CLICK THIS TO START!
├── 📖 README.md                   ← This file
├──  requirements.txt            ← Python dependencies
│
├── 📂 webapp/                     ← Flask web application
│   ├── app.py                    (Main application)
│   ├── templates/                (HTML files)
│   ├── static/                   (CSS, JS, images)
│   └── requirements.txt
│
├── 📂 sqlite/                    ← SQLite database
│   ├── finance_local.db          ← THE DATABASE
│   ├── 01_create_database.sql
│   └── 02_crud_operations.sql
│
├── 📂 oracle/                    ← Oracle SQL scripts
│   ├── 01_create_database.sql
│   ├── 02_plsql_crud_package.sql  (1,400 lines)
│   ├── 03_reports_package.sql     (718 lines)
│   └── ...
│
├── 📂 synchronization/           ← Sync module
│   ├── sync_manager.py
│   ├── config.ini
│   └── requirements.txt
│
├── 📂 scripts/                   ← Utility scripts
│   ├── populate_sample_data.py   (Database population)
│   └── README.md
│
├── 📂 tests/                     ← Test scripts
│   ├── test_sync.py
│   ├── test_sync_extended.py
│   ├── verify_database.py
│   └── README.md
│
├── 📂 logs/                      ← Log files
│   └── sync_log.txt
│
├── 📂 archived/                  ← Old/deprecated files
│   └── (historical reference only)
│
├── 📂 docs/                      ← Documentation
│   ├── setup/                   ← Setup guides
│   │   └── COMPLETE_SETUP_GUIDE.md
│   ├── user-guide/              ← User documentation
│   │   └── QUICKSTART.md
│   ├── development/             ← Developer docs
│   │   ├── WHICH_FILE_TO_USE.md
│   │   └── cw.md
│   ├── checklists/              ← Testing checklists
│   ├── guides/                  ← Detailed guides
│   ├── analysis/                ← Requirements analysis
│   ├── summaries/               ← Status reports
│   └── troubleshooting/         ← Issue fixes
│
├── 📂 database_designs/         ← Database design docs
│   ├── requirements.md
│   ├── logical_design.md
│   └── ...
│
├── 📂 backups/                  ← Database backups
├── 📂 reports/                  ← Generated reports
│
└── 📄 *.bat files               ← Quick launch scripts
```

---

## 🧪 Testing Status

**Honestly, I haven't done thorough testing yet.** Here's what I know works and what needs checking:

### ✅ Tested & Working:
- SQLite database creation
- Sample data population (367 expenses loaded)
- Flask app starts and runs
- All web pages load
- User registration/login
- Dashboard displays data
- Charts render correctly
- Oracle connection works
- Synchronization script runs (390 records synced!)
- PL/SQL packages compile (both VALID status)

### ⚠️ Needs Testing:
- Edge cases in forms (what happens with invalid input?)
- Deleting records
- Updating budgets
- Adding goal contributions
- Error handling
- Mobile responsiveness
- Different browsers
- Performance with lots of data

### 🐛 Known Issues:
- No password encryption yet (storing plain text)
- No input validation on some forms
- Reports might be slow with large datasets
- No pagination on expense list
- Some UI polish needed

**Please test everything and report bugs!**

---

## 🤔 What I Need from You

### 1. Run It and Break It 🔨
- Try to break the app
- Enter weird data
- Click things in weird orders
- Let me know what crashes

### 2. Review the Code 👀
- Is my Python code clean?
- Are my SQL queries efficient?
- Any security concerns?
- Better ways to do things?

### 3. UI/UX Feedback 🎨
- Is the UI intuitive?
- Colors good?
- Navigation clear?
- Missing features?

### 4. Documentation 📚
- Does the documentation make sense?
- Anything unclear?
- Missing information?

### 5. Coursework Requirements ✅
- Check `cw.md` for requirements
- Check `REQUIREMENTS_COMPLETION_ANALYSIS.md` for my completion status
- Did I miss anything?

---

## 🔑 Credentials & Access

### Web App
- **URL**: http://127.0.0.1:5000
- **Test Users**: `john_doe` or `jane_smith` (or register new)
- **No password needed** (simplified)

### SQLite Database
- **File**: `sqlite/finance_local.db`
- **Open with**: DB Browser for SQLite
- Already has 367 expenses, 8 income, 8 budgets, 5 goals

### Oracle Database (if you want to check)
- **Host**: 172.20.10.4
- **Port**: 1521
- **SID**: xe
- **Username**: system
- **Password**: oracle123
- Already has 390 synced records!

---

## 📊 By the Numbers

| What | Count |
|------|-------|
| Total Code | 8,838 lines |
| Python Code | 2,220 lines |
| SQL/PL-SQL | 4,618 lines |
| HTML/CSS/JS | 2,000+ lines |
| Documentation | 50,000+ words |
| Database Tables | 18 (9 × 2) |
| Sample Transactions | 395 |

---

## 🎯 Next Steps (After Your Feedback)

Based on what you guys find, I'll:
1. Fix any bugs you report
2. Optimize slow queries
3. Improve UI based on suggestions
4. Add missing features
5. Write proper unit tests
6. Polish documentation
7. Take screenshots for final report
8. Submit!

---

## 💬 How to Give Feedback

Feel free to:
- **Open Issues** on GitHub
- **Comment on code** (pull requests welcome!)
- **Message me directly** with thoughts
- **Edit this README** with notes

I'm looking for honest, constructive feedback. Don't hold back!

---

## ⏰ Timeline

- **Now**: MVP ready for review
- **Nov 2-3**: Fix bugs, implement feedback
- **Nov 4**: Final polish, screenshots
- **Nov 5**: Submit (deadline 23:59)

---

---

**Last Updated**: November 1, 2025  
**Status**: MVP - Ready for Review  
**Need**: Your feedback!


## � Quick Setup Commands

**For Windows:**
```powershell
# Clone the repo
git clone https://github.com/LakinduQA/DM2_CW.git
cd DM2_CW

# Install dependencies
pip install flask cx_Oracle

# Run the app
cd webapp
.\start.bat
```

**For Mac/Linux:**
```bash
# Clone the repo
git clone https://github.com/LakinduQA/DM2_CW.git
cd DM2_CW

# Install dependencies
pip3 install flask cx_Oracle

# Run the app
cd webapp
chmod +x run_app.sh
./run_app.sh
```

---

## 🔍 What to Check

When you run the app, try these things:

1. **Register a new account** - Does it work?
2. **View the dashboard** - Do charts load?
3. **Add an expense** - Can you create one?
4. **Check budgets** - Progress bars working?
5. **View reports** - Do they generate?
6. **Break things** - Try entering weird data!

Then let me know what works and what doesn't!

---

## 📸 Screenshots Coming Soon

I still need to capture screenshots for the final report:
- All web pages
- Database views
- PL/SQL package status
- Sample data

Will add these after getting your feedback and fixing any issues!

---

## � Report Issues

If you find bugs or have suggestions:
1. Open an issue on GitHub, or
2. Message me directly, or  
3. Add comments to the code

All feedback welcome!

---

## ⚡ Quick Links

- **Coursework Requirements**: See `cw.md`
- **Completion Status**: See `REQUIREMENTS_COMPLETION_ANALYSIS.md`
- **Main Report**: See `FINAL_PROJECT_REPORT.md`
- **All Design Docs**: Check `database_designs/` folder

---

## � Important Notes

- The SQLite database (`sqlite/finance_local.db`) already has 367 sample expenses loaded
- Oracle database is running on my server (172.20.10.4) - you can connect to check
- Synchronization has been tested - it works!
- PL/SQL packages are compiled and VALID
- No extensive testing done yet - **please test thoroughly!**

---

