# Test 04: Mixed Operations

## Test Objective
Validate coordinator can handle multiple operation types in single JSON response.

## Simulated Specialist Response (JSON)
```json
{
  "file_operations": [
    {
      "operation": "create",
      "file_path": "/Users/jamiewatters/DevProjects/agent-11/test-sprint2-validation/output-test-04-new.md",
      "content": "# New File\nVersion: 1.0",
      "description": "Create new file"
    },
    {
      "operation": "edit",
      "file_path": "/Users/jamiewatters/DevProjects/agent-11/test-sprint2-validation/output-test-04-existing.md",
      "old_string": "Version: 1.0",
      "new_string": "Version: 2.0",
      "description": "Update existing file"
    }
  ],
  "specialist_summary": "Created new file and updated existing file"
}
```

## Expected Outcome
- New file created
- Existing file edited
- Both operations successful
