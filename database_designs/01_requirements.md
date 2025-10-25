# Requirements Analysis - Personal Finance Management System

## 1. System Overview
A dual-database personal finance management system that uses:
- **SQLite**: Local, offline data storage for individual users
- **Oracle Database**: Centralized data storage for analytics and reporting

## 2. Functional Requirements

### 2.1 Expense Tracking
- **FR-ET-01**: Users shall be able to record expenses with the following details:
  - Expense amount (decimal, required)
  - Expense category (text, required)
  - Expense date (date, required)
  - Description (text, optional)
  - Payment method (Cash, Card, Online, etc.)
  
- **FR-ET-02**: System shall support multiple expense categories:
  - Food & Dining
  - Transportation
  - Entertainment
  - Bills & Utilities
  - Healthcare
  - Shopping
  - Education
  - Others

- **FR-ET-03**: Users shall be able to view, edit, and delete their expenses

### 2.2 Income Tracking
- **FR-IT-01**: Users shall be able to record income with details:
  - Income amount (decimal, required)
  - Income source (text, required)
  - Income date (date, required)
  - Description (text, optional)

- **FR-IT-02**: System shall support multiple income sources:
  - Salary
  - Freelance
  - Investment
  - Gift
  - Others

### 2.3 Budget Creation and Monitoring
- **FR-BM-01**: Users shall be able to create monthly budgets for each category
- **FR-BM-02**: System shall track budget utilization percentage
- **FR-BM-03**: System shall identify budget overruns (actual > budgeted)
- **FR-BM-04**: Budgets shall have start and end dates
- **FR-BM-05**: Users can set budget limits per category

### 2.4 Savings Goal Management
- **FR-SG-01**: Users shall be able to set savings goals with:
  - Goal name (text, required)
  - Target amount (decimal, required)
  - Deadline date (date, required)
  - Current saved amount (decimal, default 0)
  - Priority level (High, Medium, Low)

- **FR-SG-02**: System shall calculate and display progress percentage
- **FR-SG-03**: Users can contribute to savings goals
- **FR-SG-04**: System shall track goal achievement status

### 2.5 Synchronization
- **FR-SY-01**: System shall sync local SQLite data to Oracle database periodically
- **FR-SY-02**: System shall handle conflict resolution during sync:
  - Last modified timestamp wins
  - Track sync status for each record
- **FR-SY-03**: System shall maintain sync logs
- **FR-SY-04**: Users can manually trigger synchronization

### 2.6 Reporting & Analytics
- **FR-RP-01**: Monthly expenditure analysis report
- **FR-RP-02**: Budget adherence tracking report
- **FR-RP-03**: Savings goal progress report
- **FR-RP-04**: Category-wise expense distribution report
- **FR-RP-05**: Forecasted savings trends report
- **FR-RP-06**: All reports shall be exportable to CSV format

## 3. Non-Functional Requirements

### 3.1 Data Security
- **NFR-DS-01**: Sensitive financial data shall be encrypted
- **NFR-DS-02**: Database access shall be controlled via authentication
- **NFR-DS-03**: SQLite database files shall be protected with encryption
- **NFR-DS-04**: Oracle database shall use role-based access control

### 3.2 Data Privacy
- **NFR-DP-01**: User financial data shall remain private
- **NFR-DP-02**: No data shall be shared without user consent
- **NFR-DP-03**: Compliance with data protection regulations

### 3.3 Performance
- **NFR-PF-01**: Local SQLite operations shall complete within 1 second
- **NFR-PF-02**: Synchronization shall complete within 5 minutes for 1000 records
- **NFR-PF-03**: Reports shall generate within 3 seconds

### 3.4 Reliability
- **NFR-RL-01**: System shall maintain data integrity during sync failures
- **NFR-RL-02**: Automatic backup mechanism for SQLite database
- **NFR-RL-03**: Oracle database backup strategy with recovery point objective (RPO) of 24 hours

### 3.5 Usability
- **NFR-US-01**: Clear SQL scripts for CRUD operations
- **NFR-US-02**: Well-documented PL/SQL procedures
- **NFR-US-03**: User-friendly CSV report formats

## 4. Database-Specific Requirements

### 4.1 SQLite (Local Database)
- **Offline functionality**: Complete CRUD operations without internet
- **Lightweight storage**: Optimized for single-user access
- **Constraints**: Primary keys, foreign keys, NOT NULL, UNIQUE
- **Data types**: INTEGER, REAL, TEXT, DATE

### 4.2 Oracle Database (Central Database)
- **Advanced constraints**: CHECK, DEFAULT values in addition to basic constraints
- **PL/SQL procedures**: For all CRUD operations
- **Aggregation**: Store and analyze synced data from multiple sources
- **Triggers**: For audit logging and validation
- **Advanced data types**: NUMBER, VARCHAR2, DATE, TIMESTAMP

## 5. Data Flow

```
User Input → SQLite (Local) → Synchronization Service → Oracle (Central) → Reports & Analytics
      ↑                                                           ↓
      └─────────────────── Dashboard & Insights ─────────────────┘
```

## 6. User Stories

### US-01: Record Daily Expenses
**As a** user  
**I want to** record my daily expenses with category and amount  
**So that** I can track where my money is being spent

### US-02: Set Monthly Budget
**As a** user  
**I want to** set a monthly budget for different spending categories  
**So that** I can control my spending and stay within limits

### US-03: Track Savings Goals
**As a** user  
**I want to** create savings goals with target amounts and deadlines  
**So that** I can work towards achieving my financial objectives

### US-04: View Spending Reports
**As a** user  
**I want to** generate reports showing my spending patterns  
**So that** I can make informed financial decisions

### US-05: Sync Data to Cloud
**As a** user  
**I want to** synchronize my local data to a central database  
**So that** I have backup and can access analytics

## 7. Dual-Database Justification

### 7.1 Why SQLite?
1. **Offline Access**: Users can manage finances without internet connectivity
2. **Local Performance**: Fast read/write operations for daily transactions
3. **Zero Configuration**: No server setup required for end users
4. **Lightweight**: Minimal resource consumption on client devices
5. **Portability**: Single file database, easy to backup and transfer
6. **Privacy**: Data stays on user's device until they choose to sync

### 7.2 Why Oracle Database?
1. **Centralized Analytics**: Aggregate data across multiple users (if extended)
2. **Advanced Features**: PL/SQL, triggers, packages for complex business logic
3. **Scalability**: Handle large volumes of historical financial data
4. **Enterprise Security**: Robust security features and access control
5. **Data Integrity**: ACID compliance for critical financial data
6. **Backup & Recovery**: Professional-grade backup and disaster recovery options

### 7.3 Advantages of Dual Approach
1. **Best of Both Worlds**: Local speed + Central intelligence
2. **Resilience**: System works even if central database is unavailable
3. **Data Sovereignty**: Users control when to sync sensitive data
4. **Reduced Load**: Central database only handles periodic syncs, not real-time operations
5. **Flexibility**: Can work completely offline or leverage cloud analytics
6. **Learning Opportunity**: Demonstrates mastery of both embedded and enterprise databases

## 8. Success Criteria
- All CRUD operations working in both SQLite and Oracle
- Successful bidirectional synchronization with conflict resolution
- All 5 reports generating accurate data
- Complete documentation of database designs and procedures
- Security measures implemented and documented
- Backup and recovery strategies defined and tested
