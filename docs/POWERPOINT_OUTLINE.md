# PowerPoint Outline

## Slide 1: Project Title

OS Project - System Monitoring Solution

Presented by: Ahmed Osama

## Slide 2: Project Overview

This project is a system monitoring solution that collects, analyzes, and reports hardware and software performance metrics.

## Slide 3: Project Objectives

- Collect system metrics
- Detect critical usage levels
- Generate Markdown and HTML reports
- Provide an interactive dashboard
- Run inside a Docker container

## Slide 4: Monitored Components

- CPU usage and temperature
- GPU utilization and health
- Memory consumption
- Disk usage and SMART status
- Network interface statistics
- System load metrics
- Running processes

## Slide 5: Tools and Technologies

- Bash scripting
- Ubuntu / WSL Ubuntu
- Docker
- Docker Compose
- Whiptail
- Pandoc
- lm-sensors
- smartmontools
- pciutils

## Slide 6: Bash Monitoring Script

The main script is `monitor.sh`. It collects system metrics using Linux commands and generates reports.

## Slide 7: Alert System

Alerts are triggered when CPU, memory, or disk usage exceeds 80%.

## Slide 8: Reporting System

The system generates Markdown and HTML reports. Pandoc converts the Markdown report into HTML.

## Slide 9: Interactive Dashboard

The dashboard is created using Whiptail. It allows the user to run monitoring, view reports, view logs, and open project files.

## Slide 10: Docker Containerization

Docker containerizes the project using a Dockerfile and Docker Compose. Reports, logs, and alerts are saved using volumes.

## Slide 11: Project Output

- Markdown report
- HTML report
- Log file
- Alert file when needed
- Dashboard interface
- Dockerized execution

## Slide 12: Limitations

WSL and Docker may limit access to full hardware metrics such as GPU utilization, CPU temperature, and SMART disk status.

## Slide 13: Conclusion

The project successfully provides a complete monitoring solution using Bash, reports, alerts, logging, dashboard interaction, and Docker.
