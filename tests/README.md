# Tests

These tests use the Terraform built-in test provider (`terraform.io/builtin/test`).

## Running Tests

```bash
cd tests/aws
terraform init
terraform test
```

Repeat for `azure`, `gcp`, and `oci` directories.
