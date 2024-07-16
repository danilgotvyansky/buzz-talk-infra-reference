# buzz-talk-infra-reference
Public portfolio repository representing DevOps solutions for the pet-project Buzz-Talk Chat Application where I took part as DevOps Engineer.

Review and experience knowledge is highly appreciated!

[🗐](#table-of-contents) is to return to Table of contents.


# Table of contents:
1. [Application](#application-)
2. [Repository structure](#repository-structure-)
3. [GCP Minimum Architecture](#gcp-minimum-architecture-)
   * [Challenges and Solutions](#challenges-and-solutions-)
     * [Cheap but complete and Why GCP?](#cheap-but-complete-and-why-gcp-)
     * [Fast and consistent launch](#fast-and-consistent-launch-)
     * [Database on Namecheap](#database-on-namecheap-)
     * [Handling SPOT and instance autoscaling](#handling-spot-and-instance-autoscaling-)
     * [Instance template requires shutdown to edit](#instance-template-requires-shutdown-to-edit-)
     * [Don't expose startup secrets on repo](#dont-expose-startup-secrets-on-repo-)
     * [One application entrypoint](#one-application-entrypoint-)
     * [Frontend and Backend can't communicate in Docker](#frontend-and-backend-cant-communicate-in-docker-)
     * [Handling websockets](#handling-websockets-)
     * [Monitoring. Grafana, Prometheus, exporters](#monitoring-grafana-prometheus-exporters-)
       * [Service discovery](#service-discovery-)
       * [Monitoring dashboard](#monitoring-dashboard-)
     * [Container scaling with Python and Grafana](#container-scaling-with-python-and-grafana-)
     * [Continuous Integration & Continuous Delivery](#continuous-integration--continuous-delivery-)
     * [Ensure apps on Namecheap server always run](#ensure-apps-on-namecheap-server-always-run-)

### Application [🗐](#table-of-contents)

Chat application. Link: [buzztalk.burava.com](http://buzztalk.burava.com)
* Backend: Django
* Frontend: React [link to repo](https://github.com/lovember26/buzzTalk-chat-front-end-2)
* Database: MySQL
* Redis


### Repository structure [🗐](#table-of-contents)
```
.github/** - workflows for GitHub Actions in infrastructure repo
backend-repo-devops/** - files from backend repo of BuzzTalk org related to DevOps solutions
(hidden) .ssh/** - ssh keys and config
assistant-scripts/** - scripts which can be used to automate some local configurations.
${provider}-${scale}-architecture/** - Terraform configuration for a particular architecture depending on the scale and provider.
${provider}-${scale}-architecture/env.hcl - main Terragrunt configuration DRY file. Provider, backend and var files configurations are defined/generated here.
${provider}-${scale}-architecture/grafana.hcl - Grafana Terragrunt configuration DRY file.
${provider}-${scale}-architecture/terragrunt.hcl - left for proper Terragrunt working.
${provider}-${scale}-architecture/${int_apply_order}-${module}/${component}.tf - main component Terraform configuration file.
${provider}-${scale}-architecture/${int_apply_order}-${module}/variables.tf - Terraform file containing variables used in the module configuration.
${provider}-${scale}-architecture/${int_apply_order}-${module}/outputs.tf - Terraform file containing outputs from the module configuration.
${provider}-${scale}-architecture/${int_apply_order}-${module}/settings.tfvars - file containing specific module inputs.
${provider}-${scale}-architecture/${int_apply_order}-${module}/terragrunt.hcl - main module Terragrunt file. Dependencies and source *.tf files are specified there.
${provider}-${scale}-architecture/sources/** - source files for the Terraform and Namecheap server configuration such as startup-scripts or automation python scripts.
... other GitHub-related files
```

## [GCP Minimum Architecture](gcp-min-architecture/) [🗐](#table-of-contents)

![image](https://github.com/user-attachments/assets/c882704b-f691-4bf4-9a88-8a7e4e017a2f)

**Description**

The idea of this configuration is to make the most minimum cost-effective architecture which will be still fault-tolerant and allow us to resolve most of the dependency-related issues by containerization.

Below I will describe all solutions as `Challenge: Solution` to make sense of some of the decisions.

`When reading all the solutions below remember that it is all about low-cost solution for development, not most effective for production :)`

### Challenges and Solutions [🗐](#table-of-contents)
<details>
    <summary>Click to Read more</summary>

#### Cheap but complete and Why GCP? [🗐](#table-of-contents)

Because of the completely voluntary and free nature of our project, only free hosting providers were used for all components which was generally okay, but also raised many issues such as:
* Dependencies for python packages - some python packages were impossible to install due to rootless environment or other limitations.
* Free hosting didn't allow to run some things continuously, for example, we couldn't use SSH tunnels because this functionality was blocked from server side, media files were deleted each time session ended, and backend needed 1-2 minutes to boot.
* etc.

So I decided that the best way is to find solutions allowing to use Docker and rootful environments for the application hosting.

Google Cloud was chosen due to its 3 months Free Trial with 300$ for unlimited sandbox usage. Moreover, if we spend all our resources or decide to renew the project after a pause, we can launch completely the same configuration on different billing and Google account (without any abuse ofc).

Even if we decide to keep current project for the long time, GCP offers 1 completely free e2-standard each month meaning costs would be very low.

Compute settings can be found there [gcp-min-architecture/02-instance/instance-template.tf](gcp-min-architecture/02-instance/instance-template.tf)

Shortly speaking, we use one of the cheapest e2-micro instance with SPOT launch type.

#### Fast and consistent launch [🗐](#table-of-contents)

I used Terraform and Terragrunt to make this configuration possible to launch in minutes and also easy to maintain. It also allowed me to practice my configuration on GCP sandboxes without spending money on my Google account. Beforehand, you literally only create Cloud Storage bucket and database on Namecheap server.

Proper structuring allowed me not to get lost in a bunch of .tf files and using Terragrunt maintained DRY configuration.

You can read more about the structure [here](#repository-structure)

I also use [Cloud Storage bucket](gcp-min-architecture/env.hcl) as a backend for my state files to allow me to work and study from any device and any place I want.

#### Database on Namecheap [🗐](#table-of-contents)

Since the free database PostgreSQL solution was limited by 3 concurrent database connections, developers and QA could not study and work simultaneously.

At the same time, we couldn't use CloudSQL because its one of the most expensive resources offered by GCP, and it doesn't fall to our *Cheap* logic. 

I am continuously renting the cheapest Shared Server on Namecheap for my other side-projects which offers many things for its low price: Email, Database, Disk, WordPress, Application hosting. We could launch our backend on the same server and we tried but we faced the same dependency issues as on the free ones. But at the same time, we decided to take advantage of the MySQL database offered by this plan since its usage is not limited.

The only limitation is that the database port and host is not public, but with the SSH tunneling you can connect your outside applications with the database without any issues.

SSH tunneling handled by creating a [small Django command](backend-repo-devops/main/commands/start_db_tunnel.py) to initiate a tunnel to the database server and calling this command right in [backend Dockerfile](backend-repo-devops/Dockerfile) on container startup.

#### Handling SPOT and instance autoscaling [🗐](#table-of-contents)

Using spot instances means we need to be able to have >= 1 machines running with the same configuration.

Because of that, we use [instance template](gcp-min-architecture/02-instance/instance-template.tf), [managed instance group with auto scaler](gcp-min-architecture/02-instance/managed_instance_group.tf) and [startup scripts](gcp-min-architecture/sources/startup-scripts) to automate instance launch.

Again, using DRY configuration allows us to quickly change minimum and maximum numbers of running instances. 

#### Instance template requires shutdown to edit [🗐](#table-of-contents)

Due to the fact that GCP adds many attributes to the template which are not possible to be indicated in Terraform configuration, I had to set `lifecycle{ignore_changes = all}` in .tf configuration. At the same time, to make startup-application-script easier for updating, it is uploaded directly to GCP bucket.

The [default instance startup script](gcp-min-architecture/sources/startup-scripts/application-node-startup-script/startup.bash) just downloads the [actual startup script](gcp-min-architecture/sources/startup-scripts/application-node-startup-script/startup-application-script.template) which proceeds with the configuration.

#### Don't expose startup secrets on repo [🗐](#table-of-contents)

Before uploading startup script to the bucket, you just need to run [universal assistant script](assistant-scripts/encoded-dotenv-to-script-converter.py) that compares your .env file excluded in .gitignore with the .template file where you need to replace variables with the base64 encoded strings. Generated file is also excluded in .gitignore.

#### One application entrypoint [🗐](#table-of-contents)

The application uses Load Balancer as first entrypoint.

I added load balancer to this project for several reasons:
* pay only for one [static public IP](gcp-min-architecture/01-network/network.tf) no matter how much instances you have.
* smooth communication between client and application.
* actual load balancing in case of scaling.

Configuration for the load balancer is located [here](gcp-min-architecture/03-load-balancer).

#### Frontend and Backend can't communicate in Docker [🗐](#table-of-contents)

When we had started using Docker, I thought that I will need to learn how to route requests with Nginx at once.

This part caused me a lot of struggle and time to fully understand how it works but in the end Nginx configuration works as expected.

Nginx configuration:
* [nginx.conf.template](https://github.com/lovember26/buzzTalk-chat-front-end-2/blob/dev/nginx.conf.template)
* [startnginx.sh](https://github.com/lovember26/buzzTalk-chat-front-end-2/blob/dev/startnginx.sh)
* [baseURL.js](https://github.com/lovember26/buzzTalk-chat-front-end-2/blob/dev/src/constants/baseURL.js)
* [Dockerfile](https://github.com/lovember26/buzzTalk-chat-front-end-2/blob/dev/Dockerfile)

#### Handling websockets [🗐](#table-of-contents)

Application uses websockets for notifications and chat sessions. At the start, application used local memory middleware for storing websockets.

While using Docker containers and having multiple instances - it's impossible.

That's why I hosted Redis on my Namecheap shared server as a binary file installed using [pip library](https://pypi.org/project/redis-server/)

You can find used Redis configuration [there](gcp-min-architecture/sources/namecheap-config/home/cpanel_username/redis/etc/redis.conf)

#### Monitoring. Grafana, Prometheus, exporters [🗐](#table-of-contents)

For monitoring purposes many of the components are launched as binary files on Namecheap server, and it consists of the following apps:

* Grafana - for monitoring visualizing and alerting. Alerts for all basic components are created but I will not upload them there since it is not very interesting 
* Prometheus - for storing and collecting metrics ([prometheus.yml](gcp-min-architecture/sources/namecheap-config/home/cpanel_username/prometheus/prometheus.yml))
* Node exporter and cAdvisor ([configuration]((gcp-min-architecture/sources/startup-scripts/application-node-startup-script/startup-application-script.template)))
* Blackbox exporter - for the endpoints and database healthchecks ([configuration](gcp-min-architecture/sources/namecheap-config/home/cpanel_username/prometheus/exporters/blackbox_exporter/blackbox.yml))
* cPanel exporter - for collecting Namecheap server account metrics. This custom exporter was developed due to this project needs but can be used for any cPanel account monitoring. [Repository](https://github.com/danilgotvyansky/cpanel-exporter)
* Redis exporter - for collecting Redis metrics
* Stackdriver exporter - for collecting GCP project metrics. Mainly used to monitor instances uptime. Uses service account described [here](gcp-min-architecture/04-monitoring/iam/serviceaccount.tf)
* [Database healthcheck script](gcp-min-architecture/sources/namecheap-config/home/cpanel_username/prometheus/dbhealthcheck/dbhealthcheck.py) - custom way for monitoring database health in case of the database maintenance on shared server. Depends on Blackbox exporter
* Discord - messanger to where all alerts are routed

##### Service discovery [🗐](#table-of-contents)

Once I came to the GCP environment monitoring I needed to dynamically discover public ephemeral IPs of the instances.

To do that I developed a [small script](gcp-min-architecture/sources/namecheap-config/home/cpanel_username/prometheus/gcp_discover_instances.py) which updates `file_sd/gcp_instances.yml` file mentioned in [prometheus.yml](gcp-min-architecture/sources/namecheap-config/home/cpanel_username/prometheus/prometheus.yml). Runs on Cron

The script uses service account for Prometheus described [here](gcp-min-architecture/04-monitoring/iam/serviceaccount.tf).

##### Monitoring dashboard [🗐](#table-of-contents)

[Main monitoring dashboard](gcp-min-architecture/sources/namecheap-config/home/cpanel_username/grafana/dashboards/buzz_talk_monitoring.json) has a few interesting solutions on how to dynamically display information for all instances.

Since instances have public ephemeral IPs, developers could just visit the dashboard to know current instance IP and connect to it to perform debugging without requiring access to GCP.

**Last 1 hour screenshot of dynamic panel**

![screenshot_1h](https://github.com/user-attachments/assets/f57ae599-1802-4fb5-99d4-2513a82e489a)

**Last 24 hours screenshot of dynamic panel**

![screenshot_24h](https://github.com/user-attachments/assets/ba6c4237-6a4b-45a0-8264-e6c27482e2c7)

Other screenshots can be found [there](gcp-min-architecture/sources/namecheap-config/home/cpanel_username/grafana/dashboards/README.md)

#### Container scaling with Python and Grafana [🗐](#table-of-contents)

To minimize the need in instances scaling I decided to think of the containers scaling using Docker Swarm, Grafana Unified Alerting and custom developed [proxy_container-scaler.py](gcp-min-architecture/sources/namecheap-config/home/cpanel_username/proxy_container_scaler/proxy_container_scaler.py) app.

Scaling logic:

**Grafana Alert Rule**

There is an [alert rule](gcp-min-architecture/04-monitoring/grafana/scaler/scaling_rule_group.tf) in Grafana which monitors the containers resource usage over their limits or reservations, calculates how many containers we can scale over the currently used container limits and instance resource limits, performs the condition evaluation to trigger scaling up or down. 

Scaling will be triggered as many times as it is possible and needed.

It is also possible to control the amount of the `desired containers number` per instance using the alert rule.

Once the alert rule is triggered, results of all queries and expressions are passed to the WebHook contact point which later communicates with the scaling app. Using labels also allows us to pass `public_ip` to the scaling application.

Also, using multiple notification policies allows us to send a message to Discord channel when the scaling is triggered. 

More information about high-end Math expressions as well as their representation in Python (for better understanding) can be found [here](gcp-min-architecture/04-monitoring/grafana/scaler/settings.tfvars)

Grafana configuration related to the scaling is described in Terraform. Configuration can be found [here](gcp-min-architecture/04-monitoring/grafana/scaler)

**Scaling app**

The [proxy_container-scaler.py](gcp-min-architecture/sources/namecheap-config/home/cpanel_username/proxy_container_scaler/proxy_container_scaler.py) app receives a trigger from Grafana by a webhook with all pre-calculated values and relevant info: what container to scale, direction of scaling and if it's possible at all, `public_ip` for the instance.

Scaling is performed on the particular instance where service has been overloaded for some reason. 

Application uses SSH to pass scaling commands. 

Prior to that, app checks if there is no deploy in progress on the corresponding instance by checking environment variables. If `IN_DEPLOY` set to `True`, scaling won't be performed until it is set to `False`. Deploying logic makes sure this environment variable is controlled.

*P.S. you might think why not to move all logic to the python app. I have several reasons to use Grafana:* 

*1. Considering our limited resources, all applications should be used in their full capacity - Grafana is good in numbers and calculating so why not to let it do it?* 

*2. Grafana already have all required data collected from Prometheus and exporters to calculate the numbers over all instances and can pass all required IPs thanking to the [Service Discovery](#service-discovery)*.

Testing this approach actually didn't show any issues in this scaling logic and I think it is more than appropriate for development environment.

#### Continuous Integration & Continuous Delivery [🗐](#table-of-contents)

The project uses GitHub actions spread to backend, frontend and infra repos to perform all the basic CI/CD steps.

* Any pull request on backend repo triggers [ci_build-test.yaml](backend-repo-devops/.github/workflows/ci_build-test.yaml) which builds Docker image and runs unit tests.
* Merging pull request on backend repo triggers [ci_build-push.yaml](backend-repo-devops/.github/workflows/ci_build-push.yaml) which builds Docker image and pushes it to the GitHub Container Registry.
* For frontend building and pushing image is triggered manually by [ci_build-push.yaml](https://github.com/lovember26/buzzTalk-chat-front-end-2/blob/dev/.github/workflows/ci_build-push.yaml) because the approach was more convenient for frontend developer. Image is pushed to GitHub Container Registry.
* Deploy is triggered manually and performed with the help of [deploy.yaml](.github/workflows/deploy.yaml), dynamic instance public ephemeral IP discovery, SSH requests and bash scripts used both for the [instance launch automation](#instance-template-requires-shutdown-to-edit) and deploy. Deploy workflow actually just runs the bash script on the machine. Also, you are able to use both locally generated `gloud auth access token` or service account for deployment.

#### Ensure apps on Namecheap server always run [🗐](#table-of-contents)

To ensure all apps on Namecheap server are still working after some maintenance or shutdown, I developed a custom script which acts as a healthcheck for all processes indicated in it and restarts the app if it is not running. Runs on cron.

[proc_healthcheck.py](gcp-min-architecture/sources/namecheap-config/home/cpanel_username/proc_healthcheck/proc_healthcheck.py)

</details>

**Author**: Danylo Hotvianskyi
* [LinkedIn](https://www.linkedin.com/in/danylo-hotvianskyi-540630236/)
* [GitHub](https://github.com/danilgotvyansky)
