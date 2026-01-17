#!/usr/bin/env fish

# Handle init subcommand
if test (count $argv) -gt 0; and test $argv[1] = "init"
    # Create plan.md if not exists
    if not test -f plan.md
        echo "\
# Project Name

## High Level Overview
Brief description of what this project aims to accomplish.

## Tasks

### Task 1: Task Title
Brief description of what this task accomplishes.

#### Subtasks
- [ ] Subtask 1: Short description
- [ ] Subtask 2: Short description
- [ ] Subtask 3: Short description

#### Implementation Guide
Overview of the approach to complete this task.

- Step 1: High level first step
- Step 2: Second step
- Step 3: Third step

Reference files:
- \`src/file1.ts\` - description
- \`src/file2.py\` - description

#### Detailed Requirements
Overview of the functional and non-functional requirements.

- Requirement 1
- Requirement 2
- Requirement 3

### Task 2: Task Title
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
