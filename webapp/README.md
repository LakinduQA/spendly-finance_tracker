# Spendly Web Application

The Flask-based web frontend for the Spendly personal finance tracker.

## Features

### User Interface
- **Modern Design** - Bootstrap 5 with custom styling
- **Responsive Layout** - Works on desktop, tablet, and mobile
- **Interactive Charts** - Chart.js for data visualization
- **Real-time Updates** - Dynamic content without page reloads

### Pages
- **Login/Register** - User authentication with secure password hashing
- **Dashboard** - Financial overview with charts and quick stats
- **Expenses** - Add, view, and manage expense records
- **Income** - Track income from various sources
- **Budgets** - Set and monitor monthly budgets
- **Savings Goals** - Create goals and track contributions
- **Reports** - Generate comprehensive financial reports

## Quick Start

### Run the Application

```bash
cd webapp
python app.py
```

Open your browser to: **http://127.0.0.1:5000**

### First Time?

1. Click "Create Account" to register
2. Log in with your credentials
3. Start tracking your finances!

## Project Structure

```
webapp/
├── app.py                  # Main Flask application
├── requirements.txt        # Python dependencies
├── templates/              # Jinja2 HTML templates
│   ├── base.html          # Base layout with navigation
│   ├── login.html         # Login page
│   ├── register.html      # Registration page
│   ├── dashboard.html     # Main dashboard
│   ├── expenses.html      # Expense management
│   ├── income.html        # Income tracking
│   ├── budgets.html       # Budget planning
│   ├── goals.html         # Savings goals
│   └── reports.html       # Analytics and reports
└── static/                 # Static assets
    ├── css/
    │   └── style.css      # Custom styles
    └── js/
        └── main.js        # JavaScript utilities
```

## API Endpoints

### Pages (GET)
| Route | Description |
|-------|-------------|
| `/` | Redirect to login or dashboard |
| `/login` | Login page |
| `/register` | Registration page |
| `/dashboard` | Main dashboard |
| `/expenses` | Expense management |
| `/income` | Income tracking |
| `/budgets` | Budget planning |
| `/goals` | Savings goals |
| `/reports` | Financial reports |

### Data API (GET)
| Route | Description |
|-------|-------------|
| `/api/expense_by_category` | Category-wise expense data for charts |
| `/api/monthly_trend` | Monthly expense trend data |

### Actions (POST)
| Route | Description |
|-------|-------------|
| `/login` | Authenticate user |
| `/register` | Create new account |
| `/add_expense` | Add new expense |
| `/add_income` | Add new income record |
| `/add_budget` | Create new budget |
| `/add_goal` | Create savings goal |
| `/add_contribution` | Add goal contribution |
| `/delete_expense/<id>` | Delete expense |
| `/delete_income/<id>` | Delete income |
| `/sync` | Trigger database synchronization |

## Configuration

### Database
The application uses SQLite by default. The database file is located at:
```
../sqlite/finance_local.db
```

### Oracle Synchronization
To enable Oracle sync, configure `../synchronization/config.ini`:
```ini
[oracle]
username = your_username
password = your_password
host = localhost
port = 1521
sid = xe
```

## Security

- **Password Hashing** - PBKDF2-SHA256 with 600,000 iterations
- **Session Management** - Secure server-side sessions
- **SQL Injection Prevention** - Parameterized queries
- **Input Validation** - Server-side validation

## Dependencies

See `requirements.txt`:
- Flask 3.0+
- Werkzeug (for password hashing)
- cx_Oracle (optional, for Oracle sync)

## Development

### Debug Mode
The application runs in debug mode by default. For production:

```python
# In app.py, change:
app.run(debug=False, host='0.0.0.0', port=5000)
```

### Environment Variables
For production, set these environment variables:
- `SECRET_KEY` - Session encryption key
- `DATABASE_PATH` - Path to SQLite database

## Troubleshooting

### Port Already in Use
```bash
# Change port in app.py or use:
python app.py --port 5001
```

### Database Not Found
The database is created automatically on first run. If issues persist:
```bash
cd ../sqlite
sqlite3 finance_local.db < 01_create_database.sql
```

### cx_Oracle Issues
Oracle sync is optional. If cx_Oracle fails to install:
1. Install Oracle Instant Client
2. Add to PATH
3. Reinstall: `pip install cx_Oracle`

## License

MIT License - See repository root for details.
