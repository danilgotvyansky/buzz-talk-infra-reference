import yaml
from google.auth.transport.requests import Request
from google.oauth2.service_account import Credentials
from googleapiclient.discovery import build


# Set your project ID and output file path
PROJECT = "somegcpproject"
OUTPUT_FILE = "/home/cpanel_username/prometheus/file_sd/gcp_instances.yml"


def get_service_account_credentials():
    # Path to the service account key file
    key_file = "/home/cpanel_username/prometheus/prometheus_sa_key.json"

    # Define the required scopes
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]

    # Load the service account credentials
    credentials = Credentials.from_service_account_file(key_file, scopes=scopes)

    return credentials


def get_instances(credentials):
    service = build('compute', 'v1', credentials=credentials)
    request = service.instances().aggregatedList(project=PROJECT)
    response = request.execute()
    return response


def extract_instance_info(response):
    instances = []
    for zone, instances_in_zone in response['items'].items():
        if 'instances' in instances_in_zone:
            for instance in instances_in_zone['instances']:
                if instance['status'] == "RUNNING":
                    for interface in instance['networkInterfaces']:
                        if 'accessConfigs' in interface:
                            for access_config in interface['accessConfigs']:
                                if 'natIP' in access_config:
                                    instances.append({
                                        'targets': [f"{access_config['natIP']}"],
                                        'labels': {'instance': instance['name'], 'public_ip': f"{access_config['natIP']}", 'private_ip': interface['networkIP'], 'instance_id':  instance['id'], 'instance_name': instance['name'], 'project_id': PROJECT}
                                    })
    return instances


def write_to_file(instances, output_file):
    with open(output_file, 'w') as file:
        yaml.dump(instances, file)


def main():
    credentials = get_service_account_credentials()
    response = get_instances(credentials)
    instances = extract_instance_info(response)
    write_to_file(instances, OUTPUT_FILE)


if __name__ == "__main__":
    main()
