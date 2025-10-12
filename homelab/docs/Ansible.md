# Ansible Guide

This guide provides an overview of how to use Ansible for managing and automating tasks in your homelab environment.
Ansible is a powerful open-source automation tool that simplifies configuration management, application deployment, and task automation.

## Overall Approach
1. **Inventory Management**: Ansible uses inventory files to define the hosts and groups of hosts it manages.
2. **Playbooks**: Playbooks are YAML files that define the tasks to be executed on the managed hosts (use IDE integration for "YAML programming").
3. **Roles**: Roles are a way to organize playbooks and related files into reusable components.
4. **Modules**: Ansible provides a wide range of built-in modules to perform various tasks.
5. **Variables**: Variables allow you to customize playbooks and roles for different environments or hosts.

## How to define what goes where?
I have RPis, a Mini PC, and a Laptop. Some services should run on the Mini PC, some on the RPis, and some on the Laptop.
To manage this with Ansible, I define an inventory file that lists the hosts and groups them based on their roles.

### Example Scenario
- hosts: minipc, laptop, rpi4
- services:
    - minipc: vaultwarden, immich, ssh
    - laptop: node-exporter (monitoring only)
    - rpi4: cockpit, pihole, home-assistant, node-exporter, ssh
    - rpi4-admin: cockpit, node-exporter, pihole (fallback if rpi4 is down), ssh

To implement this, I create an inventory file and use group variables to specify which services should be installed on which hosts.
### Inventory File Example
file: `inventory/homelab.ini`
```ini
[minipc]
ansible_connection=local
services=vaultwarden, immich, ssh

# other hosts...
```

### Group Variables Example
Group variables allow you to define variables for specific groups of hosts.
file: `inventory/group_vars/all.yml`
```yaml
all:
  services:
    - node-exporter

minipc:
  services:
    - vaultwarden
    - immich
    - ssh
# other hosts...
```

### Host Variables Example
Host variables allow you to define variables for specific hosts.
file: `inventory/host_vars/rpi4.yml`
```yaml
services:
  - cockpit
  - node-exporter
  - pihole
  - ssh
```

### Playbook Example
Host and group variables can be accessed in playbooks using the `hostvars` and `groups` dictionaries.
In the playbook, I include tasks to install services based on the `services` variable defined for each host.

file: `playbooks/setup_services.yml`
```yaml
- name: Setup services on homelab hosts
  hosts: all
  become: yes

  tasks:
    - name: Install services based on host variables
      include_tasks: install_service.yml
      loop: "{{ hostvars[inventory_hostname].services }}"
      loop_control:
        loop_var: service
        when: hostvars[inventory_hostname].services is defined
        vars:
          service: "{{ service }}"
```