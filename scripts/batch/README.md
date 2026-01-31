# Batch Scripts

Windows batch scripts for managing the Spendly application.

## Scripts

| Script | Description |
|--------|-------------|
| `setup.bat` | Complete setup wizard - installs dependencies, configures the app, and launches it |
| `start.bat` | Starts the Flask web application |
| `stop.bat` | Stops all running Python processes |
| `restart.bat` | Restarts the application (stop + start) |
| `install.bat` | Quick install - only installs Python dependencies |

## Usage

### First Time Setup

```cmd
cd scripts\batch
setup.bat
```

This will:
1. Check Python installation
2. Install all dependencies
3. Verify project structure
4. Offer to populate sample data
5. Launch the application

### Daily Use

```cmd
# Start the app
scripts\batch\start.bat

# Stop the app
scripts\batch\stop.bat

# Restart the app
scripts\batch\restart.bat
```

## Requirements

- Windows OS
- Python 3.8 or higher installed
- Python added to PATH environment variable
