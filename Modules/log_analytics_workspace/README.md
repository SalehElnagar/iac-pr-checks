# Log Analytics Workspace Module

Creates a Log Analytics workspace using the shared conventions modules for naming and tagging.

## Notes

- The default SKU is `PerGB2018`.
- `daily_quota_gb` is nullable so the live stack can leave the quota unlimited unless explicitly configured.
