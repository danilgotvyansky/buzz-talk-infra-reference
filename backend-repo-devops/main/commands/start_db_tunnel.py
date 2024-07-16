import subprocess
import environ
from pathlib import Path
from django.core.management.base import BaseCommand

BASE_DIR = Path(__file__).resolve().parent.parent.parent.parent

env = environ.Env()


class Command(BaseCommand):
    help = 'Starts the SSH tunnel before other commands'

    def handle(self, *args, **options):
        host = "127.0.0.1"
        port = env("MYSQL_DB_PORT")
        ssh_key = (BASE_DIR/'.ssh/cpanel_username')
        ssh_user = 'cpanel_username'
        ssh_host = 'cpanel_hostname'
        ssh_port = 21098

        tunnel_command = f"ssh -o StrictHostKeyChecking=no -oHostKeyAlgorithms=+ssh-rsa -oPubkeyAcceptedKeyTypes=+ssh-rsa -f -i {ssh_key} -p {ssh_port} -L {host}:{port}:127.0.0.1:3306 -N {ssh_user}@{ssh_host}"

        self.stdout.write(self.style.SUCCESS('Starting SSH tunnel...'))
        subprocess.run(tunnel_command, shell=True, check=True)
        self.stdout.write(self.style.SUCCESS('SSH tunnel started successfully'))
