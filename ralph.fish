#!/usr/bin/env fish

# Handle init subcommand
if test (count $argv) -gt 0; and test $argv[1] = "init"
    # Create plan.md if not exists
    if not test -f plan.md
        echo "\
## Project Name

## 1. Problem & Motivation
- **Context**: Why are we doing this?
- User Pain Points

## 2. Success Criteria & End State
- What does success look like?
- Key User Stories / Workflows

## 3. Scope, Constraints & Risks
- In Scope / Out of Scope
- Technical Constraints (Performance, Security, etc.)
- Risks & Mitigation Strategies

## 4. High Level Implementation Strategy
- Architecture & Component Overview
- Key Technical Decisions
- Data Flow / System Diagrams (Mermaid if applicable)

## 5. Implementation Roadmap (Milestones)

### Phase 1: [Milestone Name]
- **Goal**: [Brief description]
- Key Deliverables:
  - [ ] **[Feature / Component Name]**: [Brief but clear description of the requirement or functionality. What does this achieve?]
  - [ ] **[Feature / Component Name]**: [Description...]

### Phase 2: [Milestone Name]
..." > plan.md
        echo "Created plan.md"
    else
        echo "plan.md already exists, skipping"
    end

    # Create progress.txt if not exists
    if not test -f progress.txt
        echo "\
Project initialized with Ralph workflow.

- Created `plan.md` - project plan and tasks
- Created `progress.txt` - progress tracking log

Next: Begin working on first task.

---" > progress.txt
        echo "Created progress.txt"
    else
        echo "progress.txt already exists, skipping"
    end

    # Create prompt.md if not exists
    if not test -f prompt.md
        echo "\
0. Read plan.md and progress.txt to understand the state of the project.
1. Find the highest-priority task to work on (not necessarily first in list).
2. Work ONLY on that single task until complete.
3. After completing a task, reread the whole file and review.
4. Run type checks, tests, and lint (if available).
5. Update plan.md to check off completed items with [x].
6. Append to progress.txt:
   - Tasks completed in this session
   - Decisions made and why
   - Blockers encountered
   - Files changed
7. Update AGENTS.md if fundamental changes were made to the codebase
8. Make a git commit for that task.
ONLY WORK ON A SINGLE TASK. YOU ARE DONE AFTER THAT SINGLE TASK IS COMPLETE.
If plan.md is fully complete (all items checked), output <promise>COMPLETE</promise>." > prompt.md
        echo "Created prompt.md"
    else
        echo "prompt.md already exists, skipping"
    end

    exit 0
end

# Handle clear subcommand
if test (count $argv) -gt 0; and test $argv[1] = "clear"
    set files_deleted 0
    
    if test -f plan.md
        rm plan.md
        echo "Deleted plan.md"
        set files_deleted (math $files_deleted + 1)
    end
    
    if test -f progress.txt
        rm progress.txt
        echo "Deleted progress.txt"
        set files_deleted (math $files_deleted + 1)
    end
    
    if test -f prompt.md
        rm prompt.md
        echo "Deleted prompt.md"
        set files_deleted (math $files_deleted + 1)
    end
    
    if test $files_deleted -eq 0
        echo "No ralph files to delete"
    else
        echo "Deleted $files_deleted file(s)"
    end
    
    exit 0
end

# Defaults
set iterations 10
set delay 10

# Parse arguments
argparse 'h/help' 'i/iteration=' 'd/delay=' 'once' -- $argv
or exit 1

if set -q _flag_help
    echo "Usage: ralph [OPTIONS]"
    echo "       ralph init"
    echo ""
    echo "Run AI coding agent in iterative loops to complete a plan."
    echo ""
    echo "Commands:"
    echo "  init               Initialize plan.md, progress.txt, and prompt.md in current directory"
    echo "  clear              Remove all ralph files (plan.md, progress.txt, prompt.md)"
    echo ""
    echo "Options:"
    echo "  -i, --iteration N  Number of iterations to run (default: 10)"
    echo "      --once         Run exactly 1 iteration (overrides -i)"
    echo "  -d, --delay N      Delay between iterations in seconds (default: 10)"
    echo "      --help         Show this help message"
    exit 0
end

if set -q _flag_iteration
    set iterations $_flag_iteration
end

if set -q _flag_once
    set iterations 1
end

if set -q _flag_delay
    set delay $_flag_delay
end

# Check required files exist
if not test -f plan.md
    echo "Error: plan.md not found. Run 'ralph init' to create it."
    exit 1
end

if not test -f progress.txt
    echo "Error: progress.txt not found. Run 'ralph init' to create it."
    exit 1
end

if not test -f prompt.md
    echo "Error: prompt.md not found. Run 'ralph init' to create it."
    exit 1
end

# Main loop
for i in (seq 1 $iterations)
    echo "=== Ralph iteration $i of $iterations ==="
    echo "Started at "(date '+%Y-%m-%d %H:%M:%S')
    echo ""

    set prompt (cat prompt.md)
    set result (opencode run "$prompt")

    # Exit on failure
    or exit 1

    echo $result

    # Check for completion signal
    if string match -q -- '*<promise>COMPLETE</promise>*' $result
        echo "Plan complete after $i iterations."
        exit 0
    end

    # Delay between iterations (not after last)
    if test $i -lt $iterations
        echo ""
        echo "Waiting $delay seconds before next iteration..."
        sleep $delay
    end
end

echo "Completed $iterations iterations."
