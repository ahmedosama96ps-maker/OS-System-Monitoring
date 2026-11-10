# OS Project - System Monitoring Solution

A Bash-based system monitoring solution that collects, analyzes, and reports hardware and software performance metrics. The project includes monitoring scripts, alerts, logging, Markdown/HTML reporting, an interactive dashboard, and Docker containerization.

## Project Overview

The system monitors important operating system and hardware metrics, then generates reports that can be used for review, troubleshooting, and presentation.

The monitoring solution includes:

- System information collection
- CPU usage and temperature monitoring
- GPU utilization and health checking when available
- Memory usage monitoring
- Disk usage and SMART health checking
- Network interface statistics
- System load metrics
- Running process monitoring
- Alert generation
- Markdown and HTML reporting
- Interactive dashboard
- Docker containerization

## Features

- CPU usage monitoring using `top`
- CPU temperature check using `lm-sensors`
- GPU check using `nvidia-smi`, `rocm-smi`, or `lspci` fallback
- Memory usage monitoring using `free`
- Disk usage monitoring using `df`
- Disk SMART health check using `smartctl`
- Network statistics using `ip -s link`
- System load check using `uptime`
- Top running processes using `ps`
- Alert system for high CPU, memory, and disk usage
- Log file generation
- Markdown report generation
- HTML report generation using Pandoc
- Terminal dashboard using Whiptail
- Dockerfile and Docker Compose support

## Tools and Technologies

- Bash scripting
- Ubuntu / WSL Ubuntu
- Docker
- Docker Compose
- Whiptail
- Pandoc
- lm-sensors
- smartmontools
- pciutils
- procps
- iproute2
- net-tools

## Repository Structure

```text
OS-System-Monitoring/
├── Dockerfile
├── docker-compose.yml
├── .gitignore
├── .dockerignore
├── README.md
├── docs/
└── scripts/
    ├── monitor.sh
    └── dashboard.sh
```

The `reports/`, `logs/`, and `alerts/` directories are created at runtime, not tracked as source files. The scripts now resolve paths relative to their own location and can be invoked from any working directory.

## Installation

Update the package list:

```bash
sudo apt update
```

Install the required tools:

```bash
sudo apt install -y nano curl git htop net-tools lm-sensors smartmontools pandoc whiptail pciutils less
```

Give scripts execution permission:

```bash
chmod +x scripts/monitor.sh
chmod +x scripts/dashboard.sh
```

## Running the Monitoring Script

Run:

```bash
./scripts/monitor.sh
```

The script creates:

- Markdown report in `reports/`
- HTML report in `reports/`
- Log file in `logs/`
- Alert file in `alerts/` if critical alerts are detected

## Running the Dashboard

Run:

```bash
./scripts/dashboard.sh
```

The dashboard allows the user to:

- Run system monitoring
- View the latest Markdown report
- View the log file
- Open the reports folder in Windows from WSL
- Show project files

## Running with Docker

Build the Docker image:

```bash
docker compose build
```

Run the project container:

```bash
docker compose up
```

Docker runs the monitoring script **inside a container**. CPU, disk, memory, network, and hardware readings can reflect container views or the host kernel rather than reliable host-wide metrics. Containerization is a convenient packaging option, **not** an accurate substitute for installing the monitor on the host. The `reports`, `logs`, and `alerts` folders are mounted as volumes, so generated output is saved back to the local project folder.

## Viewing Reports

List reports:

```bash
ls reports
```

View the latest Markdown report:

```bash
cat "$(ls -t reports/*.md | head -1)"
```

Open the latest HTML report from WSL:

```bash
explorer.exe "$(wslpath -w "$(ls -t reports/*.html | head -1)")"
```

## Alert System

The system triggers alerts when:

- CPU usage is above 80%
- Memory usage is above 80%
- Disk usage is above 80%

If an alert is triggered, it is written to:

- The alert file
- The main log file
- The generated monitoring report

## Hardware Limitations

Some hardware metrics may be limited in WSL or Docker environments.

Examples:

- GPU utilization may require `nvidia-smi` or `rocm-smi`
- CPU temperature may not be fully available in WSL
- Disk SMART status may not access the physical disk directly in WSL or Docker

The script handles these cases safely by displaying a clear message instead of stopping execution.

## Discussion Summary

This project provides a complete system monitoring solution using Bash scripting. It collects system metrics, generates alerts, saves logs, creates Markdown and HTML reports, includes an interactive dashboard, and supports Docker containerization for consistent execution.


## Validation and operational limitations

- The CPU calculation uses a second `top` sample. If it cannot be parsed, CPU usage is marked `N/A` instead of inaccurately reporting zero.
- This is a snapshot monitor, not a continuously running agent: alerts occur **only when the script runs**.
- Missing GPU, temperature, or SMART support is reported as unavailable, not inferred as healthy.
- Run syntax checks with `bash -n scripts/monitor.sh scripts/dashboard.sh`. The included GitHub Actions workflow also executes a basic smoke test on Ubuntu.
- Logs and reports are ignored from Git history. Never commit sensitive local host information to public repositories.
