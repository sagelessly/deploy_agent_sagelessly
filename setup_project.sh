#!/bin/bash
set -e

#Getting the project input from the user

read -p "Enter project name (don't add spaces): " input

if [[ -z "$input" ]]; then
  echo "Error: project name cannot be empty."
  exit 1
fi

PROJECT_DIR="attendance_tracker_${input}"
ARCHIVE_NAME="attendance_tracker_${input}_archive"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/source_files"

#Handling the CTRL+C key

cleanup() {
  echo ""
  echo " Interrupt received. Bundling current state into archive..."

  if [[ -d "$PROJECT_DIR" ]]; then
    tar -czf "${ARCHIVE_NAME}.tar.gz" "$PROJECT_DIR"
    echo " Archive created: ${ARCHIVE_NAME}.tar.gz"
    rm -rf "$PROJECT_DIR"
    echo " Incomplete directory removed."
  else
    echo " Nothing to archive — directory was not yet created."
  fi

  echo "Exiting."
  exit 1
}

trap cleanup SIGINT

#Building the project directory

echo ""
echo "Creating project directory: $PROJECT_DIR"

mkdir -p "$PROJECT_DIR/Helpers"
mkdir -p "$PROJECT_DIR/reports"

#Adding the source files

echo "Copying source files..."

cp "$SOURCE_DIR/attendance_checker.py" "$PROJECT_DIR/attendance_checker.py"
cp "$SOURCE_DIR/assets.csv"            "$PROJECT_DIR/Helpers/assets.csv"
cp "$SOURCE_DIR/config.json"           "$PROJECT_DIR/Helpers/config.json"
cp "$SOURCE_DIR/reports.log"           "$PROJECT_DIR/reports/reports.log"

echo " Files copied."

#Updating the thresholds

echo ""
read -p "Do you want to update attendance thresholds? (y/n): " update_config

if [[ "$update_config" == "y" || "$update_config" == "Y" ]]; then

  read -p "Enter Warning threshold % (default 75): " warn_val
  read -p "Enter Failure threshold % (default 50): " fail_val

  # Use defaults if the user pressed Enter without typing a value
  warn_val="${warn_val:-75}"
  fail_val="${fail_val:-50}"

  CONFIG_FILE="$PROJECT_DIR/Helpers/config.json"

  # Detect OS for correct sed in-place syntax
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/\"warning\": [0-9]*/\"warning\": $warn_val/" "$CONFIG_FILE"
    sed -i '' "s/\"failure\": [0-9]*/\"failure\": $fail_val/" "$CONFIG_FILE"
  else
    sed -i "s/\"warning\": [0-9]*/\"warning\": $warn_val/" "$CONFIG_FILE"
    sed -i "s/\"failure\": [0-9]*/\"failure\": $fail_val/" "$CONFIG_FILE"
  fi

  echo "✔  config.json updated — warning: ${warn_val}%, failure: ${fail_val}%"

else
  echo "   Keeping default thresholds (warning: 75%, failure: 50%)."
fi
 
#Doing the health check

echo ""
echo "Running environment health check..."

#Check for Python 3

if python3 --version &>/dev/null; then
  PYTHON_VERSION=$(python3 --version 2>&1)
  echo "  Python 3 found: $PYTHON_VERSION"
else
  echo "  Warning: python3 is not installed or not on PATH."
  echo "  The application may not run correctly."
fi

#Verify directory structure

echo ""
echo "Verifying project structure..."

MISSING=0
for path in \
  "$PROJECT_DIR/attendance_checker.py" \
  "$PROJECT_DIR/Helpers/assets.csv" \
  "$PROJECT_DIR/Helpers/config.json" \
  "$PROJECT_DIR/reports/reports.log"; do
  if [[ -e "$path" ]]; then
    echo "  $path"
  else
    echo "  MISSING: $path"
    MISSING=1
  fi
done

if [[ $MISSING -eq 1 ]]; then
  echo ""
  echo " Health check failed — some files are missing."
  exit 1
fi

#Finishing the project

echo "  Project setup complete!"
echo "  Directory: $PROJECT_DIR"
echo "  To run the app:"
echo "  cd $PROJECT_DIR && python3 attendance_checker.py"
