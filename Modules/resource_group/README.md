# Resource Group Module

Creates a resource group using the shared naming and tagging conventions modules.

## Notes

- Use `name` to supply an explicit resource group name.
- Leave `name = null` to let the module generate a conventions-based name.
- This module is used by the Article 1 Terragrunt live stack as the shared foundation resource group.
