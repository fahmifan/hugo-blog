#!/bin/bash

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

# Build the project.
hugo -t cocoa-eh # if using a theme, replace with `hugo -t <YOURTHEME>`

# Go To Public folder
cd public

# hapus symbolic link img
rm -rf photos/

# Add changes to git.
git add .

# Commit changes.
msg="rebuilding fahmifan.github.io `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

# Push source and build repos.
git push origin master

# Come Back up to the Project Root
cd ..

git add public/ content/
git commit -m "rebuild site `date`"
git push origin master