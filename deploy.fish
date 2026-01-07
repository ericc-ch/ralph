#!/usr/bin/env fish

# Deploy ralph.fish to ~/.local/bin as ralph
set target ~/.local/bin/ralph
set source (dirname (status filename))/ralph.fish

# Ensure ~/.local/bin exists
mkdir -p ~/.local/bin

# Copy ralph.fish to target
cp $source $target

# Make executable
chmod +x $target

echo "Deployed ralph to $target"
