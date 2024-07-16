#! /bin/bash
exec > /tmp/startup-script.log 2>&1
snap install jq

TOKEN=$(curl -H "Metadata-Flavor: Google" "http://metadata/computeMetadata/v1/instance/service-accounts/default/token" | jq -r '.access_token')
curl -H "Authorization: Bearer $TOKEN" -o /tmp/startup-script.sh "https://storage.googleapis.com/buzz-talk/gcp-min-architecture/02-instance/startup-application-script.bash"

chmod +x /tmp/startup-script.sh

/tmp/startup-script.sh