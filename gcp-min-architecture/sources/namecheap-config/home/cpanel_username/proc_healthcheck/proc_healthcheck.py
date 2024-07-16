import subprocess
import re
import os
from datetime import datetime
import logging

# Configure logging
logging.basicConfig(filename='/home/cpanel_username/proc_healthcheck/process_monitor.log',
                    level=logging.INFO,
                    format='%(asctime)s [%(levelname)s] %(message)s',
                    datefmt='%Y-%m-%d %H:%M:%S')

os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = "/home/cpanel_username/prometheus/exporters/stackdriver-exporter/stackdriver_exporter_sa_key.json"


def run_command(command):
    """Run shell command and return its output."""
    logging.info(f'Executing command: {command}')
    result = subprocess.run(command, shell=True, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if result.stderr:
        logging.error(f'Error executing command "{command}": {result.stderr}')
    else:
        logging.debug(f'Command executed successfully: {command}')
    return result.stdout


def get_running_processes():
    """Get the list of running processes using 'ps aux'."""
    logging.debug('Fetching running processes.')
    return run_command("ps aux")


def read_pid_file():
    """Read the processes_pids file into a dictionary."""
    pid_dict = {}
    try:
        with open("/home/cpanel_username/proc_healthcheck/processes_pids", "r") as file:
            for line in file:
                key, val = line.strip().split("=")
                pid_dict[key] = val
        logging.info('Successfully read PID file.')
    except Exception as e:
        logging.error(f'Error reading PID file: {e}')
    return pid_dict


def log_and_restart(process_name, command):
    """Log the failure reason for a process and restart it."""
    logging.warning(f'Process {process_name} is not running or PID is missing. Attempting to restart.')

    # Restart command adjusted to use the passed command
    pid = ""
    if process_name == "REDIS":
        restart_command = "/home/cpanel_username/virtualenv/redis/3.9/lib/python3.9/site-packages/redis_server/bin/redis-server /home/cpanel_username/redis/etc/redis.conf"
    else:
        restart_command = command
    if process_name == "BLACKBOX":
        command_to_execute = f"nohup {restart_command} > /home/cpanel_username/prometheus/exporters/blackbox-exporter/blackbox.log 2>&1 & echo $!"
    else:
        command_to_execute = f"nohup {restart_command} > /dev/null 2>&1 & echo $!"
    try:
        pid = run_command(command_to_execute).strip()
        if pid:
            logging.info(f"Successfully restarted {process_name} with PID: {pid}")
        else:
            logging.warning(f"Restarted {process_name} but failed to obtain new PID.")
    except Exception as e:
        logging.error(f"Error restarting {process_name}: {e}")
    return pid


def main():
    logging.info('Starting process monitoring script execution.')

    # Define your expected processes
    expected_processes = {
        "PROM": "/home/cpanel_username/prometheus/prometheus --web.external-url=http://prometheus.burava.com --web.config.file=/home/cpanel_username/prometheus/web.yml --storage.tsdb.retention.size=512MB --config.file=/home/cpanel_username/prometheus/prometheus.yml --storage.tsdb.path=/home/cpanel_username/prometheus/data/",
        "DBHEALTHCHECK": "/home/cpanel_username/virtualenv/prometheus/3.9/bin/python3.9_bin /home/cpanel_username/prometheus/dbhealthcheck/dbhealthcheck.py",
        "BLACKBOX": "/home/cpanel_username/prometheus/exporters/blackbox-exporter/blackbox_exporter --log.level=info --log.format=json --config.file=/home/cpanel_username/prometheus/exporters/blackbox-exporter/blackbox.yml",
        "REDIS-EXPORTER": "/home/cpanel_username/prometheus/exporters/redis-exporter/redis_exporter --redis.addr=redis://redis_uri --redis.password somepass",
        "REDIS": "/home/cpanel_username/virtualenv/redis/3.9/lib/python3.9/site-packages/redis_server/bin/redis-server *:12112",
        "CP-EXPORTER": "/home/cpanel_username/virtualenv/prometheus/3.9/bin/python3.9_bin /home/cpanel_username/prometheus/exporters/cpanel-exporter/cpanel-exporter.py",
        "GRAFANA": "/home/cpanel_username/grafana/bin/grafana server --config=/home/cpanel_username/grafana/grafana.ini --homepath=/home/cpanel_username/grafana",
        "STACKDRIVER-EXPORTER": "/home/cpanel_username/prometheus/exporters/stackdriver-exporter/stackdriver_exporter --google.project-id=somegcpproject --web.listen-address=:9255 --web.telemetry-path=/metrics --monitoring.metrics-type-prefixes compute.googleapis.com/instance/uptime_total,compute.googleapis.com/instance_group/size,loadbalancing.googleapis.com/https/backend_latencies,loadbalancing.googleapis.com/https/backend_request_count,loadbalancing.googleapis.com/https/request_count,loadbalancing.googleapis.com/https/total_latencies,autoscaler.googleapis.com/,billingbudgets.googleapis.com/",
        "PROXY-CONTAINER-SCALER": "/home/cpanel_username/virtualenv/prometheus/3.9/bin/python3.9_bin /home/cpanel_username/proxy_container_scaler/proxy_container_scaler.py",
    }

    running_processes = get_running_processes()
    pid_dict = read_pid_file()

    for process_name, command in expected_processes.items():
        logging.debug(f'Checking process: {process_name}')
        command_found = command in running_processes

        if command_found:
            logging.info(f'Process {process_name} is running. Updating PID.')
            # Update PID for running processes
            pattern = rf"(\d+).*?{re.escape(command.partition(' ')[2])}"  # Adjust regex to match your command structure and extract PID
            match = re.search(pattern, running_processes, re.MULTILINE)
            if match:
                pid_dict[process_name] = match.group(1)
        else:
            logging.warning(f'Process {process_name} not found or PID is missing. Proceeding to restart.')
            # Adjusted to either log, restart, and/or append missing key with a newly started PID
            pid = log_and_restart(process_name, command)
            pid_dict[process_name] = pid  # This updates or adds the key-value pair in the dictionary

    # Update or add the (key=PID) to processes_pids
    with open("/home/cpanel_username/proc_healthcheck/processes_pids", "w") as file:
        for key, val in pid_dict.items():
            file.write(f"{key}={val}\n")
    logging.info('Finished process monitoring script execution.')


if __name__ == "__main__":
    main()
