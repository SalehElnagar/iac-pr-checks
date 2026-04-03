# Route Table Module

Creates a single route table, its routes, and optional subnet associations.

## Notes

- The module intentionally manages one route table at a time to keep routing changes easy to review.
- Use `subnet_ids` to associate one or more subnets with the route table.
