# Section 2: Introduction

**Personal Finance Management System**  
**Data Management 2 Coursework**

---

## 1.1 Project Overview

### Purpose

The Personal Finance Management System is a comprehensive web-based application designed to help individuals track, manage, and analyze their personal finances. The system provides a centralized platform for managing expenses, income, budgets, and savings goals while maintaining data integrity across both local and cloud environments through intelligent synchronization.

### Problem Statement

Managing personal finances effectively remains a significant challenge for individuals in today's complex financial landscape:

- **Fragmented Data**: Financial information scattered across multiple platforms and documents
- **Limited Visibility**: Difficulty in understanding spending patterns and budget utilization
- **Manual Tracking**: Time-consuming manual entry and calculation of financial data
- **No Forecasting**: Lack of tools to predict future savings and financial trends
- **Data Loss Risk**: Vulnerability to data loss without proper backup mechanisms
- **Offline Access**: Need for local data access even without internet connectivity

### Solution

This project addresses these challenges by implementing a dual-database architecture that combines:

1. **Local SQLite Database**: Fast, offline-capable storage for immediate data access
2. **Oracle Cloud Database**: Centralized, secure storage with advanced PL/SQL capabilities
3. **Intelligent Synchronization**: Bidirectional sync with conflict resolution
4. **Advanced Reporting**: Five comprehensive PL/SQL reports with CSV export
5. **Security**: PBKDF2-SHA256 password hashing and SQL injection prevention
6. **Automation**: 30+ triggers for automatic data maintenance

### Key Capabilities

The system provides the following core functionalities:

1. **User Management**
   - Secure registration and authentication
   - Password hashing with PBKDF2-SHA256
   - Profile management

2. **Financial Tracking**
   - Expense recording with categories and payment methods
   - Income tracking from multiple sources
   - Automatic fiscal period calculation
   - Transaction history with filtering

3. **Budget Management**
   - Category-based budget creation
   - Real-time budget utilization monitoring
   - Overspending alerts
   - Budget vs. actual comparisons

4. **Savings Goals**
   - Goal creation with target amounts and deadlines
   - Contribution tracking
   - Progress visualization
   - Priority-based goal management
   - Automatic status updates

5. **Advanced Reporting**
   - Monthly expenditure analysis
   - Budget adherence tracking
   - Savings progress reports
   - Category distribution analysis
   - Forecasted savings trends

6. **Data Synchronization**
   - Manual and automatic sync options
   - Bidirectional data flow (SQLite ↔ Oracle)
   - Conflict resolution using last-modified-wins strategy
   - Comprehensive sync logging

---

## 1.2 Problem Statement

### Current Challenges in Personal Finance Management

#### 1. **Data Fragmentation**
Many individuals use multiple tools (spreadsheets, mobile apps, paper notebooks) leading to:
- Inconsistent data formats
- Difficulty in consolidating financial information
- Time wasted reconciling different sources
- Risk of data duplication and errors

#### 2. **Limited Analytics**
Basic tracking tools lack advanced analytical capabilities:
- No trend analysis or forecasting
- Manual calculation of totals and percentages
- Inability to identify spending patterns
- No predictive insights for future planning

#### 3. **Connectivity Dependency**
Cloud-only solutions face limitations:
- Require constant internet connectivity
- Slow performance in areas with poor network
- Cannot access data during outages
- Latency issues with remote databases

#### 4. **Security Concerns**
Many personal finance applications have security vulnerabilities:
- Weak password storage mechanisms
- SQL injection vulnerabilities
- Unencrypted data transmission
- Inadequate access controls

#### 5. **Lack of Customization**
Off-the-shelf solutions often lack flexibility:
- Fixed categories that don't match user needs
- Limited reporting options
- Cannot adapt to different currencies
- No support for custom fiscal periods

### Our Solution Approach

This project addresses these challenges through:

1. **Hybrid Architecture**: SQLite for local speed + Oracle for cloud power
2. **Smart Sync**: Intelligent bidirectional synchronization with conflict resolution
3. **Advanced PL/SQL**: Five comprehensive reports with forecasting capabilities
4. **Security First**: Industry-standard PBKDF2 hashing and parameterized queries
5. **Customization**: Flexible categories, custom date ranges, Sri Lankan context (LKR currency)
6. **Automation**: 30+ triggers and stored procedures for automatic data maintenance

---

