# Container Management in Homelab

To efficiently manage and deploy services in the homelab environment, containerization is utilized. Containers provide a lightweight and portable way to run applications consistently across different environments.

## Current Solution
1. **Ansible**: Used for setting up hosts, software prerequisites, and provisioning configuration files and secrets. Main orchestration tool.
2. **Make/Scripts**: Custom scripts are used to manage cloud resources and secrets, providing flexibility and control. The main tool to trigger anything is `make` (see [Makefile](./Makefile) and run `make help`).
3. **Docker/Podman Compose**: Employed for defining and running multi-container Docker applications.
4. **Portainer**: Optionally used for managing Docker environments through a web-based interface.

## Requirements
- **Repeatable Deployments**: Ensure that services can be easily redeployed with minimal effort. On different hardware or after system changes, the deployment process should remain consistent.
- **Configuration Management**: Store all configuration files in `git` and use Ansible for automation. This ensures that configurations are version-controlled and can be easily updated or rolled back.
- **Backup and Restore**: Implement a robust backup strategy to safeguard data and configurations. This includes regular backups of container volumes, configuration files, and any other critical data.
- **Secret Management**: Use secret management tools to handle sensitive information such as passwords, API keys, and certificates securely.

## Tooling Options

The following table outlines various container orchestration and management tools, along with their pros and cons.

| Tool | Pros | Cons | Automation Potential ⭐️ 3-star rating | Management Effort 🟢🟡🔴 |
|------|------|------|-----|----------------|
| Docker/Podman Compose | Simple to set up and use, widely supported, good for small to medium deployments | Limited scalability, manual management of multiple containers | ⭐️⭐️⭐️ | 🟢 |
| Ansible | Powerful automation, integrates well with existing config management, good for repeatable deployments | Requires learning curve, not a full orchestration solution | ⭐️⭐️⭐️⭐️ | 🟡 |
| Portainer | User-friendly UI, easy to manage containers and images, supports Docker and Swarm | Limited advanced features, may not be suitable for complex deployments | ⭐️⭐️⭐️ | 🟢 |
| Ansible + Docker/Podman Compose | Combines the simplicity of Compose with the automation of Ansible, good for small to medium deployments | Requires knowledge of both tools, may not scale well for very large deployments | ⭐️⭐️⭐️⭐️ | 🟡 |
| Terraform | Infrastructure as Code, good for managing cloud resources, supports multiple providers | Not specifically designed for container orchestration, requires additional tools for full container management | ⭐️⭐️ | 🟡 |
| Kubernetes | Highly scalable, robust ecosystem, supports complex deployments | Steep learning curve, high management overhead, may be overkill for small homelabs | ⭐️⭐️⭐️⭐️⭐️ | 🔴 |

## Solution Assessment
- **Docker/Podman Compose**: Ideal for the current scale of the homelab. It allows for quick setup and management of containers with minimal overhead. Configuration files can be stored in `git`, and Ansible can be used to automate the deployment process.
- **Portainer**: Can be used on top of Docker/Podman for easier management through a graphical interface. Make sure it does not get in the way of automation.

**Decision**: Start with Docker/Podman Compose for container management, leveraging Ansible for automation and configuration management. This approach balances ease of use, automation potential, and management effort effectively for the homelab environment.

**Revisit 1**. After playing around with Ansible for a while, I learned managing cloud resources is not one of its strengths. I had to back it up with script, which provides a lot of flexibility.

**Decision 1:** Use Ansible to setup software prerequisites and provision configuration files and secrets. Do not use Ansible to manage/create cloud resources and cloud secrets. Use scripts to manage cloud resources and secrets.

## Deployment Flow
1. **Define Services**: List all services to be containerized and their respective configurations.
2. **Create Docker/Podman Compose Files**: Write `docker-compose.yml` or `podman-compose.yml` files for each service, specifying images, volumes, networks, and environment variables.
3. **Store Configuration in Git**: Commit all compose files and related configuration files to a `git` repository for version control.
4. **Automate with Ansible**: Create Ansible playbooks to automate the deployment of containers using the compose files. This includes tasks for pulling images, starting containers, and managing updates.
5. **Implement Backup Strategy**: Set up regular backups for container volumes and configuration files. Use tools like `rsync`, `cron`, or dedicated backup solutions.
6. **Manage Secrets**: Use secret management tools (e.g., Vaultwarden) to securely store and retrieve sensitive information needed by the containers. \
**Update:** For simplicity, I am now using Keychain/Keyring on Linux to manage master passwords. Anything else is managed as encrypted files (outside of git) and synced to/from cloud storage. This decision can be revisited later.

7. **Monitor and Maintain**: Regularly monitor container health and performance. Update services as needed and ensure backups are functioning correctly.
8. **Documentation**: Document the entire deployment process, including how to add new services, update existing ones, and restore from backups. This documentation should be stored in the `homelab/docs` directory for easy access.
