# Kalilix KubeVirt Test Environment

This directory contains KubeVirt manifests for **testing and validating** the Kalilix Lix/Nix flake bootstrap automation. These resources deploy minimal Ubuntu 24.04 VMs that automatically bootstrap the complete Kalilix development environment via cloud-init.

> **Purpose**: Validate `mise run bootstrap` works correctly on clean Ubuntu systems. Not for production use.
>
> **For Kalilix documentation**, see [../README.md](../README.md)

## Quick Start

### Prerequisites

- Kubernetes cluster with KubeVirt installed
- kubectl configured with cluster access
- SSH public key at `~/.ssh/id_ed25519.pub`

### Deploy from GitHub

```bash
# 1. Create SSH key secret (required)
kubectl create secret generic kargo-sshpubkey-kali \
  --from-file=key1=$HOME/.ssh/id_ed25519.pub \
  --namespace=default

# 2. Deploy from main branch
kubectl kustomize https://github.com/scopecreep-zip/kalilix//kubevirt?ref=main | kubectl apply -f -

# Or deploy from feature branch for testing
kubectl kustomize https://github.com/scopecreep-zip/kalilix//kubevirt?ref=feat/kubevirt-bootstrap | kubectl apply -f -
```

### Deploy from Local Clone

```bash
# 1. Create SSH key secret
kubectl create secret generic kargo-sshpubkey-kali \
  --from-file=key1=$HOME/.ssh/id_ed25519.pub

# 2. Deploy from local directory
kubectl kustomize kubevirt | kubectl apply -f -
```

## Monitor Bootstrap Progress

```bash
# Watch VM creation
kubectl get vm,vmi,dv,pvc -l app=kalilix -w

# Get VM IP address (once running)
kubectl get vmi kalilix -o jsonpath='{.status.interfaces[0].ipAddress}'

# SSH into VM
ssh kali@<VM_IP>

# Watch cloud-init bootstrap logs
tail -f /var/log/cloud-init-output.log
```

## Validate Bootstrap Success

Once cloud-init completes (~10-12 minutes), verify the environment:

```bash
# Check environment status
cd ~/.kalilix
mise run status

# Enter development shell (should be instant - prebuilt)
nix develop .#full

# Verify tools are available
which pulumi go cargo python node
```

Expected results:
- ✅ Lix 2.93.0 installed
- ✅ Experimental features enabled
- ✅ Flake evaluation successful
- ✅ Full dev shell prebuilt
- ✅ All language toolchains available

## What Gets Tested

The cloud-init automation validates:

1. **Platform Detection**: Ubuntu 24.04 native Linux environment
2. **Mise Installation**: Via `curl https://mise.run | sh`
3. **Repository Clone**: From GitHub branch specified in userdata
4. **Bootstrap Execution**: `mise run bootstrap` completes without errors
5. **Cache Configuration**: Binary caches configured, `accept-flake-config = true`
6. **Trusted Users**: Current user added to `/etc/nix/nix.conf`
7. **Flake Validation**: `nix flake check --impure` succeeds
8. **Shell Prebuild**: `nix develop .#full --command true` caches all packages

## Cleanup

```bash
# Delete VM and resources
kubectl delete vm kalilix
kubectl delete pvc kalilix-root
kubectl delete secret kalilix-userdata kargo-sshpubkey-kali
```

## Files

| File | Purpose |
|------|---------|
| `kustomization.yaml` | Kustomize configuration for deployment |
| `kalilix-userdata.yaml` | Cloud-init configuration (bootstrap automation) |
| `ubuntu-kalilix-flake-minimal.yaml` | KubeVirt VirtualMachine specification |

## Customization

### Test Different Branch

Edit `kalilix-userdata.yaml` line 48 to change the branch:

```yaml
runcmd:
  - sudo -u kali git clone -b YOUR_BRANCH https://github.com/scopecreep-zip/kalilix.git /home/kali/.kalilix
```

Then deploy locally:

```bash
kubectl kustomize kubevirt | kubectl apply -f -
```

### Change VM Resources

Edit `ubuntu-kalilix-flake-minimal.yaml`:

```yaml
resources:
  requests:
    memory: 16Gi  # Increase for faster builds
cpu:
  cores: 6       # More cores = faster Nix builds
```

### Use Different Base Image

Change the container image in `ubuntu-kalilix-flake-minimal.yaml`:

```yaml
source:
  registry:
    url: docker://docker.io/containercraft/ubuntu:24-04  # Or any Ubuntu 24.04 image
```

## Troubleshooting

### VM Not Starting

```bash
# Check DataVolume import status
kubectl get dv kalilix-root
kubectl describe dv kalilix-root

# Check VMI events
kubectl describe vmi kalilix
```

### Bootstrap Fails

```bash
# SSH into VM and check logs
ssh kali@<VM_IP>
tail -f /var/log/cloud-init-output.log

# Common issues:
# - Network connectivity (check DNS, outbound HTTPS)
# - Insufficient resources (needs 16GB RAM for full shell)
# - GitHub rate limiting (use authenticated clone)
```

### Cloud-Init Not Running

```bash
# Check cloud-init status
cloud-init status --wait

# View full cloud-init output
cat /var/log/cloud-init-output.log

# Re-run cloud-init manually (testing only)
sudo cloud-init clean --logs
sudo cloud-init init
sudo cloud-init modules --mode=config
sudo cloud-init modules --mode=final
```

## Testing Workflow

1. **Make changes** to bootstrap automation in `.config/mise/toml/nix.toml` or `.config/mise/tasks/nix-bootstrap`
2. **Commit and push** to feature branch
3. **Update** `kalilix-userdata.yaml` to reference your branch
4. **Deploy** VM: `kubectl kustomize kubevirt | kubectl apply -f -`
5. **Monitor** cloud-init: `ssh kali@<VM_IP> tail -f /var/log/cloud-init-output.log`
6. **Verify** bootstrap success: `mise run status`, `nix develop .#full`
7. **Cleanup** and iterate: `kubectl delete vm kalilix`

## Network Configuration

The VM uses bridge networking via Multus CNI:

```yaml
networks:
  - name: enp1s0
    multus:
      networkName: br0-network-attachment
```

**Requirements:**
- Network Attachment Definition `br0-network-attachment` must exist
- VM gets IP via DHCP on the bridged network
- Direct LAN access for SSH and internet connectivity

## VM Specifications

| Setting | Value | Notes |
|---------|-------|-------|
| **OS** | Ubuntu 24.04 LTS | From containercraft/ubuntu:24-04 |
| **CPU** | 6 threads (1 socket × 1 core × 6 threads) | Adjust for build performance |
| **Memory** | 16GB | Required for full dev shell |
| **Disk** | 64GB | Persistent via hostpath-provisioner |
| **User** | kali:kali | Passwordless sudo |
| **Storage Class** | hostpath-provisioner | Change for your cluster |

## Integration with Main Project

This directory is **not part of the main Kalilix deployment**. It exists solely to:

- Validate bootstrap automation on clean systems
- Test cross-platform compatibility (Ubuntu 24.04 validated)
- Provide CI/CD testing infrastructure
- Enable rapid iteration on bootstrap scripts

For actual Kalilix usage, see the main [README.md](../README.md).

## Related Documentation

- [Main README](../README.md) - Kalilix architecture and usage
- [Cloud-init Docs](https://cloudinit.readthedocs.io/) - Cloud-init reference
- [KubeVirt Docs](https://kubevirt.io/) - Virtual machine management
- [Kustomize Docs](https://kustomize.io/) - Kustomization reference
