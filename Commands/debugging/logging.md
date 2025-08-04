# Terraform Debug Logging and Troubleshooting

## Overview
Debug logging is essential for troubleshooting Terraform issues. This guide covers all logging options and debugging techniques.

## Environment Variables for Logging

### `TF_LOG`
**Purpose**: Set Terraform log level

**Levels**:
- `TRACE` - Most verbose, shows all operations
- `DEBUG` - Detailed debugging information
- `INFO` - General information messages
- `WARN` - Warning messages only
- `ERROR` - Error messages only

**Examples**:
```bash
# Enable debug logging
export TF_LOG=DEBUG
terraform plan

# Enable trace logging (most verbose)
export TF_LOG=TRACE
terraform apply

# Enable specific component logging
export TF_LOG=DEBUG
export TF_LOG_PROVIDER=TRACE
terraform plan

# Disable logging
unset TF_LOG
```

### `TF_LOG_PATH`
**Purpose**: Write logs to file instead of stderr

**Examples**:
```bash
# Log to file
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform.log
terraform plan

# Check log file
tail -f terraform.log

# Log with timestamp
export TF_LOG_PATH="terraform_$(date +%Y%m%d_%H%M%S).log"
terraform apply
```

### Provider-Specific Logging
```bash
# AWS Provider logging
export TF_LOG_PROVIDER=DEBUG
export AWS_SDK_LOAD_CONFIG=1

# Enable AWS SDK logging
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform.log
terraform plan

# Azure Provider logging
export TF_LOG_PROVIDER=DEBUG
export AZURE_CLIENT_DEBUG=true

# Google Cloud Provider logging
export TF_LOG_PROVIDER=DEBUG
export GOOGLE_CREDENTIALS_DEBUG=true
```

---

## Debugging Workflows

### Basic Debugging Workflow
```bash
# 1. Enable debug logging
export TF_LOG=DEBUG
export TF_LOG_PATH=debug.log

# 2. Run problematic command
terraform plan

# 3. Analyze logs
grep -i error debug.log
grep -i "http request" debug.log

# 4. Clean up
unset TF_LOG TF_LOG_PATH
```

### Advanced Debugging Workflow
```bash
# 1. Set comprehensive logging
export TF_LOG=TRACE
export TF_LOG_PROVIDER=TRACE
export TF_LOG_PATH=trace_$(date +%Y%m%d_%H%M%S).log

# 2. Run command with timing
time terraform plan

# 3. Analyze different aspects
echo "=== Errors ==="
grep -i error $TF_LOG_PATH

echo "=== API Calls ==="
grep -i "http request" $TF_LOG_PATH

echo "=== Provider Issues ==="
grep -i "provider" $TF_LOG_PATH

echo "=== State Operations ==="
grep -i "state" $TF_LOG_PATH
```

### Performance Debugging
```bash
# 1. Enable trace logging with timing
export TF_LOG=TRACE
export TF_LOG_PATH=perf.log

# 2. Run with timing
time terraform plan

# 3. Analyze performance
echo "=== Slow Operations ==="
grep -E "took [0-9]+\.[0-9]+s" perf.log | sort -k3 -nr

echo "=== API Call Times ==="
grep -E "HTTP.*took" perf.log

echo "=== Provider Plugin Times ==="
grep -E "plugin.*took" perf.log
```

---

## Log Analysis Techniques

### Filtering Logs
```bash
# Error analysis
grep -i "error\|failed\|exception" terraform.log

# API call analysis
grep -E "HTTP (GET|POST|PUT|DELETE)" terraform.log

# State operation analysis
grep -i "state\|lock\|unlock" terraform.log

# Provider plugin analysis
grep -i "plugin\|provider" terraform.log

# Resource operation analysis
grep -E "(Creating|Reading|Updating|Deleting).*resource" terraform.log
```

### Log Parsing Scripts
```bash
#!/bin/bash
# parse-terraform-logs.sh

LOG_FILE=${1:-terraform.log}

if [ ! -f "$LOG_FILE" ]; then
    echo "Log file $LOG_FILE not found"
    exit 1
fi

echo "=== Terraform Log Analysis ==="
echo "Log file: $LOG_FILE"
echo "Log size: $(wc -l < $LOG_FILE) lines"
echo

echo "=== Error Summary ==="
grep -i "error\|failed" "$LOG_FILE" | head -10

echo
echo "=== API Call Summary ==="
grep -c "HTTP GET" "$LOG_FILE" | xargs echo "GET requests:"
grep -c "HTTP POST" "$LOG_FILE" | xargs echo "POST requests:"
grep -c "HTTP PUT" "$LOG_FILE" | xargs echo "PUT requests:"
grep -c "HTTP DELETE" "$LOG_FILE" | xargs echo "DELETE requests:"

echo
echo "=== Resource Operations ==="
grep -c "Creating.*resource" "$LOG_FILE" | xargs echo "Resources created:"
grep -c "Reading.*resource" "$LOG_FILE" | xargs echo "Resources read:"
grep -c "Updating.*resource" "$LOG_FILE" | xargs echo "Resources updated:"
grep -c "Deleting.*resource" "$LOG_FILE" | xargs echo "Resources deleted:"

echo
echo "=== Slowest Operations ==="
grep -E "took [0-9]+\.[0-9]+s" "$LOG_FILE" | \
    sort -k3 -nr | head -5
```