## 1.3 System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      User Interface Layer                    │
│  (HTML5, CSS3, JavaScript, Bootstrap 5, Chart.js)           │
└──────────────────┬──────────────────────────────────────────┘
                   │ HTTP/HTTPS
                   ▼
┌─────────────────────────────────────────────────────────────┐
│                   Application Layer                          │
│            Flask 3.1.0 Web Framework (Python 3.13)          │
│  ┌─────────────┬──────────────┬──────────────┬───────────┐ │
│  │   Routes    │  Business    │   Session    │   Error   │ │
│  │  (app.py)   │    Logic     │  Management  │  Handling │ │
│  └─────────────┴──────────────┴──────────────┴───────────┘ │
└──────────────────┬────────────────────────┬─────────────────┘
                   │                        │
                   ▼                        ▼
┌──────────────────────────────┐  ┌────────────────────────────┐
│     Local Database Layer     │  │  Synchronization Layer     │
│    SQLite 3 (finance_local)  │◄─┤    sync_manager.py         │
│  ┌────────────────────────┐  │  │  (620 lines Python)        │
│  │  9 Tables              │  │  │  - Bidirectional sync      │
│  │  28 Indexes            │  │  │  - Conflict resolution     │
│  │  10 Triggers           │  │  │  - Error handling          │
│  │  5 Views               │  │  │  - Logging                 │
│  └────────────────────────┘  │  └─────────────┬──────────────┘
└──────────────────────────────┘                │
                                                 ▼
                                 ┌────────────────────────────┐
                                 │  Cloud Database Layer      │
                                 │  Oracle 11g XE (Cloud)     │
                                 │  ┌──────────────────────┐  │
                                 │  │  9 Tables            │  │
                                 │  │  30+ Indexes         │  │
                                 │  │  20+ Triggers        │  │
                                 │  │  2 PL/SQL Packages   │  │
                                 │  │  - pkg_finance_crud  │  │
                                 │  │  - pkg_finance_reports│  │
                                 │  └──────────────────────┘  │
                                 └────────────────────────────┘
