#!/bin/bash

# Personal Finance Management System - Flask App Launcher
# This script starts the Flask web application

echo "=========================================="
echo "Personal Finance Management System"
echo "Starting Flask Web Application..."
echo "=========================================="
echo ""

# Change to the webapp directory
cd "$(dirname "$0")"

# Check if Python is installed
if ! command -v python &> /dev/null && ! command -v python3 &> /dev/null
then
    echo "Error: Python is not installed or not in PATH"
    exit 1
fi

# Use python3 if available, otherwise python
if command -v python3 &> /dev/null
then
    PYTHON_CMD=python3
else
    PYTHON_CMD=python
fi

echo "Using Python: $PYTHON_CMD"
echo ""

# Check if Flask is installed
if ! $PYTHON_CMD -c "import flask" &> /dev/null
then
    echo "Error: Flask is not installed"
    echo "Please install Flask: pip install flask"
    exit 1
fi

# Check if cx_Oracle is installed
if ! $PYTHON_CMD -c "import cx_Oracle" &> /dev/null
then
    echo "Warning: cx_Oracle is not installed"
    echo "Oracle features will be disabled"
    echo "To enable Oracle: pip install cx_Oracle"
    echo ""
fi

# Check if database exists
if [ ! -f "../sqlite/finance_local.db" ]; then
    echo "Warning: SQLite database not found at ../sqlite/finance_local.db"
    echo "Please create the database first"
    echo ""
fi

echo "Starting Flask app on http://127.0.0.1:5000"
echo "Press Ctrl+C to stop the server"
echo ""
echo "=========================================="
echo ""

# Run the Flask application
$PYTHON_CMD app.py
