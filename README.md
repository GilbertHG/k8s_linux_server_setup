# Kubernetes Docker Linux Servers

A Docker Compose setup for creating a Kubernetes-like cluster environment with one master and two worker nodes, each running Ubuntu 22.04 with SSH access.

## Overview

This project creates three Docker containers:
- **k8s-master** (172.20.0.10) - SSH on port 2222
- **k8s-worker1** (172.20.0.11) - SSH on port 2223
- **k8s-worker2** (172.20.0.12) - SSH on port 2224

All containers are connected via a custom bridge network (172.20.0.0/16) and configured with SSH key-based authentication.

## Prerequisites

- Docker and Docker Compose installed
- SSH key pair (ed25519)

## Setup

1. **Generate SSH key** (if you don't have one):
   ```bash
   mkdir -p ~/.ssh && ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N "" -C "gilberthg@local"
   ```

2. **Build and start containers**:
   ```bash
   docker-compose up -d --build
   ```

## Usage

### Access containers via SSH

```bash
# Master node
ssh -p 2222 root@localhost

# Worker nodes
ssh -p 2223 root@localhost  # worker1
ssh -p 2224 root@localhost  # worker2
```

### Validate network connectivity

Run the validation script to verify all containers are running and can communicate:

```bash
./validate_network.sh
```

### Stop containers

```bash
docker-compose down
```

## Container Details

- **Base Image**: Ubuntu 22.04
- **SSH Access**: Root login enabled with password "root" and key-based auth
- **Network**: Custom bridge network (172.20.0.0/16)
- **Privileged Mode**: Enabled for system-level operations

## Notes

- Containers run in privileged mode for Kubernetes-like functionality
- SSH keys are copied from `id_ed25519.pub` during build
- All containers share the same base image and configuration
