"""
Personal Finance Management System
Synchronization Module - SQLite to Oracle
Handles bidirectional data synchronization with conflict resolution
"""

import sqlite3
import cx_Oracle
import configparser
import logging
from datetime import datetime
from pathlib import Path
import sys

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('sync_log.txt'),
        logging.StreamHandler(sys.stdout)
    ]
)

logger = logging.getLogger(__name__)


class DatabaseSync:
    """Handles synchronization between SQLite and Oracle databases"""
    
    def __init__(self, config_file='config.ini'):
        """Initialize database connections"""
        self.config = configparser.ConfigParser()
        self.config.read(config_file)
        
        self.sqlite_conn = None
        self.oracle_conn = None
        self.sync_log_id = None
        self.records_synced = 0
        
    def connect_sqlite(self):
        """Connect to SQLite database"""
        try:
            db_path = self.config['sqlite']['database_path']
            self.sqlite_conn = sqlite3.connect(db_path)
            self.sqlite_conn.row_factory = sqlite3.Row
            logger.info(f"Connected to SQLite database: {db_path}")
            return True
        except Exception as e:
            logger.error(f"SQLite connection failed: {str(e)}")
            return False
    
    def connect_oracle(self):
        """Connect to Oracle database"""
        try:
            username = self.config['oracle']['username']
            password = self.config['oracle']['password']
            host = self.config['oracle']['host']
            port = self.config['oracle']['port']
            
            # Check if using SID or service_name
            if 'sid' in self.config['oracle']:
                sid = self.config['oracle']['sid']
                dsn = cx_Oracle.makedsn(host, port, sid=sid)
                logger.info(f"Connecting to Oracle database: {host}:{port}/{sid}")
            else:
                service_name = self.config['oracle']['service_name']
                dsn = cx_Oracle.makedsn(host, port, service_name=service_name)
                logger.info(f"Connecting to Oracle database: {host}:{port}/{service_name}")
            
            self.oracle_conn = cx_Oracle.connect(username, password, dsn)
            logger.info("Oracle connection successful")
            return True
        except Exception as e:
            logger.error(f"Oracle connection failed: {str(e)}")
            return False
    
    def create_sync_log(self, user_id, sync_type='Manual'):
        """Create sync log entry in Oracle"""
        try:
            cursor = self.oracle_conn.cursor()
            sync_log_id_var = cursor.var(cx_Oracle.NUMBER)
            
            cursor.callproc('pkg_finance_crud.create_sync_log', [
                user_id,
                sync_type,
                sync_log_id_var
            ])
            
            self.sync_log_id = int(sync_log_id_var.getvalue())
            logger.info(f"Created sync log: {self.sync_log_id}")
            return True
        except Exception as e:
            logger.error(f"Failed to create sync log: {str(e)}")
            return False
    
    def complete_sync_log(self, status, error_message=None):
        """Complete sync log entry"""
        try:
            cursor = self.oracle_conn.cursor()
            cursor.callproc('pkg_finance_crud.complete_sync_log', [
                self.sync_log_id,
                self.records_synced,
                status,
                error_message
            ])
            logger.info(f"Completed sync log: {status}, Records: {self.records_synced}")
            return True
        except Exception as e:
            logger.error(f"Failed to complete sync log: {str(e)}")
            return False
    
    def sync_users(self):
        """Sync users from SQLite to Oracle"""
        try:
            sqlite_cursor = self.sqlite_conn.cursor()
            oracle_cursor = self.oracle_conn.cursor()
            
            # Get all users from SQLite
            sqlite_cursor.execute("""
                SELECT user_id, username, password_hash, email, full_name, created_at
                FROM user
            """)
            
            users = sqlite_cursor.fetchall()
            synced_count = 0
            
            for user in users:
                try:
                    # Check if user exists in Oracle
                    oracle_cursor.execute("""
                        SELECT user_id FROM finance_user WHERE user_id = :1
                    """, [user['user_id']])
                    
                    exists = oracle_cursor.fetchone()
                    
                    if not exists:
                        # Insert new user
                        oracle_cursor.execute("""
                            INSERT INTO finance_user (user_id, username, password_hash, email, full_name, created_at)
                            VALUES (:1, :2, :3, :4, :5, TO_TIMESTAMP(:6, 'YYYY-MM-DD HH24:MI:SS'))
                        """, [
                            user['user_id'],
                            user['username'],
                            user['password_hash'],
                            user['email'],
                            user['full_name'],
                            user['created_at']
                        ])
                        synced_count += 1
                        logger.info(f"Synced user: {user['username']}")
                    
                except Exception as e:
                    logger.warning(f"Failed to sync user {user['username']}: {str(e)}")
                    continue
            
            self.oracle_conn.commit()
            self.records_synced += synced_count
            logger.info(f"Users synced: {synced_count}")
            return synced_count
            
        except Exception as e:
            logger.error(f"User sync failed: {str(e)}")
            self.oracle_conn.rollback()
            return 0
    
    def sync_expenses(self):
        """Sync expenses from SQLite to Oracle"""
        try:
            sqlite_cursor = self.sqlite_conn.cursor()
            oracle_cursor = self.oracle_conn.cursor()
            
            # Get unsynced expenses from SQLite
            sqlite_cursor.execute("""
                SELECT expense_id, user_id, category_id, amount, expense_date,
                       description, payment_method, created_at, modified_at, is_deleted
                FROM expense
                WHERE is_synced = 0
            """)
            
            expenses = sqlite_cursor.fetchall()
            synced_count = 0
            
            for expense_row in expenses:
                try:
                    # Convert Row to dict for easier access
                    expense = dict(expense_row)
                    
                    # Check if expense already exists in Oracle
                    oracle_cursor.execute("""
                        SELECT expense_id FROM finance_expense WHERE expense_id = :1
                    """, [expense['expense_id']])
                    
                    exists = oracle_cursor.fetchone()
                    
                    if exists:
                        # Update existing expense (conflict resolution - last modified wins)
                        oracle_cursor.execute("""
                            UPDATE finance_expense
                            SET amount = :1, category_id = :2, expense_date = TO_DATE(:3, 'YYYY-MM-DD'),
                                description = :4, payment_method = :5, is_deleted = :6, 
                                modified_at = SYSTIMESTAMP, sync_timestamp = SYSTIMESTAMP
                            WHERE expense_id = :7
                        """, [
                            expense['amount'],
                            expense['category_id'],
                            expense['expense_date'],
                            expense['description'],
                            expense['payment_method'],
                            expense.get('is_deleted', 0),
                            expense['expense_id']
                        ])
                    else:
                        # Insert new expense
                        oracle_cursor.execute("""
                            INSERT INTO finance_expense 
                            (expense_id, user_id, category_id, amount, expense_date, 
                             description, payment_method, is_deleted, created_at, modified_at, sync_timestamp)
                            VALUES (:1, :2, :3, :4, TO_DATE(:5, 'YYYY-MM-DD'), 
                                    :6, :7, :8, TO_TIMESTAMP(:9, 'YYYY-MM-DD HH24:MI:SS'), 
                                    TO_TIMESTAMP(:10, 'YYYY-MM-DD HH24:MI:SS'), SYSTIMESTAMP)
                        """, [
                            expense['expense_id'],
                            expense['user_id'],
                            expense['category_id'],
                            expense['amount'],
                            expense['expense_date'],
                            expense['description'],
                            expense['payment_method'],
                            expense.get('is_deleted', 0),
                            expense['created_at'],
                            expense['modified_at']
                        ])
                    
                    # Mark as synced in SQLite
                    sqlite_cursor.execute("""
                        UPDATE expense 
                        SET is_synced = 1, sync_timestamp = datetime('now')
                        WHERE expense_id = ?
                    """, [expense['expense_id']])
                    
                    synced_count += 1
                    
                except Exception as e:
                    logger.warning(f"Failed to sync expense {expense['expense_id']}: {str(e)}")
                    continue
            
            self.oracle_conn.commit()
            self.sqlite_conn.commit()
            self.records_synced += synced_count
            logger.info(f"Expenses synced: {synced_count}")
            return synced_count
            
        except Exception as e:
            logger.error(f"Expense sync failed: {str(e)}")
            self.oracle_conn.rollback()
            self.sqlite_conn.rollback()
            return 0
    
    def sync_income(self):
        """Sync income records from SQLite to Oracle"""
        try:
            sqlite_cursor = self.sqlite_conn.cursor()
            oracle_cursor = self.oracle_conn.cursor()
            
            # Get unsynced income from SQLite
            sqlite_cursor.execute("""
                SELECT income_id, user_id, income_source, amount, income_date,
                       description, created_at, modified_at, is_deleted
                FROM income
                WHERE is_synced = 0
            """)
            
            incomes = sqlite_cursor.fetchall()
            synced_count = 0
            
            for income_row in incomes:
                try:
                    # Convert Row to dict for easier access
                    income = dict(income_row)
                    
                    # Check if income exists in Oracle
                    oracle_cursor.execute("""
                        SELECT income_id FROM finance_income WHERE income_id = :1
                    """, [income['income_id']])
                    
                    exists = oracle_cursor.fetchone()
                    
                    if exists:
                        # Update existing income
                        oracle_cursor.execute("""
                            UPDATE finance_income
                            SET amount = :1, income_source = :2, income_date = TO_DATE(:3, 'YYYY-MM-DD'),
                                description = :4, is_deleted = :5, modified_at = SYSTIMESTAMP, 
                                sync_timestamp = SYSTIMESTAMP
                            WHERE income_id = :6
                        """, [
                            income['amount'],
                            income['income_source'],
                            income['income_date'],
                            income['description'],
                            income.get('is_deleted', 0),
                            income['income_id']
                        ])
                    else:
                        # Insert new income
                        oracle_cursor.execute("""
                            INSERT INTO finance_income 
                            (income_id, user_id, income_source, amount, income_date, 
                             description, is_deleted, created_at, modified_at, sync_timestamp)
                            VALUES (:1, :2, :3, :4, TO_DATE(:5, 'YYYY-MM-DD'), 
                                    :6, :7, TO_TIMESTAMP(:8, 'YYYY-MM-DD HH24:MI:SS'), 
                                    TO_TIMESTAMP(:9, 'YYYY-MM-DD HH24:MI:SS'), SYSTIMESTAMP)
                        """, [
                            income['income_id'],
                            income['user_id'],
                            income['income_source'],
                            income['amount'],
                            income['income_date'],
                            income['description'],
                            income.get('is_deleted', 0),
                            income['created_at'],
                            income['modified_at']
                        ])
                    
                    # Mark as synced in SQLite
                    sqlite_cursor.execute("""
                        UPDATE income 
                        SET is_synced = 1, sync_timestamp = datetime('now')
                        WHERE income_id = ?
                    """, [income['income_id']])
                    
                    synced_count += 1
                    
                except Exception as e:
                    logger.warning(f"Failed to sync income {income['income_id']}: {str(e)}")
                    continue
            
            self.oracle_conn.commit()
            self.sqlite_conn.commit()
            self.records_synced += synced_count
            logger.info(f"Income records synced: {synced_count}")
            return synced_count
            
        except Exception as e:
            logger.error(f"Income sync failed: {str(e)}")
            self.oracle_conn.rollback()
            self.sqlite_conn.rollback()
            return 0
    
    def sync_budgets(self):
        """Sync budgets from SQLite to Oracle"""
        try:
            sqlite_cursor = self.sqlite_conn.cursor()
            oracle_cursor = self.oracle_conn.cursor()
            
            # Get unsynced budgets from SQLite
            sqlite_cursor.execute("""
                SELECT budget_id, user_id, category_id, budget_amount, 
                       start_date, end_date, is_active, created_at, modified_at, is_deleted
                FROM budget
                WHERE is_synced = 0
            """)
            
            budgets = sqlite_cursor.fetchall()
            synced_count = 0
            
            for budget_row in budgets:
                try:
                    # Convert Row to dict for easier access
                    budget = dict(budget_row)
                    
                    # Check if budget exists in Oracle
                    oracle_cursor.execute("""
                        SELECT budget_id FROM finance_budget WHERE budget_id = :1
                    """, [budget['budget_id']])
                    
                    exists = oracle_cursor.fetchone()
                    
                    if exists:
                        # Update existing budget
                        oracle_cursor.execute("""
                            UPDATE finance_budget
                            SET budget_amount = :1, start_date = TO_DATE(:2, 'YYYY-MM-DD'),
                                end_date = TO_DATE(:3, 'YYYY-MM-DD'), is_active = :4, is_deleted = :5,
                                modified_at = SYSTIMESTAMP
                            WHERE budget_id = :6
                        """, [
                            budget['budget_amount'],
                            budget['start_date'],
                            budget['end_date'],
                            budget['is_active'],
                            budget.get('is_deleted', 0),
                            budget['budget_id']
                        ])
                    else:
                        # Insert new budget
                        oracle_cursor.execute("""
                            INSERT INTO finance_budget 
                            (budget_id, user_id, category_id, budget_amount, start_date, end_date,
                             is_active, is_deleted, created_at, modified_at)
                            VALUES (:1, :2, :3, :4, TO_DATE(:5, 'YYYY-MM-DD'), TO_DATE(:6, 'YYYY-MM-DD'),
                                    :7, :8, TO_TIMESTAMP(:9, 'YYYY-MM-DD HH24:MI:SS'), 
                                    TO_TIMESTAMP(:10, 'YYYY-MM-DD HH24:MI:SS'))
                        """, [
                            budget['budget_id'],
                            budget['user_id'],
                            budget['category_id'],
                            budget['budget_amount'],
                            budget['start_date'],
                            budget['end_date'],
                            budget['is_active'],
                            budget.get('is_deleted', 0),
                            budget['created_at'],
                            budget['modified_at']
                        ])
                    
                    # Mark as synced in SQLite
                    sqlite_cursor.execute("""
                        UPDATE budget 
                        SET is_synced = 1
                        WHERE budget_id = ?
                    """, [budget['budget_id']])
                    
                    synced_count += 1
                    
                except Exception as e:
                    logger.warning(f"Failed to sync budget {budget['budget_id']}: {str(e)}")
                    continue
            
            self.oracle_conn.commit()
            self.sqlite_conn.commit()
            self.records_synced += synced_count
            logger.info(f"Budgets synced: {synced_count}")
            return synced_count
            
        except Exception as e:
            logger.error(f"Budget sync failed: {str(e)}")
            self.oracle_conn.rollback()
            self.sqlite_conn.rollback()
            return 0
    
    def sync_savings_goals(self):
        """Sync savings goals from SQLite to Oracle"""
        try:
            sqlite_cursor = self.sqlite_conn.cursor()
            oracle_cursor = self.oracle_conn.cursor()
            
            # Get unsynced goals from SQLite
            sqlite_cursor.execute("""
                SELECT goal_id, user_id, goal_name, target_amount, current_amount,
                       start_date, deadline, priority, status, created_at, modified_at, is_deleted
                FROM savings_goal
                WHERE is_synced = 0
            """)
            
            goals = sqlite_cursor.fetchall()
            synced_count = 0
            
            for goal_row in goals:
                try:
                    # Convert Row to dict for easier access
                    goal = dict(goal_row)
                    
                    # Check if goal exists in Oracle
                    oracle_cursor.execute("""
                        SELECT goal_id FROM finance_savings_goal WHERE goal_id = :1
                    """, [goal['goal_id']])
                    
                    exists = oracle_cursor.fetchone()
                    
                    if exists:
                        # Update existing goal
                        oracle_cursor.execute("""
                            UPDATE finance_savings_goal
                            SET goal_name = :1, target_amount = :2, current_amount = :3,
                                deadline = TO_DATE(:4, 'YYYY-MM-DD'), priority = :5, status = :6,
                                is_deleted = :7, modified_at = SYSTIMESTAMP
                            WHERE goal_id = :8
                        """, [
                            goal['goal_name'],
                            goal['target_amount'],
                            goal['current_amount'],
                            goal['deadline'],
                            goal['priority'],
                            goal['status'],
                            goal.get('is_deleted', 0),
                            goal['goal_id']
                        ])
                    else:
                        # Insert new goal
                        oracle_cursor.execute("""
                            INSERT INTO finance_savings_goal 
                            (goal_id, user_id, goal_name, target_amount, current_amount,
                             start_date, deadline, priority, status, is_deleted, created_at, modified_at)
                            VALUES (:1, :2, :3, :4, :5, TO_DATE(:6, 'YYYY-MM-DD'), 
                                    TO_DATE(:7, 'YYYY-MM-DD'), :8, :9, :10,
                                    TO_TIMESTAMP(:11, 'YYYY-MM-DD HH24:MI:SS'), 
                                    TO_TIMESTAMP(:12, 'YYYY-MM-DD HH24:MI:SS'))
                        """, [
                            goal['goal_id'],
                            goal['user_id'],
                            goal['goal_name'],
                            goal['target_amount'],
                            goal['current_amount'],
                            goal['start_date'],
                            goal['deadline'],
                            goal['priority'],
                            goal['status'],
                            goal.get('is_deleted', 0),
                            goal['created_at'],
                            goal['modified_at']
                        ])
                    
                    # Mark as synced in SQLite
                    sqlite_cursor.execute("""
                        UPDATE savings_goal 
                        SET is_synced = 1
                        WHERE goal_id = ?
                    """, [goal['goal_id']])
                    
                    synced_count += 1
                    
                except Exception as e:
                    logger.warning(f"Failed to sync goal {goal['goal_id']}: {str(e)}")
                    continue
            
            self.oracle_conn.commit()
            self.sqlite_conn.commit()
            self.records_synced += synced_count
            logger.info(f"Savings goals synced: {synced_count}")
            return synced_count
            
        except Exception as e:
            logger.error(f"Savings goal sync failed: {str(e)}")
            self.oracle_conn.rollback()
            self.sqlite_conn.rollback()
            return 0
    
    def sync_all(self, user_id, sync_type='Manual'):
        """Perform complete synchronization"""
        logger.info("=" * 60)
        logger.info("Starting synchronization process...")
        logger.info("=" * 60)
        
        start_time = datetime.now()
        
        # Connect to databases
        if not self.connect_sqlite():
            return False
        
        if not self.connect_oracle():
            return False
        
        try:
            # IMPORTANT: Sync users FIRST (before creating sync log)
            # because sync_log has FK to user table
            logger.info("Step 1: Syncing users...")
            self.sync_users()
            
            # Now create sync log (user exists in Oracle)
            if not self.create_sync_log(user_id, sync_type):
                logger.warning("Failed to create sync log, but continuing...")
            
            # Sync all other entities
            logger.info("Step 2: Syncing expenses...")
            self.sync_expenses()
            logger.info("Step 3: Syncing income...")
            self.sync_income()
            logger.info("Step 4: Syncing budgets...")
            self.sync_budgets()
            logger.info("Step 5: Syncing savings goals...")
            self.sync_savings_goals()
            
            # Complete sync log with success
            self.complete_sync_log('Success')
            
            end_time = datetime.now()
            duration = (end_time - start_time).total_seconds()
            
            logger.info("=" * 60)
            logger.info(f"Synchronization completed successfully!")
            logger.info(f"Total records synced: {self.records_synced}")
            logger.info(f"Duration: {duration:.2f} seconds")
            logger.info("=" * 60)
            
            return True
            
        except Exception as e:
            logger.error(f"Synchronization failed: {str(e)}")
            self.complete_sync_log('Failed', str(e))
            return False
            
        finally:
            # Close connections
            if self.sqlite_conn:
                self.sqlite_conn.close()
                logger.info("SQLite connection closed")
            
            if self.oracle_conn:
                self.oracle_conn.close()
                logger.info("Oracle connection closed")
    
    def close(self):
        """Close all database connections"""
        if self.sqlite_conn:
            self.sqlite_conn.close()
        if self.oracle_conn:
            self.oracle_conn.close()


def main():
    """Main execution function"""
    print("\n" + "=" * 60)
    print("Personal Finance Management System - Database Synchronization")
    print("=" * 60 + "\n")
    
    # Get user ID for synchronization
    try:
        user_id = int(input("Enter user ID to synchronize (default: 1): ") or "1")
    except ValueError:
        print("Invalid user ID. Using default: 1")
        user_id = 1
    
    sync_type = input("Sync type [Manual/Automatic] (default: Manual): ") or "Manual"
    
    # Perform synchronization
    sync = DatabaseSync()
    success = sync.sync_all(user_id, sync_type)
    
    if success:
        print("\n✓ Synchronization completed successfully!")
        return 0
    else:
        print("\n✗ Synchronization failed. Check sync_log.txt for details.")
        return 1


if __name__ == "__main__":
    exit(main())