### Real-time Log Monitoring
```bash
# Monitor logs in real-time
export TF_LOG=DEBUG
export TF_LOG_PATH=live.log

# In terminal 1: Run Terraform
terraform plan &

# In terminal 2: Monitor logs
tail -f live.log | grep --line-buffered -E "(ERROR|WARN|Creating|Deleting)"

# Advanced monitoring with colors
tail -f live.log | grep --line-buffered -E "(ERROR|WARN|Creating|Deleting)" | \
    sed 's/ERROR/\x1b[31mERROR\x1b[0m/g; s/WARN/\x1b[33mWARN\x1b[0m/g'
```

---

## Debugging Specific Issues

### Authentication Issues
```bash
# Enable AWS SDK debugging
export TF_LOG=DEBUG
export TF_LOG_PROVIDER=TRACE
export AWS_SDK_LOAD_CONFIG=1

# Run and check for auth errors
terraform plan 2>&1 | grep -i "auth\|credential\|permission"

# Check specific auth flow
grep -E "(credential|token|assume)" terraform.log
```

### Network Issues
```bash
# Enable network debugging
export TF_LOG=TRACE
export TF_LOG_PATH=network.log

# Run command
terraform plan

# Analyze network calls
echo "=== HTTP Requests ==="
grep -E "HTTP (GET|POST|PUT|DELETE)" network.log

echo "=== Network Errors ==="
grep -i "timeout\|connection\|network\|dns" network.log

echo "=== Retry Attempts ==="
grep -i "retry\|attempt" network.log
```

### State Issues
```bash
# Enable state debugging
export TF_LOG=DEBUG
export TF_LOG_PATH=state.log

# Run state operation
terraform plan

# Analyze state operations
echo "=== State Lock Operations ==="
grep -i "lock\|unlock" state.log

echo "=== State Read/Write ==="
grep -i "state.*read\|state.*write" state.log

echo "=== Backend Operations ==="
grep -i "backend" state.log
```

### Provider Plugin Issues
```bash
# Enable plugin debugging
export TF_LOG=TRACE
export TF_LOG_PATH=plugin.log

# Run command
terraform plan

# Analyze plugin operations
echo "=== Plugin Initialization ==="
grep -i "plugin.*start\|plugin.*init" plugin.log

echo "=== Plugin Communication ==="
grep -i "plugin.*request\|plugin.*response" plugin.log

echo "=== Plugin Errors ==="
grep -i "plugin.*error\|plugin.*failed" plugin.log
```

---

## Crash Analysis

### Crash Log Location
```bash
# Default crash log location
ls -la crash.log

# Find crash logs
find . -name "crash.*.log" -type f

# Check system crash logs (macOS)
ls -la ~/Library/Logs/DiagnosticReports/terraform*

# Check system crash logs (Linux)
ls -la /var/crash/terraform*
```

### Analyzing Crash Logs
```bash
# Basic crash analysis
if [ -f crash.log ]; then
    echo "=== Crash Log Found ==="
    echo "Crash time: $(head -1 crash.log)"
    echo
    echo "=== Stack Trace ==="
    grep -A 20 "panic:" crash.log
    echo
    echo "=== Go Routines ==="
    grep -c "goroutine" crash.log | xargs echo "Active goroutines:"
fi
```

### Crash Recovery
```bash
#!/bin/bash
# crash-recovery.sh

echo "=== Terraform Crash Recovery ==="

# 1. Check for crash logs
if ls crash.*.log 1> /dev/null 2>&1; then
    echo "Crash logs found:"
    ls -la crash.*.log
    
    # Backup crash logs
    mkdir -p crash_logs_backup
    mv crash.*.log crash_logs_backup/
    echo "Crash logs backed up to crash_logs_backup/"
fi

# 2. Check state lock
echo "Checking state lock..."
if terraform plan 2>&1 | grep -q "state lock"; then
    echo "State is locked - manual intervention needed"
    echo "Run: terraform force-unlock LOCK_ID"
else
    echo "State is not locked"
fi

# 3. Validate configuration
echo "Validating configuration..."
if terraform validate; then
    echo "Configuration is valid"
else
    echo "Configuration has errors - fix before proceeding"
    exit 1
fi

# 4. Try to refresh state
echo "Refreshing state..."
if terraform refresh; then
    echo "State refreshed successfully"
else
    echo "State refresh failed - check manually"
fi

echo "=== Recovery complete ==="
```

