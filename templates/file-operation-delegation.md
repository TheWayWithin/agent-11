# File Operation Delegation Template

**Purpose**: Ready-to-use templates for delegating file operations to specialists with proper JSON output format.

**Usage**: Copy-paste these templates into Task tool prompts when delegating file creation, editing, or deletion operations.

---

## Template: File Creation Delegation

```
Task(
  subagent_type="[developer|architect|documenter|etc.]",
  prompt="First read agent-context.md and handoff-notes.md for mission context.

  [Describe what needs to be created and why]

  **REQUIRED OUTPUT FORMAT**:
  Provide file_operations as structured JSON output.

  {
    \"file_operations\": [
      {
        \"operation\": \"create\",
        \"file_path\": \"/absolute/path/to/file.ts\",
        \"content\": \"complete file content here\",
        \"description\": \"what this file does\"
      }
    ]
  }

  **CRITICAL REQUIREMENTS**:
  - Use ABSOLUTE file paths (starting with /)
  - Provide COMPLETE content (no placeholders like '...rest of code')
  - DO NOT attempt to create files directly
  - DO NOT use Write/Edit tools
  - Provide specifications for coordinator to execute

  Update handoff-notes.md with your design decisions."
)
```

---

## Template: File Edit Delegation

```
Task(
  subagent_type="[developer|architect|documenter|etc.]",
  prompt="First read agent-context.md and handoff-notes.md for mission context.

  [Describe what needs to be changed and why]

  **REQUIRED OUTPUT FORMAT**:
  Provide file_operations as structured JSON output.

  {
    \"file_operations\": [
      {
        \"operation\": \"edit\",
        \"file_path\": \"/absolute/path/to/file.ts\",
        \"old_string\": \"exact text to replace (copy from existing file)\",
        \"new_string\": \"exact replacement text\",
        \"description\": \"what this change accomplishes\"
      }
    ]
  }

  **CRITICAL REQUIREMENTS**:
  - Read the file first to get EXACT old_string
  - old_string must be unique in the file
  - Use ABSOLUTE file paths (starting with /)
  - DO NOT attempt to modify files directly
  - DO NOT use Write/Edit tools
  - Provide specifications for coordinator to execute

  Update handoff-notes.md with your design decisions."
)
```

---

## Template: Multiple File Operations

```
Task(
  subagent_type="[developer|architect|documenter|etc.]",
  prompt="First read agent-context.md and handoff-notes.md for mission context.

  [Describe the overall task requiring multiple files]

  **REQUIRED OUTPUT FORMAT**:
  Provide file_operations as structured JSON output.

  {
    \"file_operations\": [
      {
        \"operation\": \"create\",
        \"file_path\": \"/absolute/path/to/file1.ts\",
        \"content\": \"complete file 1 content\",
        \"description\": \"file 1 purpose\"
      },
      {
        \"operation\": \"create\",
        \"file_path\": \"/absolute/path/to/file2.ts\",
        \"content\": \"complete file 2 content\",
        \"description\": \"file 2 purpose\"
      },
      {
        \"operation\": \"edit\",
        \"file_path\": \"/absolute/path/to/existing.ts\",
        \"old_string\": \"text to replace\",
        \"new_string\": \"replacement text\",
        \"description\": \"why this change is needed\"
      }
    ]
  }

  **CRITICAL REQUIREMENTS**:
  - Use ABSOLUTE file paths (starting with /)
  - Provide COMPLETE content for each file
  - Order operations logically (dependencies first)
  - DO NOT attempt to create/modify files directly
  - DO NOT use Write/Edit tools
  - Provide specifications for coordinator to execute

  Update handoff-notes.md with your design decisions."
)
```

---

## Template: File Deletion (Use Sparingly)

```
Task(
  subagent_type="[developer|architect|etc.]",
  prompt="First read agent-context.md and handoff-notes.md for mission context.

  [Explain why deletion is needed]

  **REQUIRED OUTPUT FORMAT**:
  Provide file_operations as structured JSON output.

  {
    \"file_operations\": [
      {
        \"operation\": \"delete\",
        \"file_path\": \"/absolute/path/to/file.ts\",
        \"description\": \"why this file should be deleted\",
        \"safety_check\": \"confirmed no dependencies\"
      }
    ]
  }

  **CRITICAL REQUIREMENTS**:
  - Verify file has no dependencies before deletion
  - Include safety_check confirmation
  - Use ABSOLUTE file paths
  - DO NOT attempt to delete files directly
  - Provide specifications for coordinator to execute

  Update handoff-notes.md with your rationale."
)
```

---

## Common Mistakes to Avoid

**❌ WRONG - Requesting direct file creation**:
```
Task(
  subagent_type="developer",
  prompt="Create auth.ts with JWT authentication logic"
)
```

**✅ RIGHT - Requesting JSON output**:
```
Task(
  subagent_type="developer",
  prompt="Design JWT authentication and provide file_operations JSON to create auth.ts.

  {\"file_operations\": [{\"operation\": \"create\", \"file_path\": \"...\", \"content\": \"...\"}]}

  DO NOT attempt to create files directly."
)
```

---

**❌ WRONG - Vague output expectations**:
```
Task(
  subagent_type="architect",
  prompt="Design the API architecture and document it"
)
```

**✅ RIGHT - Explicit JSON requirement**:
```
Task(
  subagent_type="architect",
  prompt="Design the API architecture and provide file_operations JSON for documentation.

  Include all file specifications with absolute paths and complete content.
  DO NOT create files. Provide JSON specifications for coordinator to execute."
)
```

---

## Verification Checklist (After Specialist Response)

Use this checklist after receiving a specialist response:

```
☐ Response contains file_operations JSON structure
☐ All file_path values are absolute paths (start with /)
☐ All content values are complete (no placeholders)
☐ JSON is valid and parseable
☐ No claims of "file created successfully" without JSON
☐ Ready to execute via Write/Edit tools
```

**If any check fails**: Re-delegate using templates above with explicit JSON requirement.

---

## Quick Reference Card

| Task Type | Key Prompt Addition |
|-----------|---------------------|
| Create file | `"Provide file_operations JSON with operation: 'create'"` |
| Edit file | `"Provide file_operations JSON with operation: 'edit', old_string, new_string"` |
| Multiple files | `"Provide file_operations array with all operations"` |
| Delete file | `"Provide file_operations JSON with operation: 'delete', safety_check"` |

**Always include**:
- `"DO NOT attempt to create files directly"`
- `"Provide specifications for coordinator to execute"`
- JSON schema example in prompt
