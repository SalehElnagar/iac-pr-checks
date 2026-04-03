config {
  force = false
  disabled_by_default = true
}

# Keep lint deterministic and offline-safe for PR checks.
rule "terraform_required_version" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_typed_variables" {
  enabled = true
}
