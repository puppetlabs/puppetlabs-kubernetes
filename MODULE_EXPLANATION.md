# Puppetlabs Kubernetes Module - Comprehensive Explanation

## Overview

The **puppetlabs-kubernetes** module is a Puppet module designed to automate the installation, configuration, and management of Kubernetes clusters. It provides a declarative way to deploy production-ready Kubernetes infrastructure using Puppet's configuration management capabilities.

**Current Version:** 8.1.0  
**Author:** Puppetlabs  
**License:** Apache-2.0  
**Repository:** https://github.com/puppetlabs/puppetlabs-kubernetes

## What Does This Module Do?

This module helps you:

1. **Bootstrap Kubernetes Clusters** - Automatically set up Kubernetes control plane and worker nodes
2. **Configure Container Runtimes** - Support for Docker and containerd
3. **Manage Networking** - Deploy CNI (Container Network Interface) providers like Calico, Flannel, Weave, and Cilium
4. **Setup High Availability** - Configure multi-controller clusters with etcd
5. **Manage Certificates** - Handle cluster PKI infrastructure automatically
6. **Deploy Add-ons** - Optional installation of Kubernetes Dashboard and other components

## Key Technologies & Components

### Core Technologies
- **Kubernetes** (versions 1.10.x and higher)
- **kubeadm** - Kubernetes cluster bootstrapping tool
- **Container Runtimes:**
  - Docker (officially supported)
  - containerd (for advanced users)
- **etcd** - Distributed key-value store for cluster state

### Container Network Interface (CNI) Providers Supported
- **Flannel** - Simple overlay network
- **Weave** - Network plugin with built-in mesh networking
- **Calico** - Network policy and network security
- **Cilium** - eBPF-based networking and security

## Architecture

### Node Types

The module supports two primary node types:

1. **Controller (Control Plane) Nodes**
   - Run the Kubernetes API server
   - Host etcd for cluster state
   - Manage cluster scheduling and control loops
   - Recommended: 3, 5, or 7 nodes for production HA

2. **Worker Nodes**
   - Run application workloads
   - Execute pods scheduled by controllers
   - Can scale horizontally based on demand

**Important:** A node cannot be both a controller and worker simultaneously.

### Key Components Managed

```
┌─────────────────────────────────────────────────┐
│            Kubernetes Cluster                    │
├─────────────────────────────────────────────────┤
│                                                  │
│  ┌──────────────┐        ┌──────────────┐      │
│  │ Controller 1 │        │  Worker 1    │      │
│  │              │        │              │      │
│  │ - API Server │        │ - Kubelet    │      │
│  │ - Scheduler  │        │ - Pods       │      │
│  │ - Controller │◄──────►│ - CNI        │      │
│  │   Manager    │        │              │      │
│  │ - etcd       │        └──────────────┘      │
│  └──────────────┘                               │
│         │                                        │
│         │                ┌──────────────┐      │
│         │                │  Worker 2    │      │
│         └───────────────►│              │      │
│                          │ - Kubelet    │      │
│                          │ - Pods       │      │
│                          │ - CNI        │      │
│                          └──────────────┘      │
└─────────────────────────────────────────────────┘
```

## How It Works

### Installation Flow

1. **Preparation Phase**
   ```
   - Install required OS packages (kubectl, kubelet, kubeadm)
   - Setup container runtime (Docker or containerd)
   - Configure system prerequisites (swap off, kernel modules)
   - Setup package repositories
   ```

2. **Certificate Generation**
   ```
   - Kubetool generates PKI certificates
   - Creates discovery tokens for node joining
   - Configures etcd certificates for HA
   ```

3. **Cluster Bootstrap**
   ```
   - Initialize first controller with kubeadm
   - Setup etcd cluster (for HA)
   - Deploy CNI network provider
   - Configure RBAC roles
   ```

4. **Node Joining**
   ```
   - Workers join using discovery token
   - Additional controllers join the control plane
   - Nodes register with the cluster
   ```

## Configuration Tool: Kubetool

The module includes **Kubetool**, a Docker-based configuration generator that automates:

- Generation of Hiera YAML configuration files
- PKI certificate creation for secure cluster communication
- Discovery token generation for node joining
- Operating system-specific configurations

### Kubetool Usage Example

```bash
docker run --rm -v $(pwd):/mnt \
  -e OS=ubuntu \
  -e VERSION=1.10.2 \
  -e CONTAINER_RUNTIME=docker \
  -e CNI_PROVIDER=cilium \
  -e CNI_PROVIDER_VERSION=1.4.3 \
  -e ETCD_INITIAL_CLUSTER=controller1:172.17.10.101,controller2:172.17.10.102 \
  -e ETCD_IP="%{networking.ip}" \
  -e KUBE_API_ADVERTISE_ADDRESS="%{networking.ip}" \
  -e INSTALL_DASHBOARD=true \
  puppet/kubetool:8.1.0
```

