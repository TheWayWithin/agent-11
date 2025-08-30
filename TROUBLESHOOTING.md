# BOS-AI ↔ AGENT-11 Integration Troubleshooting Guide

**Version**: 1.0.0  
**Last Updated**: 2025-01-29  
**Status**: Production Ready

## Quick Reference

### Emergency Procedures

| Issue | Quick Fix | Details |
|-------|-----------|---------|
| Bundle validation fails | `./bridge validate --fix-common` | [Bundle Validation Issues](#bundle-validation-issues) |
| Handoff process hangs | `pkill bridge && ./bridge handoff --retry` | [Handoff Process Issues](#handoff-process-issues) |
| Reports not generating | `./bridge report --force-regenerate` | [Progress Reporting Issues](#progress-reporting-issues) |
| Integration bridge crashed | `./tools/maintenance/emergency-restart.sh` | [System Recovery](#system-recovery) |
| Complete system failure | `./tools/maintenance/emergency-rollback.sh` | [Emergency Rollback](#emergency-rollback) |

### Diagnostic Commands

```bash
# System health check
./integration-bridge/bridge status

# Detailed diagnostics
./integration-bridge/tools/maintenance/health-check.sh --detailed

# View recent logs
tail -n 50 ./integration-bridge/logs/integration.log

# Check configuration
./integration-bridge/tools/maintenance/validate-config.sh
```

## Common Issues and Solutions

### Bundle Validation Issues

#### Issue: "Schema validation failed"

**Symptoms:**
- Bundle validation returns errors about YAML frontmatter
- Error messages like "Invalid schema format" or "Missing required fields"
- Validation report shows multiple schema violations

**Diagnosis:**
```bash
# Check specific schema errors
./integration-bridge/bridge validate /path/to/bundle --verbose

# Validate individual document schemas
./integration-bridge/scripts/validation/validate-document-schema.sh \
  /path/to/bundle/core-requirements/prd.md \
  ./config/schemas/prd-schema.json
```

**Common Causes:**
1. **Malformed YAML frontmatter**: Incorrect indentation or syntax
2. **Missing required fields**: Schema requires fields not present in document
3. **Incorrect data types**: String provided where number expected, etc.
4. **Version mismatch**: Document schema version incompatible with validator

**Solutions:**

**Fix 1: Repair YAML Frontmatter**
```bash
# Check YAML syntax
yamllint /path/to/bundle/core-requirements/prd.md

# Common YAML issues and fixes:
# Wrong: version: 1.0.0 (missing quotes)
# Right: version: "1.0.0"

# Wrong: 
# status:draft
# Right:
# status: "draft"
```

**Fix 2: Add Missing Required Fields**
```yaml
# Example: PRD missing required fields
---
version: "1.0.0"              # Required
project_id: "proj_001"        # Required
created: "2025-01-29T10:00:00Z"  # Required
updated: "2025-01-29T10:00:00Z"  # Required
status: "approved"            # Required
priority: "high"              # Required
estimated_complexity: 7       # Required
target_completion: "2025-02-15" # Required
---
```

**Fix 3: Correct Data Types**
```yaml
# Wrong data types
estimated_complexity: "high"  # Should be number
target_completion: 2025-02-15  # Should be quoted string

# Correct data types  
estimated_complexity: 7       # Number 1-10
target_completion: "2025-02-15"  # ISO date string
```

**Fix 4: Update Schema Version**
```bash
# Check current schema version
grep "schema_version" ./integration-bridge/config/integration-settings.yaml

# Update document to match
# In document frontmatter:
schema_version: "2.0"  # Match integration-settings.yaml
```

#### Issue: "Content completeness check failed"

**Symptoms:**
- Validation passes schema but fails content requirements
- Missing required sections or insufficient content
- Word count below minimum thresholds

**Diagnosis:**
```bash
# Check content requirements
./integration-bridge/scripts/validation/check-completeness.sh \
  /path/to/bundle --detailed-report
```

**Solutions:**

**Fix 1: Add Missing Sections**
```markdown
# PRD must include these sections:
## Problem Statement
[Content describing the problem]

## Solution Overview  
[High-level solution description]

## Core Features
[Detailed feature descriptions with user stories]

## Technical Requirements
[Performance, security, integration requirements]

## Success Metrics
[Measurable outcomes and KPIs]
```

**Fix 2: Meet Content Requirements**
```yaml
# Check requirements in validation-rules.yaml
prd:
  min_word_count: 500    # Document must have at least 500 words
  required_sections: 5   # Must include all 5 required sections
  max_complexity_score: 10  # Complexity score must be 1-10
```

**Fix 3: Improve Content Quality**
```markdown
# Instead of: "Users need authentication"
# Write: "Users require secure authentication to protect personal data and comply with GDPR requirements. Authentication must support email/password and OAuth providers (Google, GitHub) with session management and password reset functionality."
```

#### Issue: "Cross-reference validation failed"

**Symptoms:**
- Broken internal links between documents
- References to non-existent sections or documents
- Circular dependencies detected

**Diagnosis:**
```bash
# Check cross-references
./integration-bridge/scripts/validation/cross-reference.sh \
  /path/to/bundle --show-broken-links
```

**Solutions:**

**Fix 1: Repair Broken Links**
```markdown
# Wrong: Link to non-existent section
See [User Stories](./prd.md#user-stories) for details

# Right: Link to existing section  
See [Core Features](./prd.md#core-features) for details
```

**Fix 2: Update File References**
```markdown
# Wrong: Reference to moved/renamed file
For brand details, see [Brand Guide](./brand.md)

# Right: Reference to correct file location
For brand details, see [Brand Guidelines](../design-specifications/brand-guidelines.md)
```

**Fix 3: Resolve Circular Dependencies**
```markdown
# Avoid: A references B, B references A, A references B
# PRD.md -> Context.md -> Vision.md -> PRD.md (circular)

# Better: Clear hierarchy
# Vision.md (top level)
# ↓
# PRD.md (references Vision)
# ↓  
# Context.md (references PRD and Vision, but not vice versa)
```

### Handoff Process Issues

#### Issue: "Handoff process hangs or fails"

**Symptoms:**
- Handoff command runs indefinitely without completion
- Process terminates with unclear error messages
- Bundle appears to transfer but AGENT-11 doesn't acknowledge

**Diagnosis:**
```bash
# Check handoff process status
ps aux | grep handoff

# Check system resources
df -h  # Disk space
free -m  # Memory usage

# Check permissions
ls -la /path/to/bos-output/
ls -la /path/to/agent11-projects/

# Review handoff logs
tail -f ./integration-bridge/logs/handoff.log
```

**Common Causes:**
1. **Insufficient disk space**: Target directory full
2. **Permission issues**: Cannot write to destination
3. **File locks**: Bundle files locked by another process
4. **Network issues**: If using network storage
5. **Corrupted bundle**: Bundle files damaged during creation

**Solutions:**

**Fix 1: Check Disk Space**
```bash
# Check available space
df -h /path/to/agent11-projects/

# Clean up if needed
./integration-bridge/tools/maintenance/cleanup-old-bundles.sh

# Free up space
sudo find /tmp -name "*integration*" -type d -mtime +7 -exec rm -rf {} \;
```

**Fix 2: Fix Permissions**
```bash
# Check current permissions
ls -la /path/to/agent11-projects/

# Fix permissions
chmod 755 /path/to/agent11-projects/
chown -R $USER:$USER /path/to/agent11-projects/

# Test write access
touch /path/to/agent11-projects/test-write.tmp
rm /path/to/agent11-projects/test-write.tmp
```

**Fix 3: Clear File Locks**
```bash
# Find processes using bundle files
lsof +D /path/to/bundle/

# Kill processes if safe to do so
pkill -f "bundle-name"

# Wait and retry handoff
sleep 5
./integration-bridge/bridge handoff --retry
```

**Fix 4: Verify Bundle Integrity**
```bash
# Check bundle completeness
find /path/to/bundle -name "*.md" -exec wc -l {} \;

# Verify all required files present
./integration-bridge/bridge validate /path/to/bundle --check-integrity

# Re-create bundle if corrupted
./integration-bridge/bridge create-bundle /path/to/bos-output --force
```

#### Issue: "AGENT-11 doesn't acknowledge handoff"

**Symptoms:**
- Bundle transferred but no acknowledgment generated
- Missing handoff-acknowledgment.md file
- AGENT-11 project not properly initialized

**Diagnosis:**
```bash
# Check if AGENT-11 project created
ls -la /path/to/agent11-project/

# Verify ideation directory
ls -la /path/to/agent11-project/ideation/

# Check AGENT-11 initialization
cat /path/to/agent11-project/CLAUDE.md
cat /path/to/agent11-project/progress.md
```

**Solutions:**

**Fix 1: Manual Acknowledgment Creation**
```bash
# Generate acknowledgment manually
./integration-bridge/scripts/workflows/create-handoff-acknowledgment.sh \
  /path/to/agent11-project/ideation/
```

**Fix 2: Re-initialize AGENT-11 Project**
```bash
# Re-run project initialization
./integration-bridge/scripts/workflows/initialize-tracking-files.sh \
  /path/to/agent11-project/

# Verify initialization
ls -la /path/to/agent11-project/
# Should see: CLAUDE.md, progress.md, status-reports/
```

**Fix 3: Complete Handoff Manually**
```bash
# Manual handoff completion
cd /path/to/agent11-project/
/coord dev-alignment

# Verify AGENT-11 recognizes ideation
cat ideation/handoff-acknowledgment.md
```

### Progress Reporting Issues

#### Issue: "Reports not generating automatically"

**Symptoms:**
- Expected weekly/milestone reports missing
- Generate report command fails silently
- Reports generated but empty or malformed

**Diagnosis:**
```bash
# Check report generation manually
./integration-bridge/bridge report /path/to/project weekly --debug

# Check git repository status
cd /path/to/project
git status
git log --oneline -10

# Verify project structure
ls -la project-plan.md progress.md status-reports/
```

**Common Causes:**
1. **Missing project files**: project-plan.md or progress.md missing
2. **Git repository issues**: No git history or corrupted repository
3. **Permission issues**: Cannot write to status-reports directory
4. **Template issues**: Report templates missing or corrupted

**Solutions:**

**Fix 1: Create Missing Project Files**
```bash
# Create basic project-plan.md if missing
cat > project-plan.md << 'EOF'
# Project Plan

## Tasks
- [ ] Initial setup
- [ ] Development phase 1
- [ ] Testing phase
- [ ] Deployment

## Timeline
Target completion: TBD
EOF

# Create basic progress.md if missing  
cat > progress.md << 'EOF'
# Progress Log

## Recent Updates
No updates logged yet.

## Issues and Resolutions
None reported.
EOF
```

**Fix 2: Fix Git Repository Issues**
```bash
# Initialize git if missing
cd /path/to/project
git init
git add .
git commit -m "Initial commit"

# Repair corrupted git repository
git fsck --full
git gc --prune=now
```

**Fix 3: Fix Permissions and Templates**
```bash
# Create status-reports directory structure
mkdir -p status-reports/{weekly,milestone,critical}
chmod 755 status-reports/

# Verify report templates exist
ls -la ./integration-bridge/templates/reports/
# Should see: weekly-status-template.md, milestone-report-template.md
```

**Fix 4: Test Report Generation**
```bash
# Generate test report
./integration-bridge/bridge report /path/to/project weekly \
  --output ./test-report.md --debug

# Check generated report
cat ./test-report.md

# If successful, set up automation
echo "0 17 * * 5 /path/to/integration-bridge/bridge report /path/to/project weekly" | crontab -
```

#### Issue: "Reports generated but contain no data"

**Symptoms:**
- Report files created but show "No data available"
- Metrics show zero values despite development activity
- Template variables not being replaced

**Diagnosis:**
```bash
# Check metrics collection
./integration-bridge/scripts/reporting/collect-metrics.sh /path/to/project --debug

# Verify git activity
cd /path/to/project
git log --since="1 week ago" --oneline
git diff --stat HEAD~5 HEAD

# Check task tracking
grep -c "^- \[x\]" project-plan.md  # Completed tasks
grep -c "^- \[ \]" project-plan.md  # Pending tasks
```

**Solutions:**

**Fix 1: Fix Task Tracking Format**
```markdown
# Wrong task format (not counted)
* [x] Completed task
- [X] Another task

# Right task format (counted correctly)
- [x] Completed task
- [ ] Pending task
- [~] In progress task
```

**Fix 2: Ensure Git Activity Tracking**
```bash
# Make sure git is tracking activity
cd /path/to/project
git add .
git commit -m "Progress update"

# Verify commits are being counted
git rev-list --count --since="1 week ago" HEAD
```

**Fix 3: Fix Template Variable Replacement**
```bash
# Check template processing
./integration-bridge/scripts/reporting/process-template.sh \
  ./templates/reports/weekly-status-template.md \
  ./test-output.md \
  --debug

# Common template variable issues:
# {{COMPLETION_PERCENTAGE}} not being replaced
# {{GIT_COMMITS_WEEK}} showing as 0

# Verify metrics are being calculated correctly
./integration-bridge/scripts/reporting/collect-project-metrics.sh \
  /path/to/project --verbose
```

### System Recovery

#### Emergency System Recovery

**When to Use:**
- Integration bridge completely unresponsive
- Multiple processes hanging or crashed
- System resources exhausted
- Corruption suspected in core files

**Recovery Process:**

**Step 1: Emergency Stop**
```bash
# Kill all integration bridge processes
pkill -f "integration-bridge"
pkill -f "bridge"
pkill -f "handoff"
pkill -f "validate"

# Wait for cleanup
sleep 10

# Check for remaining processes
ps aux | grep -E "(bridge|integration|handoff)"
```

**Step 2: System Cleanup**
```bash
# Clean up temporary files
rm -rf /tmp/integration-bridge-*
rm -rf /tmp/bundle-*
rm -rf /tmp/handoff-*

# Clear cache if present
rm -rf ./integration-bridge/cache/*

# Reset file locks
find ./integration-bridge -name "*.lock" -delete
```

**Step 3: Health Check and Restart**
```bash
# Check system health
./integration-bridge/tools/maintenance/health-check.sh --fix-issues

# Restart integration bridge
./integration-bridge/tools/maintenance/restart-bridge.sh

# Verify recovery
./integration-bridge/bridge status
```

**Step 4: Data Integrity Check**
```bash
# Verify configuration integrity
./integration-bridge/tools/maintenance/validate-config.sh --repair

# Check bundle integrity
find ./bos-ai/output -name "manifest.yaml" -exec \
  ./integration-bridge/bridge validate "$(dirname {})" \;

# Verify project integrity
find ./agent11-projects -name ".claude" -type d -exec \
  ./integration-bridge/tools/maintenance/verify-project.sh "$(dirname {})" \;
```

#### Emergency Rollback

**When to Use:**
- System recovery fails repeatedly
- Data corruption suspected
- Need to return to pre-integration state immediately
- Critical production issue

**Rollback Process:**

**Step 1: Immediate Rollback**
```bash
# Execute emergency rollback
./integration-bridge/tools/maintenance/emergency-rollback.sh --immediate

# This script:
# 1. Stops all integration processes
# 2. Disables integration bridge commands
# 3. Preserves current data
# 4. Provides instructions for restoration
```

**Step 2: Data Preservation**
```bash
# Create emergency backup before rollback
tar -czf emergency-backup-$(date +%s).tar.gz \
  integration-bridge/ \
  agent11-projects/ \
  bos-ai/output/

# Move to safe location
mv emergency-backup-*.tar.gz ../emergency-backups/
```

**Step 3: Restore Previous State**
```bash
# Restore from migration backups if available
if [[ -d migration-backups ]]; then
    ./tools/maintenance/restore-from-backup.sh migration-backups/
fi

# Or restore from emergency backup
./tools/maintenance/restore-emergency-backup.sh \
  ../emergency-backups/emergency-backup-*.tar.gz
```

### Performance Issues

#### Issue: "Validation taking too long"

**Symptoms:**
- Bundle validation takes >5 minutes
- System becomes unresponsive during validation
- High CPU/memory usage during validation

**Diagnosis:**
```bash
# Profile validation performance
time ./integration-bridge/bridge validate /path/to/bundle

# Check system resources during validation
top -p $(pgrep -f validate)

# Check bundle size
du -sh /path/to/bundle/
find /path/to/bundle -name "*.md" -exec wc -l {} \; | sort -n
```

**Solutions:**

**Fix 1: Enable Parallel Validation**
```yaml
# In config/integration-settings.yaml
performance:
  parallel_validation: true
  max_concurrent_jobs: 4  # Adjust based on CPU cores
```

**Fix 2: Optimize Bundle Size**
```bash
# Check for oversized files
find /path/to/bundle -size +1M -ls

# Compress large assets
find /path/to/bundle -name "*.png" -exec pngcrush {} {}.compressed \;

# Remove unnecessary files
find /path/to/bundle -name ".DS_Store" -delete
find /path/to/bundle -name "Thumbs.db" -delete
```

**Fix 3: Enable Validation Caching**
```yaml
# In config/integration-settings.yaml  
performance:
  cache_validation_results: true
  cache_directory: "./cache/validation"
```

**Fix 4: Tune Memory Settings**
```yaml
# In config/integration-settings.yaml
performance:
  memory_limit_mb: 1024    # Increase if needed
  timeout_seconds: 600     # Increase timeout
```

#### Issue: "Memory usage too high"

**Symptoms:**
- Integration bridge using excessive RAM
- System swapping or becoming sluggish
- Out of memory errors

**Diagnosis:**
```bash
# Monitor memory usage
ps aux | grep -E "(bridge|integration)" | sort -k4 -nr

# Check for memory leaks
valgrind --tool=memcheck ./integration-bridge/bridge validate /path/to/bundle

# System memory status
free -h
```

**Solutions:**

**Fix 1: Reduce Memory Limits**
```yaml
# In config/integration-settings.yaml
performance:
  memory_limit_mb: 256     # Reduce from default
  max_concurrent_jobs: 2   # Reduce parallelism
```

**Fix 2: Process Large Bundles in Chunks**
```bash
# Split large bundles for processing
./integration-bridge/tools/maintenance/split-bundle.sh \
  /path/to/large-bundle \
  --chunk-size 10MB

# Validate chunks separately
for chunk in /path/to/chunks/*; do
    ./integration-bridge/bridge validate "$chunk"
done
```

**Fix 3: Clear Caches Regularly**
```bash
# Set up automatic cache cleanup
echo "0 2 * * * /path/to/integration-bridge/tools/maintenance/cleanup-cache.sh" | crontab -

# Manual cache cleanup
rm -rf ./integration-bridge/cache/*
```

## Error Message Reference

### Validation Errors

| Error Code | Message | Cause | Solution |
|------------|---------|-------|----------|
| VAL-001 | "YAML frontmatter malformed" | Invalid YAML syntax | Fix YAML indentation and syntax |
| VAL-002 | "Required field missing: {field}" | Missing required metadata | Add missing field to frontmatter |
| VAL-003 | "Content below minimum threshold" | Document too short | Add more detailed content |
| VAL-004 | "Cross-reference broken: {link}" | Invalid internal link | Fix or remove broken link |
| VAL-005 | "Schema version mismatch" | Incompatible schema version | Update document or schema version |

### Handoff Errors

| Error Code | Message | Cause | Solution |
|------------|---------|-------|----------|
| HND-001 | "Bundle validation failed" | Bundle failed pre-handoff validation | Fix validation errors first |
| HND-002 | "Destination directory not writable" | Permission issue | Check and fix directory permissions |
| HND-003 | "Bundle transfer incomplete" | Disk space or network issue | Check resources and retry |
| HND-004 | "AGENT-11 initialization failed" | Project setup error | Check AGENT-11 compatibility |
| HND-005 | "Handoff timeout exceeded" | Process taking too long | Check system resources |

### Reporting Errors

| Error Code | Message | Cause | Solution |
|------------|---------|-------|----------|
| RPT-001 | "Project files not found" | Missing project-plan.md or progress.md | Create missing project files |
| RPT-002 | "Git repository not found" | No git initialization | Initialize git repository |
| RPT-003 | "Template processing failed" | Missing or corrupt templates | Restore template files |
| RPT-004 | "Metrics collection failed" | Cannot access project data | Check file permissions |
| RPT-005 | "Report generation timeout" | Processing taking too long | Reduce project size or increase timeout |

### System Errors

| Error Code | Message | Cause | Solution |
|------------|---------|-------|----------|
| SYS-001 | "Configuration file invalid" | Corrupt or missing config | Restore or recreate configuration |
| SYS-002 | "Dependency not found: {tool}" | Missing required tool | Install missing dependency |
| SYS-003 | "Insufficient disk space" | Storage full | Clean up disk space |
| SYS-004 | "Permission denied" | Access rights issue | Fix file/directory permissions |
| SYS-005 | "Integration bridge not found" | Installation issue | Reinstall integration bridge |

## Debug Mode and Logging

### Enable Debug Mode

```bash
# Set debug mode globally
export BRIDGE_DEBUG=1

# Enable debug for specific command
./integration-bridge/bridge validate /path/to/bundle --debug

# Enable verbose logging
./integration-bridge/bridge handoff /path/to/bundle /path/to/project --verbose
```

### Log Analysis

```bash
# View real-time logs
tail -f ./integration-bridge/logs/integration.log

# Search for specific errors
grep -i "error" ./integration-bridge/logs/integration.log
grep -i "failed" ./integration-bridge/logs/integration.log

# Analyze performance issues
grep "took.*seconds" ./integration-bridge/logs/integration.log

# Export logs for support
tar -czf integration-logs-$(date +%s).tar.gz ./integration-bridge/logs/
```

### Log Configuration

```yaml
# In config/integration-settings.yaml
logging:
  level: "DEBUG"           # Enable detailed logging
  file_enabled: true       # Log to file
  console_enabled: true    # Also log to console
  include_timestamps: true # Add timestamps
  include_performance: true # Log timing information
  max_log_size_mb: 100     # Rotate at 100MB
  max_log_files: 10        # Keep 10 old log files
```

## Getting Help

### Self-Help Resources

1. **Health Check Tool**
   ```bash
   ./integration-bridge/tools/maintenance/health-check.sh --detailed
   ```

2. **Configuration Validator**
   ```bash
   ./integration-bridge/tools/maintenance/validate-config.sh
   ```

3. **System Diagnostics**
   ```bash
   ./integration-bridge/tools/maintenance/system-diagnostics.sh
   ```

### Support Information Collection

Before seeking support, collect this information:

```bash
# Generate support bundle
./integration-bridge/tools/maintenance/generate-support-bundle.sh

# This creates a compressed file containing:
# - System configuration
# - Recent log files (sanitized)
# - Error messages and stack traces
# - Performance metrics
# - Environment information
```

### Contact Information

- **Documentation**: Check [INTEGRATION-GUIDE.md](./INTEGRATION-GUIDE.md) and [WORKFLOWS.md](./WORKFLOWS.md)
- **Configuration**: Review [INTEGRATION-STANDARDS.md](./INTEGRATION-STANDARDS.md)
- **Installation Issues**: See [DEPLOYMENT.md](./DEPLOYMENT.md)
- **Advanced Issues**: Review [BOS-AI-AGENT-11-INTEGRATION-ARCHITECTURE.md](./BOS-AI-AGENT-11-INTEGRATION-ARCHITECTURE.md)

This troubleshooting guide covers the most common issues encountered in BOS-AI ↔ AGENT-11 integration. For issues not covered here, use the diagnostic tools to gather information and follow the systematic approach outlined in each section.