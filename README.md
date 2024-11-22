# Zolara deployment
This repository contains the deployment files for Zolara. For now, it includes the ansible playbook to deploy the application (composed of the front-end, back-end and database) on a remote server.

## Ansible
The ansible playbook is used to deploy the application on a remote server. The playbook `init-project.yml` is used to clone the repositories, unlock the repositories and build and run the docker containers.

### Roles
#### clone-repo
This role is used to clone the repositories of the front-end, back-end and database. The repositories are cloned in the `/home/admusr/ansible/workspace` directory using the `git` module.

#### unlock-repositories
This role is used to unlock the repositories of the front-end, back-end and database. Here, we use `gnupg` and `git-crypt` to unlock the repositories. The `git-crypt` command is used to unlock the repositories using the `ansible.asc` file.

#### build-project
This role is used to build the docker images and run the containers. The `docker` module is used to build the images and run the containers. 