## Usage Examples

### Setting Up a Controller Node

```puppet
class {'kubernetes':
  controller                 => true,
  kubernetes_version         => '1.10.2',
  controller_address         => '172.17.10.101:6443',
  kube_api_advertise_address => "%{networking.ip}",
  etcd_ip                    => "%{networking.ip}",
  etcd_initial_cluster       => 'controller1:172.17.10.101',
  cni_provider               => 'calico',
  install_dashboard          => true,
}
```

### Setting Up a Worker Node

```puppet
class {'kubernetes':
  worker             => true,
  controller_address => '172.17.10.101:6443',
  token              => 'your-bootstrap-token',
  discovery_token_hash => 'sha256:your-discovery-hash',
}
```

### Configuring a Specific CNI Provider (Flannel)

```yaml
# In Hiera (data/common.yaml)
kubernetes::cni_network_provider: https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
kubernetes::cni_pod_cidr: 10.244.0.0/16
kubernetes::cni_provider: flannel
```

## Key Features

### 1. High Availability Support
- Multi-master control plane configuration
- Distributed etcd cluster management
- Automatic failover capabilities

### 2. Security
- PKI certificate management
- RBAC (Role-Based Access Control) configuration
- Service account token management
- Secure communication between components

### 3. Networking Flexibility
- Multiple CNI provider options
- Configurable pod and service CIDR ranges
- Support for network policies

### 4. Container Runtime Options
- **Docker**: Traditional, well-supported runtime
- **containerd**: Modern, lightweight CRI-compliant runtime

### 5. Customization
- Extra arguments for API server, controller manager, scheduler
- Custom kubelet configurations
- Volume mounts for additional functionality
- Taints and labels for node scheduling

## Module Structure

```
puppetlabs-kubernetes/
├── manifests/           # Puppet manifests (core logic)
│   ├── init.pp          # Main class
│   ├── config/          # Configuration classes
│   ├── packages.pp      # Package management
│   ├── repos.pp         # Repository setup
│   ├── service.pp       # Service management
│   ├── cluster_roles.pp # RBAC configuration
│   ├── kube_addons.pp   # Kubernetes add-ons
│   ├── kubeadm_init.pp  # Cluster initialization
│   └── kubeadm_join.pp  # Node joining
├── templates/           # Configuration file templates
├── tasks/              # Bolt tasks (Kubernetes API operations)
├── plans/              # Bolt plans (orchestration)
├── lib/                # Ruby helper functions
├── data/               # Hiera data files
├── examples/           # Usage examples
├── spec/               # RSpec tests
├── tooling/            # Kubetool (config generator)
└── types/              # Custom Puppet types
```

## Important Parameters

### Essential Configuration
- `kubernetes_version` - Kubernetes version to install (X.Y.Z format)
- `controller` - Boolean: Is this a controller node?
- `worker` - Boolean: Is this a worker node?
- `container_runtime` - 'docker' or 'cri_containerd'
- `cni_provider` - CNI plugin to use

### Networking
- `cni_pod_cidr` - Pod network CIDR (e.g., 10.244.0.0/16)
- `service_cidr` - Service VIP range (default: 10.96.0.0/12)
- `kube_api_advertise_address` - IP for API server

### Cluster Joining
- `token` - Bootstrap token for joining ([a-z0-9]{6}.[a-z0-9]{16})
- `discovery_token_hash` - CA cert hash for validation
- `controller_address` - Controller endpoint (IP:port)

### etcd Configuration (for HA)
- `etcd_ip` - IP address for etcd member
- `etcd_initial_cluster` - Comma-separated controller list
- `etcd_version` - etcd version to install

## Supported Operating Systems

- **RedHat/CentOS** 7.x
- **Ubuntu** 18.04, 20.04, 22.04
- **Debian** 10, 11

## Requirements

- **Puppet** >= 7.0.0 (< 9.0.0)
- **Ruby** >= 2.3.0
- **Kubernetes** >= 1.10.x

## Module Dependencies

This module requires several other Puppet modules:

- `puppetlabs-stdlib` - Standard library functions
- `puppetlabs-apt` - APT repository management
- `puppet-archive` - Archive file handling
- `puppet-augeasproviders_sysctl` - Sysctl management
- `puppet-augeasproviders_core` - Augeas core providers
- `puppet-kmod` - Kernel module management

## Advanced Features