```

### Database Architecture

#### SQLite (Local Database)
- **Purpose**: Fast local storage, offline capability
- **Location**: `d:/DM2_CW/sqlite/finance_local.db`
- **Size**: ~5 MB with test data
- **Performance**: Sub-millisecond query times
- **Features**:
  - 9 normalized tables (3NF)
  - 28 performance indexes
  - 10 automated triggers
  - 5 reporting views

#### Oracle (Cloud Database)
- **Purpose**: Centralized storage, advanced PL/SQL capabilities
- **Location**: `172.20.10.4:1521/xe`
- **Connection**: cx_Oracle driver
- **Features**:
  - Full PL/SQL support
  - 30+ stored procedures
  - 5 comprehensive reports
  - Advanced cursor operations
  - Sequence generators

#### Synchronization Layer
- **Bidirectional**: SQLite ↔ Oracle
- **Conflict Resolution**: Last-modified-wins strategy
- **Error Handling**: Retry logic with exponential backoff
- **Logging**: Comprehensive sync_log table tracking all operations

### Application Layers

#### 1. Presentation Layer (Frontend)
- **HTML5/CSS3**: Semantic markup and responsive design
- **Bootstrap 5**: UI components and grid system
- **JavaScript/jQuery**: Dynamic interactions and AJAX
- **Chart.js**: Data visualization (pie charts, bar charts, line graphs)
- **Font Awesome**: Icon library

#### 2. Application Layer (Backend)
- **Flask 3.1.0**: Lightweight WSGI web framework
- **Werkzeug**: Password hashing and security utilities
- **Flask-Session**: Server-side session management
- **Custom Modules**:
  - `app.py` (2,220 lines): Main application logic and routes
  - `sync_manager.py` (620 lines): Database synchronization
  
#### 3. Data Access Layer
- **sqlite3**: Python built-in SQLite interface
- **cx_Oracle**: Oracle database driver
- **Parameterized Queries**: SQL injection prevention
- **Connection Pooling**: Efficient resource management

#### 4. Business Logic Layer
- **User Authentication**: Login/logout with session management
- **CRUD Operations**: Create, Read, Update, Delete for all entities
- **Budget Calculations**: Real-time utilization tracking
- **Goal Management**: Progress tracking and status updates
- **Report Generation**: PL/SQL-based analytics

---

## 1.4 Technologies Used

### Database Technologies

| Technology | Version | Purpose | Key Features |
|------------|---------|---------|--------------|
| **SQLite** | 3.43+ | Local database | • Serverless<br>• Zero configuration<br>• ACID compliant<br>• 140 TB max DB size |
| **Oracle XE** | 11g R2 | Cloud database | • PL/SQL support<br>• Advanced analytics<br>• Enterprise features<br>• Scalability |
| **cx_Oracle** | 8.3.0 | Python-Oracle driver | • Native Oracle connectivity<br>• Connection pooling<br>• LOB support |

### Backend Technologies

| Technology | Version | Purpose | Key Features |
|------------|---------|---------|--------------|
| **Python** | 3.13.0 | Core language | • Clean syntax<br>• Rich libraries<br>• Cross-platform |
| **Flask** | 3.1.0 | Web framework | • Lightweight<br>• RESTful routing<br>• Jinja2 templating |
| **Werkzeug** | 3.0.0 | Security utilities | • PBKDF2 hashing<br>• Secure cookies<br>• Password validation |

### Frontend Technologies

| Technology | Version | Purpose | Key Features |
|------------|---------|---------|--------------|
| **HTML5** | - | Markup | • Semantic elements<br>• Form validation<br>• Local storage API |
| **CSS3** | - | Styling | • Flexbox/Grid<br>• Animations<br>• Media queries |
| **Bootstrap** | 5.3.0 | UI framework | • Responsive grid<br>• Components<br>• Utilities |
| **JavaScript** | ES6+ | Interactivity | • Async/await<br>• Arrow functions<br>• Template literals |
| **jQuery** | 3.6.0 | DOM manipulation | • AJAX requests<br>• Event handling<br>• Animations |
| **Chart.js** | 4.0.0 | Data visualization | • Responsive charts<br>• Multiple types<br>• Animations |

### Development Tools

| Tool | Purpose |
|------|---------|
| **VS Code** | Primary IDE with Python and SQL extensions |
| **Git** | Version control and collaboration |
| **Oracle SQL Developer** | Database management and PL/SQL development |
| **DB Browser for SQLite** | SQLite database inspection |
| **Postman** | API testing and debugging |
| **Chrome DevTools** | Frontend debugging and performance analysis |

### Python Libraries

```python
# Requirements.txt
Flask==3.1.0
cx-Oracle==8.3.0
Werkzeug==3.0.0
configparser==6.0.0
```

---

## 1.5 Project Organization

### Folder Structure

```
D:/DM2_CW/
│
├── webapp/                          # Flask application
│   ├── app.py                       # Main application (2,220 lines)
│   ├── templates/                   # HTML templates
│   │   ├── login.html
│   │   ├── register.html
│   │   ├── dashboard.html
│   │   ├── expenses.html
│   │   ├── income.html
│   │   ├── budgets.html
│   │   ├── goals.html
│   │   └── reports.html
│   └── static/                      # CSS, JS, images
│       ├── css/
│       ├── js/
│       └── images/
│
├── sqlite/                          # SQLite database and scripts
│   ├── finance_local.db             # Main database (5 MB)
│   ├── 01_create_database.sql       # Schema creation (500+ lines)
│   └── 02_crud_operations.sql       # CRUD queries
│
├── oracle/                          # Oracle database scripts
│   ├── 01_create_schema.sql         # Table creation (600 lines)
│   ├── 02_plsql_crud_package.sql    # CRUD package (818 lines)
│   ├── 03_reports_package.sql       # Reports package (720 lines)
│   ├── 04_sample_data.sql           # Test data
│   └── 05_recompile_reports.sql     # Package recompilation
│
├── synchronization/                 # Sync module
│   ├── sync_manager.py              # Main sync logic (620 lines)
│   └── config.ini                   # Database configuration
│
├── tests/                           # Testing scripts
│   ├── test_sync.py                 # Sync functionality tests
│   ├── test_sync_extended.py        # Extended timeout tests
│   └── verify_database.py           # Database validation
│
├── scripts/                         # Utility scripts
│   └── populate_sample_data.py      # Test data generation
│
├── logs/                            # Application logs
│   └── sync_log.txt                 # Synchronization logs
│
├── documentation_finalReport/       # Project documentation
│   ├── finalReportLatest/           # Modular report sections
│   ├── FINAL_PROJECT_REPORT.md      # Original report
│   └── REPORT_STATUS.md             # Status tracking
│
├── docs/                            # Additional documentation
│   ├── setup/
│   │   └── COMPLETE_SETUP_GUIDE.md
│   ├── user-guide/
│   │   └── QUICKSTART.md
│   └── development/
│       ├── cw.md
│       └── WHICH_FILE_TO_USE.md
│
└── archived/                        # Old/deprecated files
    ├── test_users.sql
    ├── create_db.py
    └── convert_to_lkr.py
