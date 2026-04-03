# Azure Firewall v2 Module

Creates an Azure Firewall Standard or Premium instance backed by an Azure Firewall Policy and a dedicated public IP.

## Notes

- The module is intentionally scoped to the VNet deployment model used in Article 1.
- Policy-based rule management lives in `firewall_policy/` so the firewall resource stays small and future articles can evolve the policy independently.
