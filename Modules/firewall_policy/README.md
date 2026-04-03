# Firewall Policy Module

Creates an Azure Firewall Policy and optional rule collection groups using the shared conventions modules for naming and tagging.

## Notes

- This module is the policy-based replacement for the legacy inline rule pattern in `azure_firewall/`.
- Rule collection groups are first-class resources, so they get their own conventions-driven names.
- DNS proxy settings are optional but included so later articles can move toward FQDN-based network rules cleanly.
