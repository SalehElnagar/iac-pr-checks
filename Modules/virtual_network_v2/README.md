# Virtual Network v2 Module

Creates a single virtual network and a map of subnets without the legacy module's extra DNS zone, NAT remote-state dependency, or missing external source references.

## Notes

- Reserved Azure subnet names should be passed through `subnets[*].name`. The module still routes that request through the shared conventions module by using `options.name_override`.
- Routing is intentionally kept outside this module so Article 1 can review network topology and traffic control as separate Terragrunt units.
