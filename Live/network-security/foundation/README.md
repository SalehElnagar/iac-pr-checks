# Network Security Foundation

This Terragrunt stack prepares a policy-based Azure Firewall hub-and-spoke baseline for the `mvp` subscription key.

## Stack layout

- `resource-group`: shared foundation resource group
- `log-analytics`: Log Analytics workspace for firewall diagnostics
- `hub-network`: hub VNet with `AzureFirewallSubnet`
- `spoke-network`: workload spoke VNet with one subnet
- `peering`: bidirectional hub/spoke VNet peering
- `firewall-policy`: Azure Firewall Policy and minimal rule collection groups
- `firewall`: Azure Firewall Standard plus public IP
- `routing`: route table and subnet association to steer selected traffic through the firewall
- `diagnostics`: firewall diagnostics to Log Analytics
- `test-vm`: optional Linux VM wiring, disabled by default

## Configuration model

- Shared Terragrunt behavior lives in [`../../root.hcl`](../../root.hcl).
- Long configuration is kept in YAML files next to this stack:
  - `env.yaml`
  - `region.yaml`
  - `tags.yaml`
  - `network.yaml`
  - `firewall.yaml`
  - `diagnostics.yaml`
  - `vm.yaml`
- Subscription, backend, and optional git module ref settings live in [`../../subscription.yaml`](../../subscription.yaml).

## Planning order

Run units in this order when reviewing or planning:

1. `resource-group`
2. `log-analytics`
3. `hub-network`
4. `firewall-policy`
5. `firewall`
6. `spoke-network`
7. `peering`
8. `routing`
9. `diagnostics`
10. `test-vm` if enabled

## Notes

- `test-vm` uses the existing `linux_vm` module and is disabled by default via [`vm.yaml`](./vm.yaml).
- The stack defaults to the local [`Modules/`](../../../Modules) tree so Terragrunt validates the code in this checkout. Set `TG_MODULE_SOURCE_PREFIX` to a git source if you want to consume a published module release instead.
- `subscription.yaml` keeps the git ref value used when `TG_MODULE_SOURCE_PREFIX` points at a git source and now defaults that ref to `main`.
- DNS proxy is enabled in the firewall policy, and the spoke VNet now points DNS at the firewall private IP when [`network.yaml`](./network.yaml) sets `spoke.use_firewall_dns_proxy: true`.
- Resource names use the conventions module's mapped location short code. With `region.yaml` set to `centralus`, names will include `CUS` while Azure resource `location` remains `centralus`.
- Backend state is stored in Azure Blob Storage and must exist before the first Terragrunt apply.
- The flattened repo layout keeps `backend.state_key_prefix` set to `azure/mvp` so the published article paths do not require state migration.
