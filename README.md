A shell script "Project Factory" that automates the creation and configuration
of a Student Attendance Tracker workspace.

#How to run

1. Clone this repository:
   git clone https://github.com/sagelessly/deploy_agent_sagelessly.git
   cd deploy_agent_sagelessly

2. Make the script executable (first time only):
   chmod +x setup_project.sh

3. Run the script:
   ./setup_project.sh

4. Follow the prompts:
   - Enter a project name (e.g. batch2025)
   - Choose whether to update attendance thresholds
   - If yes, enter new Warning % and Failure % values

The script will create attendance_tracker_{name}/ with the full directory
structure, copy all source files, update config.json via sed, and run a
health check.

#How to trigger the archive feature

Press Ctrl+C at any point after entering the project name.

The script will:
1. Catch the SIGINT signal
2. Bundle the current (incomplete) project directory into a .tar.gz archive
   named attendance_tracker_{name}_archive.tar.gz
3. Delete the incomplete directory
4. Exit cleanly

#Project structure created

attendance_tracker_{name}/
├── attendance_checker.py
├── Helpers/
│   ├── assets.csv
│   └── config.json
└── reports/
    └── reports.log

