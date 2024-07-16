import time
from flask import Flask, request, jsonify
from flask_httpauth import HTTPBasicAuth
import os
from dotenv import load_dotenv
import logging
import json
import paramiko
from paramiko import SSHException
from paramiko.ssh_exception import NoValidConnectionsError

app = Flask(__name__)
auth = HTTPBasicAuth()

load_dotenv()

if os.getenv("DEBUG", "").lower() in ["1", "true", "t", "yes", "y"]:
    log_level = logging.DEBUG
else:
    log_level = logging.INFO

GRAFANA_WEBHOOK_USER = os.getenv('GRAFANA_WEBHOOK_USER')
GRAFANA_WEBHOOK_PASSWORD = os.getenv('GRAFANA_WEBHOOK_PASSWORD')
SSH_KEY = os.getenv('SSH_KEY_PATH')

# Define a single user and password
users = {
    f"{GRAFANA_WEBHOOK_USER}": f"{GRAFANA_WEBHOOK_PASSWORD}"
}


@auth.get_password
def get_pw(username):
    return users.get(username)


# Setup logging
logging.basicConfig(level=log_level,
                    format='%(asctime)s [%(levelname)s] %(message)s',
                    datefmt='%Y-%m-%d %H:%M:%S',
                    handlers=[logging.StreamHandler(),
                              logging.FileHandler('/home/cpanel_username/proxy_container_scaler/proxy_container_scaler.log')])

logger = logging.getLogger()


@app.route('/', methods=['POST'])
@auth.login_required
def log_json():
    logger.info('Request received')
    raw_data = request.data.decode("utf-8")
    logger.info(f'Request data: {raw_data}')

    if request.is_json:
        data = request.get_json()

        # Write formatted JSON data to file (overwrite mode)
        with open('/home/cpanel_username/proxy_container_scaler/alert.json', 'w') as json_file:
            json.dump(data, json_file, indent=4)  # Use json.dump to write JSON string

        app_new_containers_number = data["alerts"][0]["values"].get("app_new_containers_number")
        app_active_containers = data["alerts"][0]["values"].get("app_active_containers")
        public_ip = data["alerts"][0]["labels"].get("public_ip")
        scale_trigger = data["alerts"][0]["values"].get("scale_trigger")
        status = data["alerts"][0]["status"]
        service_name = data["alerts"][0]["labels"].get("container_label_com_docker_swarm_service_name")
        scaling = data["alerts"][0]["labels"].get("scaling")

        if scale_trigger == 1 and status == "firing":
            logger.info(f'Scale trigger is 1 and status is firing for {service_name} at {public_ip}')
            if check_env_variable(public_ip, "IN_DEPLOY"):
                logger.info(f'Deploy in progress on {public_ip}. No scaling required.')
                return jsonify({"message": "Deploy in progress. No scaling required."}), 200

            if scaling == 'not_possible':
                logger.warning(f'Scale trigger received but scale is {scaling} for {service_name} at {public_ip}')
                return jsonify({"message": f"Scale is {scaling}"}), 200

            if app_active_containers == app_new_containers_number:
                logger.error(f'Scale trigger received but active containers ({app_active_containers}) for {service_name} is equal to new containers number ({app_new_containers_number}) on {public_ip}')
                return jsonify({"message": "Scale trigger received incorrectly"}), 200

            logger.info(f'Scaling {scaling} the service: {service_name} from {app_active_containers} to {app_new_containers_number} at {public_ip}')
            if scale_service(public_ip, service_name, app_new_containers_number):
                if not verify_containers_count(public_ip, service_name, app_new_containers_number):
                    logger.error(f'Failed to scale service {service_name} to {app_new_containers_number} on {public_ip}')
                    return jsonify({"message": "Failed to scale service to desired number"}), 500
                else:
                    set_env_variable(public_ip, f'{service_name.upper()}_IS_SCALED', app_new_containers_number)
                    logger.info(f'Successfully scaled service {service_name} to {app_new_containers_number} on {public_ip}')
                    return jsonify({"message": "Service scaled successfully"}), 200
        elif status == "firing":
            logger.warning(f'Scale trigger received but scale not needed for {service_name} at {public_ip}')
            return jsonify({"message": "Scale trigger received but scale not needed"}), 200
        else:
            logger.warning(f'Scale trigger not received for {service_name} at {public_ip}')
            return jsonify({"message": "Scale trigger not received"}), 200
    else:
        logger.warning('Request body is not JSON')
        return jsonify({"message": "Request body must be JSON"}), 400


def ssh_command(host, command, ssh_key, timeout=300):
    try:
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        client.connect(hostname=host, username="deploy", key_filename=SSH_KEY, timeout=float(timeout))
        logger.debug(f'Executing command on {host}: {command}')
        stdin, stdout, stderr = client.exec_command(command, timeout=float(timeout))
        result = stdout.read().decode().strip()
        error_output = stderr.read().decode().strip()
        client.close()
        if result:
            logger.debug(f'Command output on {host}: {result}')
        if error_output:
            logger.error(f'Command error on {host}: {error_output}')
        return result if result else error_output
    except (SSHException, NoValidConnectionsError) as e:
        logger.error(f'SSH command failed on {host}: {e}')
        return None


def check_env_variable(host, variable):
    command = f'echo ${variable}'
    result = ssh_command(host, command, SSH_KEY)
    return result == 'true'


def scale_service(host, service_name, container_number):
    command = f'sudo docker service scale {service_name}={container_number}'
    result = ssh_command(host, command, SSH_KEY)
    return result is not None


def verify_containers_count(host, service_name, expected_count):
    time.sleep(10)
    command = f'sudo docker service ls --filter name={service_name} --format "{{{{.Replicas}}}}"'
    result = ssh_command(host, command, SSH_KEY)
    if result:
        actual_count = int(result.split('/')[0])
        logging.debug(f"Current count: {actual_count}")
        return actual_count == expected_count
    return False


def set_env_variable(host, variable, value):
    command = f'export {variable}={value}'
    ssh_command(host, command, SSH_KEY)


@app.errorhandler(401)
def custom_401(error):
    logger.error('Unauthorized access attempt')
    return jsonify({"message": "Unauthorized access"}), 401


if __name__ == '__main__':
    app.run(port=9789)
