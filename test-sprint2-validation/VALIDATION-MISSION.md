# Validation Mission: Real-World Project Setup

## Mission Objective
Simulate real-world coordinator + specialist workflow to validate Sprint 2 architecture end-to-end.

## Scenario
Create a documentation project with:
- 10+ files across nested directories
- Multiple specialists (@architect, @documenter, @developer)
- Mixed operations (create, edit)
- No manual coordinator intervention

## Specialist Delegations

### Delegation 1: @architect creates project structure

**Coordinator delegates**: "Create architecture documentation structure"

**@architect responds** (simulated):
```json
{
  "file_operations": [
    {
      "operation": "create",
      "file_path": "/Users/jamiewatters/DevProjects/agent-11/test-sprint2-validation/project/README.md",
      "content": "# Documentation Project\n\nThis project validates Sprint 2 file persistence architecture.\n\n## Structure\n- `/docs` - Documentation files\n- `/examples` - Code examples\n- `/guides` - User guides\n",
      "description": "Create project README"
    },
    {
      "operation": "create",
      "file_path": "/Users/jamiewatters/DevProjects/agent-11/test-sprint2-validation/project/architecture.md",
      "content": "# Architecture\n\n## System Design\n- Coordinator-as-executor pattern\n- Structured JSON output\n- Automatic file operations\n",
      "description": "Create architecture document"
    },
    {
      "operation": "create",
      "file_path": "/Users/jamiewatters/DevProjects/agent-11/test-sprint2-validation/project/docs/overview.md",
      "content": "# Overview\n\nProject overview documentation.\n",
      "description": "Create overview doc"
    },
    {
      "operation": "create",
      "file_path": "/Users/jamiewatters/DevProjects/agent-11/test-sprint2-validation/project/docs/api-reference.md",
      "content": "# API Reference\n\nAPI documentation placeholder.\n",
      "description": "Create API reference"
    }
  ],
  "specialist_summary": "Created project structure with 4 foundational documents"
}
```

### Delegation 2: @documenter creates user guides

**Coordinator delegates**: "Create user guide documentation"

**@documenter responds** (simulated):
```json
{
  "file_operations": [
    {
      "operation": "create",
      "file_path": "/Users/jamiewatters/DevProjects/agent-11/test-sprint2-validation/project/guides/getting-started.md",
      "content": "# Getting Started\n\n## Quick Start\n1. Read the README\n2. Review architecture\n3. Follow examples\n",
      "description": "Create getting started guide"
    },
    {
      "operation": "create",
      "file_path": "/Users/jamiewatters/DevProjects/agent-11/test-sprint2-validation/project/guides/best-practices.md",
      "content": "# Best Practices\n\n## Recommended Patterns\n- Use structured JSON output\n- Let coordinator handle file operations\n- Verify all files created\n",
      "description": "Create best practices guide"
    },
    {
      "operation": "create",
      "file_path": "/Users/jamiewatters/DevProjects/agent-11/test-sprint2-validation/project/guides/troubleshooting.md",
      "content": "# Troubleshooting\n\n## Common Issues\n- Files not persisting: Check JSON format\n- Path errors: Use absolute paths\n",
      "description": "Create troubleshooting guide"
    }
  ],
  "specialist_summary": "Created 3 user guides"
}
```

### Delegation 3: @developer creates code examples

**Coordinator delegates**: "Create code examples"

**@developer responds** (simulated):
```json
{
  "file_operations": [
    {
      "operation": "create",
      "file_path": "/Users/jamiewatters/DevProjects/agent-11/test-sprint2-validation/project/examples/single-file.json",
      "content": "{\n  \"file_operations\": [{\n    \"operation\": \"create\",\n    \"file_path\": \"/path/to/file.md\",\n    \"content\": \"# Example\",\n    \"description\": \"Example file\"\n  }]\n}\n",
      "description": "Create single file example"
    },
    {
      "operation": "create",
      "file_path": "/Users/jamiewatters/DevProjects/agent-11/test-sprint2-validation/project/examples/multiple-files.json",
      "content": "{\n  \"file_operations\": [\n    {\"operation\": \"create\", \"file_path\": \"/path/file1.md\", \"content\": \"File 1\", \"description\": \"First\"},\n    {\"operation\": \"create\", \"file_path\": \"/path/file2.md\", \"content\": \"File 2\", \"description\": \"Second\"}\n  ]\n}\n",
      "description": "Create multiple files example"
    },
    {
      "operation": "create",
      "file_path": "/Users/jamiewatters/DevProjects/agent-11/test-sprint2-validation/project/examples/edit-example.json",
      "content": "{\n  \"file_operations\": [{\n    \"operation\": \"edit\",\n    \"file_path\": \"/path/to/file.md\",\n    \"old_string\": \"old\",\n    \"new_string\": \"new\",\n    \"description\": \"Update content\"\n  }]\n}\n",
      "description": "Create edit example"
    }
  ],
  "specialist_summary": "Created 3 JSON code examples"
}
```

### Delegation 4: Update README with completion status

**Coordinator delegates**: "Update README with project completion status"

**@architect responds** (simulated):
```json
{
  "file_operations": [
    {
      "operation": "edit",
      "file_path": "/Users/jamiewatters/DevProjects/agent-11/test-sprint2-validation/project/README.md",
      "old_string": "This project validates Sprint 2 file persistence architecture.",
      "new_string": "This project validates Sprint 2 file persistence architecture.\n\n✅ **Status**: Validation Complete - All files created successfully via structured output pattern.",
      "description": "Add completion status to README"
    }
  ],
  "specialist_summary": "Updated README with validation results"
}
```

## Expected Outcome
- Total files created: 11 files (10 creates + 1 edit)
- Nested directories: `/docs`, `/guides`, `/examples`
- All operations via structured JSON output
- Zero manual coordinator intervention
- 100% file persistence

## Execution Plan
1. Coordinator executes Delegation 1 operations (4 files)
2. Coordinator executes Delegation 2 operations (3 files)
3. Coordinator executes Delegation 3 operations (3 files)
4. Coordinator executes Delegation 4 operation (1 edit)
5. Verify all 11 files exist with correct content
