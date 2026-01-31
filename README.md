#  Spendly - Personal Finance Tracker

A modern, full-stack personal finance management system with dual-database architecture, real-time synchronization, and comprehensive financial reporting.

![Python](https://img.shields.io/badge/Python-3.8+-blue.svg)
![Flask](https://img.shields.io/badge/Flask-3.0-green.svg)
![SQLite](https://img.shields.io/badge/SQLite-3-lightgrey.svg)
![Oracle](https://img.shields.io/badge/Oracle-Database-red.svg)
![Bootstrap](https://img.shields.io/badge/Bootstrap-5.3-purple.svg)

##  Features

### Core Functionality
- **Expense Tracking** - Categorize and track daily expenses with multiple payment methods
- **Income Management** - Record income from various sources
- **Budget Planning** - Set monthly budgets with visual progress tracking
- **Savings Goals** - Create financial goals and track contributions
- **Financial Reports** - Generate comprehensive reports with charts and analytics

### Technical Highlights
- **Dual Database Architecture** - SQLite for fast local operations, Oracle for enterprise analytics
- **Bidirectional Sync** - Seamless synchronization between local and cloud databases
- **PL/SQL Reports** - 5 comprehensive financial reports using advanced Oracle features
- **Secure Authentication** - PBKDF2-SHA256 password hashing (600k iterations)
- **Responsive UI** - Modern Bootstrap 5 design with Chart.js visualizations

##  Quick Start

### Prerequisites
- Python 3.8 or higher
- Oracle Database (optional - for sync features)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/LakinduQA/spendly-finance_tracker.git
   cd spendly-finance_tracker
   ```

2. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

3. **Create the SQLite database**
   ```bash
   cd sqlite
   sqlite3 finance_local.db < 01_create_database.sql
   cd ..
   ```
   
   Or on Windows, the database is created automatically on first run.

4. **Run the application**
   ```bash
   cd webapp
   python app.py
   ```

5. **Open your browser**
   ```
   http://127.0.0.1:5000
   ```

### Windows Users
Double-click `scripts/batch/setup.bat` for a guided setup wizard.

### Optional: Add Sample Data

To populate the database with test data (5 users, 90 days of transactions):
```bash
cd scripts
python populate_sample_data.py
```

Then login with:
- Username: `dilini.fernando`
- Password: `Password123!`

## 📸 Screenshots

### Dashboard
- Financial overview with income, expenses, and savings summary
- Interactive charts showing expense distribution
- Budget progress indicators
- Recent transactions view

### Features
- Add/edit/delete expenses with category and payment method
- Track multiple income sources
- Set monthly budgets with visual progress bars
- Create savings goals with contribution tracking

##  Database Architecture

```
┌─────────────┐         ┌──────────────┐         ┌──────────────┐
│  Web UI     │────────▶│   SQLite     │────────▶│    Oracle    │
│  (Flask)    │         │   (Local)    │  Sync   │  (Central)   │
│  Bootstrap  │         │  Fast CRUD   │         │  Analytics   │
└─────────────┘         └──────────────┘         └──────────────┘
```

### SQLite (Local)
- Primary database for web application
- Fast, serverless operations
- Offline capability
- 9 tables with triggers and views

### Oracle (Central)
- Enterprise-grade analytics
- PL/SQL stored procedures
- 5 comprehensive financial reports
- Advanced SQL queries

##  Financial Reports

The system generates 5 detailed financial reports:

1. **Monthly Expenditure Analysis** - Track spending patterns by month
2. **Budget Adherence Report** - Monitor budget compliance with variance analysis
3. **Savings Progress Tracker** - Goal completion status and projections
4. **Category Distribution** - Expense breakdown by category
5. **Forecasted Savings** - Future savings predictions based on trends

##  Tech Stack

| Layer | Technology |
|-------|------------|
| **Backend** | Python 3.x, Flask 3.0 |
| **Frontend** | HTML5, Bootstrap 5.3, Chart.js |
| **Local Database** | SQLite 3 |
| **Cloud Database** | Oracle Database |
| **Sync Module** | cx_Oracle, Custom Python |
| **Security** | Werkzeug (PBKDF2-SHA256) |

##  Project Structure

```
spendly-finance_tracker/
├── webapp/                 # Flask web application
│   ├── app.py             # Main application
│   ├── templates/         # HTML templates
│   └── static/            # CSS, JS, images
├── sqlite/                # SQLite database & scripts
├── oracle/                # Oracle PL/SQL scripts
├── synchronization/       # Database sync module
├── scripts/               # Utility & batch scripts
├── tests/                 # Test scripts
├── database_designs/      # Design documentation
└── docs/                  # User & setup guides
```

##  Security Features

- **Password Hashing** - PBKDF2-SHA256 with 600,000 iterations
- **SQL Injection Prevention** - Parameterized queries throughout
- **Session Management** - Secure session handling with timeouts
- **Input Validation** - Server-side validation for all inputs
- **Soft Delete** - Data preservation with `is_deleted` flags

##  Configuration

### Oracle Connection (Optional)

1. Copy the example config:
   ```bash
   cp synchronization/config.example.ini synchronization/config.ini
   ```

2. Edit `config.ini` with your Oracle credentials:
   ```ini
   [oracle]
   username = your_username
   password = your_password
   host = localhost
   port = 1521
   sid = xe
   ```

##  Testing

Run the test suite:
```bash
cd tests
python test_sync.py
python verify_database.py
```

##  Sample Data

Populate the database with sample data:
```bash
cd scripts
python populate_sample_data.py
```

This creates:
- 5 sample users with Sri Lankan names
- 90 days of expense transactions
- Income records, budgets, and savings goals

**Demo Login:**
- Username: `dilini.fernando`
- Password: `Password123!`

##  Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

##  License

This project is open source and available under the [MIT License](LICENSE).

##  Author

**Lakindu De Silva**
- GitHub: [@LakinduQA](https://github.com/LakinduQA)

---

 If you find this project useful, please consider giving it a star!