```

### Code Organization

#### Flask Application (`webapp/app.py`)
- **Lines**: 2,220
- **Routes**: 25+ endpoints
- **Key Sections**:
  - Authentication (lines 1-200)
  - Dashboard (lines 201-400)
  - Expense management (lines 401-600)
  - Income management (lines 601-800)
  - Budget management (lines 801-1000)
  - Savings goals (lines 1001-1200)
  - Synchronization (lines 1201-1400)
  - Reports (lines 1401-1600)
  - API endpoints (lines 1601-1800)
  - Utilities (lines 1801-2220)

#### Synchronization Module (`synchronization/sync_manager.py`)
- **Lines**: 620
- **Classes**: 1 main class (`DatabaseSync`)
- **Methods**: 15+ sync methods
- **Key Features**:
  - Connection management
  - Bidirectional sync
  - Conflict resolution
  - Error handling
  - Logging

---

## 1.6 Development Timeline

### Phase 1: Planning and Design (Week 1-2)
- ✅ Requirements analysis
- ✅ ER diagram creation
- ✅ Normalization (3NF/BCNF)
- ✅ Technology selection
- ✅ Architecture design

### Phase 2: Database Implementation (Week 3-4)
- ✅ SQLite schema creation (9 tables)
- ✅ Oracle schema creation with PL/SQL
- ✅ Index optimization (28 SQLite + 30 Oracle)
- ✅ Trigger implementation (30 total)
- ✅ View creation (5 reporting views)

### Phase 3: PL/SQL Development (Week 5-6)
- ✅ CRUD package (pkg_finance_crud) - 818 lines
- ✅ Reports package (pkg_finance_reports) - 720 lines
- ✅ 30+ stored procedures
- ✅ 5 comprehensive reports
- ✅ CSV export functionality

### Phase 4: Backend Development (Week 7-8)
- ✅ Flask application setup
- ✅ Authentication system
- ✅ CRUD routes (25+ endpoints)
- ✅ Business logic implementation
- ✅ Session management

### Phase 5: Synchronization (Week 9)
- ✅ Sync module development (620 lines)
- ✅ Bidirectional sync logic
- ✅ Conflict resolution
- ✅ Error handling
- ✅ Comprehensive logging

### Phase 6: Frontend Development (Week 10-11)
- ✅ Responsive UI with Bootstrap 5
- ✅ Dashboard with Chart.js
- ✅ AJAX interactions
- ✅ Form validation
- ✅ User experience optimization

### Phase 7: Testing and Data (Week 12)
- ✅ Unit testing
- ✅ Integration testing
- ✅ Test data generation (5 users, 1,350+ transactions)
- ✅ Performance testing
- ✅ Security testing

### Phase 8: Documentation and Finalization (Week 13-14)
- ✅ Code documentation
- ✅ User manual creation
- ✅ Setup guides
- ✅ Final report preparation
- ✅ Project organization

---

## Project Statistics

### Code Metrics
- **Total Lines of Code**: 10,000+
- **Python Code**: 2,840 lines
- **SQL/PL-SQL Code**: 4,618 lines
- **JavaScript Code**: 1,500+ lines
- **HTML/CSS**: 2,000+ lines

### Database Metrics
- **Tables**: 9 entities × 2 databases = 18 total
- **Columns**: 60+ attributes
- **Indexes**: 58 total (28 SQLite + 30 Oracle)
- **Triggers**: 30 total (10 SQLite + 20 Oracle)
- **Views**: 5 reporting views
- **Stored Procedures**: 30+ PL/SQL procedures

### Test Data
- **Users**: 5 Sri Lankan users
- **Transactions**: 1,350+ over 90 days
- **Categories**: 13 predefined categories
- **Budgets**: 25+ active budgets
- **Goals**: 15+ savings goals

### Documentation
- **Total Words**: 30,000+
- **Setup Guides**: 3 comprehensive guides
- **API Documentation**: Complete endpoint listing
- **Code Comments**: 2,000+ inline comments

---

**This comprehensive architecture and organization ensures a maintainable, scalable, and professional personal finance management system that meets all coursework requirements while providing real-world functionality.**
