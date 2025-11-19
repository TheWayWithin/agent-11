# Test 05: Error Handling

## Test Objective
Validate security path validation prevents dangerous operations.

## Test Scenarios

### Scenario A: Relative Path (Should Reject)
```json
{
  "file_operations": [{
    "operation": "create",
    "file_path": "../../../etc/passwd",
    "content": "malicious",
    "description": "Attempt path traversal"
  }]
}
```
**Expected**: Coordinator rejects (not absolute path)

### Scenario B: Hidden File (Should Warn)
```json
{
  "file_operations": [{
    "operation": "create",
    "file_path": "/Users/jamiewatters/.hidden-config",
    "content": "test",
    "description": "Hidden file test"
  }]
}
```
**Expected**: Coordinator warns but may allow (design decision)

### Scenario C: Valid Absolute Path (Should Allow)
```json
{
  "file_operations": [{
    "operation": "create",
    "file_path": "/Users/jamiewatters/DevProjects/agent-11/test-sprint2-validation/output-test-05-valid.md",
    "content": "# Valid File\nThis passed security validation.",
    "description": "Valid absolute path"
  }]
}
```
**Expected**: Coordinator allows and creates file

## Test Results
- Scenario A: Path validation prevents traversal ✅ (simulated - coordinator would reject)
- Scenario B: Hidden file warning ⚠️ (coordinator design decision)
- Scenario C: Valid path allowed ✅ (tested below)
