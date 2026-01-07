#!/usr/bin/env fish

# Deploy ralph.fish to ~/.local/bin as ralph
set target ~/.local/bin/ralph
set source (dirname (status filename))/ralph.fish

# Ensure ~/.local/bin exists
mkdir -p ~/.local/bin

# Symlink ralph.fish to target
ln -sf (realpath $source) $target

echo "Deployed ralph to $target"
