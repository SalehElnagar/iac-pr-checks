# Virtual Network Peering v2 Module

Creates both directions of a same-subscription virtual network peering using conventions-based names.

## Notes

- This module intentionally avoids embedded provider aliases and credentials.
- The Article 1 live stack uses `local_alias = "hub"` and `remote_alias = "spoke"` so the generated names remain readable.
