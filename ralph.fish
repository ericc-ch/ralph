#!/usr/bin/env fish

# Defaults
set iterations 10

# Parse arguments
argparse 'h/help' 'i/iteration=' 'once' -- $argv
or exit 1

if set -q _flag_help
    echo "Usage: ralph [OPTIONS]"
    echo ""
    echo "Run AI coding agent in iterative loops to complete requirements."
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

# Main loop
for i in (seq 1 $iterations)
    echo "=== Ralph iteration $i of $iterations ==="

    set result (opencode run --file requirements.json --file progress.txt "\
1. Find the highest-priority requirement to work on (not necessarily first in list).
2. Work ONLY on that single requirement until complete.
3. Run type checks, tests, and lint (if available).
4. Update requirements.json to mark progress/completion.
5. Append your progress to progress.txt (append only, don't overwrite previous entries).
6. Make a git commit for that requirement.
ONLY WORK ON A SINGLE REQUIREMENT.
If requirements.json is fully complete, output <promise>COMPLETE</promise>.")

    # Exit on failure
    or exit 1

    echo $result

    # Check for completion signal
    if string match -q '*<promise>COMPLETE</promise>*' $result
        echo "Requirements complete after $i iterations."
        exit 0
    end
end

echo "Completed $iterations iterations."
