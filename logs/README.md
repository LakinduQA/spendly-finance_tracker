# Log Files

This folder contains application log files.

## Files

### sync_log.txt
Main synchronization log from root directory.

### sync_log_webapp.txt
Synchronization log from webapp directory.

## Log Format
Logs contain:
- Timestamp of sync operations
- User sync status
- Error messages (if any)
- Success confirmations

## Maintenance
Logs can be cleared periodically to save space:
```powershell
Remove-Item D:\DM2_CW\logs\*.txt
```

## Rotation
Consider implementing log rotation if files grow too large (>10MB).
