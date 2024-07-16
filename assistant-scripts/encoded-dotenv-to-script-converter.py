import os
import base64

default_env_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), '.env')

# Prompt paths
template_path = input('Indicate the path to a .template file where the variables should be changed from the ones from '
                      '.env: ')
env_path = input(f"Indicate the path to a .env file (default is {default_env_path}): ")

# If .env path is not specified, use default
if not env_path:
    env_path = default_env_path

# Open and parse .env file
with open(env_path, 'r') as env_file:
    env_vars = dict(line.strip().split('=', 1) for line in env_file if line.strip() and not line.startswith('#'))

# Open .template file and replace env variables with base64 encoded values
with open(template_path, 'r') as template_file, open(template_path.replace('.template', '.bash'), 'w') as out_file:
    for line in template_file:
        for env_var, value in env_vars.items():
            if "${" + env_var + "}" in line:
                 line = line.replace("${" + env_var + "}", base64.b64encode(value.encode()).decode())
        out_file.write(line)
