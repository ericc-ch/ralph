#!/usr/bin/env fish

# Handle init subcommand
if test (count $argv) -gt 0; and test $argv[1] = "init"
    # Create plan.md if not exists
    if not test -f plan.md
        echo "\
- [ ] This is an example of a task
  - Step one of the task
  - Step two of the task
  - Once all steps are done, the task is complete" > plan.md
        echo "Created plan.md"
    else
        echo "plan.md already exists, skipping"
    end

    # Create progress.txt if not exists
    if not test -f progress.txt
        echo "\
## "(date '+%Y-%m-%dT%H:%M:%S')"

Project initialized with Ralph workflow.

- Created `plan.md` - project plan and tasks
- Created `progress.txt` - progress tracking log

Next: Begin working on first task.

---" > progress.txt
        echo "Created progress.txt"
    else
        echo "progress.txt already exists, skipping"
    end

    exit 0
end

# Defaults
set iterations 10

# Parse arguments
argparse 'h/help' 'i/iteration=' 'once' -- $argv
or exit 1

if set -q _flag_help
    echo "Usage: ralph [OPTIONS]"
    echo "       ralph init"
    echo ""
    echo "Run AI coding agent in iterative loops to complete a plan."
    echo ""
    echo "Commands:"
    echo "  init               Initialize plan.md and progress.txt in current directory"
    echo ""
    echo "Options:"
    echo "  -i, --iteration N  Number of iterations to run (default: 10)"
    echo "      --once         Run exactly 1 iteration (overrides -i)"
    echo "  -h, --help         Show this help message"
    exit 0
end

if set -q _flag_iteration
    set iterations $_flag_iteration
end

if set -q _flag_once
    set iterations 1
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

# Main loop
for i in (seq 1 $iterations)
    echo "=== Ralph iteration $i of $iterations ==="

    set result (opencode run --file plan.md --file progress.txt "\
1. Find the highest-priority task to work on (not necessarily first in list).
2. Work ONLY on that single task until complete.
3. Run type checks, tests, and lint (if available).
4. Update plan.md to check off completed items with [x].
5. Append your progress to progress.txt (append only, don't overwrite previous entries).
6. Make a git commit for that task.
ONLY WORK ON A SINGLE TASK.
If plan.md is fully complete (all items checked), output <promise>COMPLETE</promise>.")

    # Exit on failure
    or exit 1

    echo $result

    # Check for completion signal
    if string match -q '*<promise>COMPLETE</promise>*' $result
        echo "Plan complete after $i iterations."
        exit 0
    end
end

echo "Completed $iterations iterations."