---

## Performance Debugging

### Timing Analysis
```bash
# Enable timing logs
export TF_LOG=TRACE
export TF_LOG_PATH=timing.log

# Run with time measurement
time terraform plan

# Analyze timing
echo "=== Operation Times ==="
grep -E "took [0-9]+\.[0-9]+s" timing.log | \
    awk '{print $NF, $0}' | sort -nr | head -10

echo "=== Provider Call Times ==="
grep -E "provider.*took" timing.log | \
    awk '{print $NF, $0}' | sort -nr | head -10
```

### Memory Usage Analysis
```bash
# Monitor memory during execution
#!/bin/bash
# memory-monitor.sh

PID_FILE="terraform.pid"

# Start Terraform in background
terraform plan &
echo $! > $PID_FILE

# Monitor memory usage
while kill -0 $(cat $PID_FILE) 2>/dev/null; do
    ps -p $(cat $PID_FILE) -o pid,vsz,rss,pcpu,pmem,comm
    sleep 5
done

rm $PID_FILE
```

### Resource Usage Monitoring
```bash
#!/bin/bash
# resource-monitor.sh

LOG_FILE="resource_usage.log"

echo "Starting resource monitoring..."
echo "Timestamp,CPU%,Memory(MB),Disk(MB)" > $LOG_FILE

# Start monitoring
while true; do
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    CPU=$(ps aux | grep terraform | grep -v grep | awk '{sum+=$3} END {print sum}')
    MEMORY=$(ps aux | grep terraform | grep -v grep | awk '{sum+=$6} END {print sum/1024}')
    DISK=$(du -sm .terraform 2>/dev/null | cut -f1)
    
    echo "$TIMESTAMP,$CPU,$MEMORY,$DISK" >> $LOG_FILE
    sleep 10
done
```

---

## Debugging Best Practices

### 1. Structured Logging
```bash
#!/bin/bash
# structured-debug.sh

OPERATION=$1
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
LOG_DIR="logs"
mkdir -p $LOG_DIR

export TF_LOG=DEBUG
export TF_LOG_PATH="$LOG_DIR/${OPERATION}_${TIMESTAMP}.log"

echo "Starting $OPERATION with logging to $TF_LOG_PATH"
terraform $OPERATION

echo "Operation complete. Log available at: $TF_LOG_PATH"
```

### 2. Log Rotation
```bash
#!/bin/bash
# log-rotation.sh

LOG_DIR="terraform_logs"
MAX_LOGS=10

mkdir -p $LOG_DIR

# Remove old logs
ls -t $LOG_DIR/terraform_*.log 2>/dev/null | tail -n +$((MAX_LOGS + 1)) | xargs rm -f

# Start new log
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
export TF_LOG=DEBUG
export TF_LOG_PATH="$LOG_DIR/terraform_${TIMESTAMP}.log"
```

### 3. Conditional Debugging
```bash
#!/bin/bash
# conditional-debug.sh

DEBUG_MODE=${DEBUG_MODE:-false}

if [ "$DEBUG_MODE" = "true" ]; then
    export TF_LOG=DEBUG
    export TF_LOG_PATH="debug_$(date +%Y%m%d_%H%M%S).log"
    echo "Debug mode enabled - logging to $TF_LOG_PATH"
fi

terraform "$@"

if [ "$DEBUG_MODE" = "true" ]; then
    echo "Debug log available at: $TF_LOG_PATH"
fi
```

---

## Quick Reference

| Environment Variable | Purpose | Example |
|---------------------|---------|---------|
| `TF_LOG` | Set log level | `export TF_LOG=DEBUG` |
| `TF_LOG_PATH` | Log to file | `export TF_LOG_PATH=terraform.log` |
| `TF_LOG_PROVIDER` | Provider logging | `export TF_LOG_PROVIDER=TRACE` |

| Log Level | Description | Use Case |
|-----------|-------------|----------|
| `TRACE` | Most verbose | Deep debugging |
| `DEBUG` | Detailed info | General debugging |
| `INFO` | General info | Normal operations |
| `WARN` | Warnings only | Issue monitoring |
| `ERROR` | Errors only | Error tracking |

| Common Grep Patterns | Purpose |
|---------------------|---------|
| `grep -i error` | Find errors |
| `grep "HTTP.*"` | Find API calls |
| `grep -i "took.*s"` | Find slow operations |
| `grep -i "state"` | Find state operations |