### 1. Custom API Server Arguments

```puppet
apiserver_extra_arguments => [
  '--enable-admission-plugins=PodSecurityPolicy',
  '--audit-log-path=/var/log/kubernetes/audit.log',
]
```

### 2. Extra Volume Mounts

```puppet
apiserver_extra_volumes => {
  'audit-logs' => {
    hostPath  => '/var/log/kubernetes',
    mountPath => '/var/log/kubernetes',
    readOnly  => false,
    pathType  => 'DirectoryOrCreate'
  },
}
```

### 3. Node Taints (for dedicated workloads)

```puppet
node_extra_taints => [
  {
    'key'      => 'dedicated',
    'value'    => 'gpu-workload',
    'effect'   => 'NoSchedule',
    'operator' => 'Equal'
  }
]
```

### 4. Proxy Configuration

```puppet
http_proxy  => 'http://proxy.example.com:8080',
https_proxy => 'http://proxy.example.com:8080',
no_proxy    => 'localhost,127.0.0.1,.example.com',
```

## Bolt Tasks

The module includes 400+ Bolt tasks for Kubernetes API operations, including:

- Creating/deleting Deployments, Services, Pods
- Managing ConfigMaps and Secrets
- RBAC management (Roles, RoleBindings, ClusterRoles)
- Network Policies
- Storage Classes and Volume Attachments
- And many more...

Example task execution:
```bash
bolt task run swagger_k8s_create_core_v1_namespaced_pod \
  kube_api="https://k8s-api.example.com:6443" \
  namespace="default" \
  body=@pod-definition.json
```

## Testing & Validation

### Validation Commands

```bash
# Validate module metadata
pdk validate metadata --puppet-version='7.0.0'

# Validate Puppet code
pdk validate puppet --puppet-version='7.0.0'

# Validate Ruby code
pdk validate ruby lib --puppet-version='7.0.0'

# Run unit tests
pdk test unit --puppet-version='7.0.0'
```

## Common Use Cases

### 1. Development Cluster
- Single controller node
- Multiple worker nodes
- Docker runtime
- Flannel networking

### 2. Production HA Cluster
- 3 or 5 controller nodes
- Separate etcd cluster
- containerd runtime
- Calico with network policies
- Multiple availability zones

### 3. Edge/IoT Deployment
- Lightweight containerd runtime
- Minimal resource footprint
- Single controller
- Few worker nodes

## Troubleshooting

### Common Issues

1. **Hiera Data Not Found**
   - Ensure `{OS}.yaml` and `{hostname}.yaml` are in the data directory
   - Verify `hiera.yaml` configuration

2. **Node Join Failures**
   - Check discovery token hasn't expired (default: 24h)
   - Verify controller_address is reachable
   - Confirm discovery_token_hash matches

3. **Network Issues**
   - Ensure CNI provider is properly deployed
   - Check pod CIDR doesn't conflict with node network
   - Verify firewall rules allow cluster communication

## Best Practices

1. **Always use Kubetool** to generate configuration
2. **Use Hiera** for environment-specific configuration
3. **Deploy HA clusters** (3+ controllers) for production
4. **Backup etcd** regularly
5. **Pin versions** explicitly (kubernetes_version, docker_version)
6. **Use containerd** for new deployments (more efficient)
7. **Implement network policies** for security
8. **Monitor cluster health** with appropriate tooling

## Learning Resources

- **Kubernetes Documentation**: https://kubernetes.io/docs/
- **Module Repository**: https://github.com/puppetlabs/puppetlabs-kubernetes
- **Puppet Forge**: https://forge.puppetlabs.com/puppetlabs/kubernetes
- **Contributing Guide**: See CONTRIBUTING.md in the repository

## Getting Help

- **Issues**: https://github.com/puppetlabs/puppetlabs-kubernetes/issues
- **Puppet Community**: https://puppet.com/community/
- **Kubernetes Community**: https://kubernetes.io/community/

## Summary

The puppetlabs-kubernetes module provides a robust, automated solution for deploying and managing Kubernetes clusters using Puppet's declarative configuration management approach. It abstracts away the complexity of manual Kubernetes setup while providing flexibility for customization and supporting both development and production use cases.

Key strengths:
- ✅ Automated cluster bootstrapping with kubeadm
- ✅ High availability support
- ✅ Multiple CNI providers
- ✅ Comprehensive configuration options
- ✅ Production-ready security defaults
- ✅ Extensive Bolt task library for Kubernetes operations
- ✅ Well-documented and actively maintained

This module is ideal for organizations already using Puppet who want to standardize their Kubernetes deployments and leverage their existing infrastructure-as-code practices.
