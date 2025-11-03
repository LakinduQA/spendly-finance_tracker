# Table of Contents
## Personal Finance Management System - Final Report

---

## 1. Introduction
   - 1.1 Project Overview
   - 1.2 Problem Statement
   - 1.3 System Architecture
   - 1.4 Technologies Used
   - 1.5 Project Organization
   - 1.6 Development Timeline

## 2. Database Design
   - 2.1 Logical Design
     - 2.1.1 Entity-Relationship Diagram
     - 2.1.2 Entity Descriptions
     - 2.1.3 Relationship Mappings
     - 2.1.4 Normalization (3NF/BCNF)
     - 2.1.5 Integrity Constraints
   - 2.2 Physical Design - SQLite
     - 2.2.1 Table Schemas
     - 2.2.2 Primary and Foreign Keys
     - 2.2.3 Check Constraints
     - 2.2.4 Unique Constraints
   - 2.3 Physical Design - Oracle
     - 2.3.1 Oracle-Specific Features
     - 2.3.2 Sequences and Tablespaces
     - 2.3.3 Schema Differences

## 3. SQLite Implementation
   - 3.1 SQL Scripts Overview
   - 3.2 Tables and Constraints
     - 3.2.1 User Table
     - 3.2.2 Category Table
     - 3.2.3 Expense Table
     - 3.2.4 Income Table
     - 3.2.5 Budget Table
     - 3.2.6 Savings Goal Table
     - 3.2.7 Savings Contribution Table
     - 3.2.8 Sync Log Table
     - 3.2.9 Audit Log Table
   - 3.3 Indexes and Performance
     - 3.3.1 Primary Key Indexes
     - 3.3.2 Foreign Key Indexes
     - 3.3.3 Date Range Indexes
     - 3.3.4 Composite Indexes
     - 3.3.5 Performance Comparisons
   - 3.4 Triggers and Automation
     - 3.4.1 Timestamp Update Triggers
     - 3.4.2 Fiscal Period Calculation
     - 3.4.3 Savings Goal Updates
     - 3.4.4 Status Automation
   - 3.5 Views for Reporting
     - 3.5.1 Monthly Expenses View
     - 3.5.2 Budget Utilization View
     - 3.5.3 Category Totals View
     - 3.5.4 Goal Progress View
     - 3.5.5 User Summary View

## 4. Oracle PL/SQL Implementation
   - 4.1 PL/SQL CRUD Package
     - 4.1.1 Package Specification
     - 4.1.2 User CRUD Operations
     - 4.1.3 Expense CRUD Operations
     - 4.1.4 Income CRUD Operations
     - 4.1.5 Budget CRUD Operations
     - 4.1.6 Savings Goal CRUD Operations
   - 4.2 PL/SQL Reports Package
     - 4.2.1 Package Specification
     - 4.2.2 Monthly Expenditure Report
     - 4.2.3 Budget Adherence Report
     - 4.2.4 Savings Progress Report
     - 4.2.5 Category Distribution Report
     - 4.2.6 Savings Forecast Report
   - 4.3 Stored Procedures
   - 4.4 Functions and Cursors

## 5. Synchronization Mechanisms
   - 5.1 Architecture and Strategy
   - 5.2 Bidirectional Sync Logic
   - 5.3 Conflict Resolution
   - 5.4 Error Handling
   - 5.5 Python Implementation
   - 5.6 Sync Logging

## 6. Generated Reports
   - 6.1 Monthly Expenditure Analysis
   - 6.2 Budget Adherence Tracking
   - 6.3 Savings Progress Report
   - 6.4 Category Distribution Analysis
   - 6.5 Savings Forecast Trends

## 7. Data Security & Privacy
   - 7.1 Authentication System
   - 7.2 Password Hashing (PBKDF2-SHA256)
   - 7.3 SQL Injection Prevention
   - 7.4 Session Security
   - 7.5 Access Control
   - 7.6 GDPR Compliance
   - 7.7 Audit Logging

## 8. Backup & Recovery
   - 8.1 Backup Strategy
   - 8.2 SQLite Backup Procedures
   - 8.3 Oracle Backup Procedures
   - 8.4 Recovery Procedures
   - 8.5 Disaster Recovery Plan
   - 8.6 RTO and RPO Objectives

## 9. Migration Plan
   - 9.1 Database Migration Strategy
   - 9.2 Data Migration Process
   - 9.3 Application Migration
   - 9.4 Rollback Procedures
   - 9.5 Testing and Validation

## 10. Testing & Validation
   - 10.1 Unit Testing
   - 10.2 Integration Testing
   - 10.3 System Testing
   - 10.4 User Acceptance Testing
   - 10.5 Performance Testing
   - 10.6 Security Testing
   - 10.7 Test Results Summary

## 11. Conclusion
   - 11.1 Project Summary
   - 11.2 Achievements
   - 11.3 Challenges and Solutions
   - 11.4 Lessons Learned
   - 11.5 Future Enhancements

## 12. References
   - 12.1 Academic Sources
   - 12.2 Technical Documentation
   - 12.3 Online Resources

## 13. Appendices
   - Appendix A: Database Schema Diagrams
   - Appendix B: Complete SQL Scripts
   - Appendix C: PL/SQL Package Listings
   - Appendix D: Screenshots
   - Appendix E: Setup and Installation Guide
   - Appendix F: User Manual
   - Appendix G: API Documentation

---

**Total Sections**: 13 major sections  
**Total Subsections**: 90+ detailed topics  
**Estimated Pages**: 60-80 pages  
**Word Count**: 15,000+ words
