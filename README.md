<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Usage

Creates a KMS key for DNSSEC. Must be in us-east-1.

Read the more about [Working with customer managed CMKs for DNSSEC](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-configuring-dnssec-cmk-requirements.html)

Using directly (assuming in us-east-1):

```hcl
module "dnssec_kms_key" {
  source = "dod-iac/dnssec-kms-key/aws"

  tags = {
    Application = var.application
    Environment = var.environment
    Automation  = "Terraform"
  }
}
```

If you need to set a separate provider for the us-east-1 region:

```hcl
provider "aws" {
  alias   = "us-east-1"
  region  = "us-east-1"
}

module "dnssec_kms_key" {
  source = "dod-iac/dnssec-kms-key/aws"

  providers = {
    aws = aws.us-east-1
  }

  tags = {
    Application = var.application
    Environment = var.environment
    Automation  = "Terraform"
  }
}
```

## Terraform Version

Terraform 0.13. Pin module version to ~> 1.0.0 . Submit pull-requests to master branch.

Terraform 0.11 and 0.12 are not supported.

## License

This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| aws | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 3.0 |

## Modules

No Modules.

## Resources

| Name |
|------|
| [aws_caller_identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) |
| [aws_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) |
| [aws_kms_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) |
| [aws_kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) |
| [aws_partition](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) |
| [aws_region](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| description | The description of the key as viewed in AWS console. | `string` | `"A KMS key used to encrypt DNS requests."` | no |
| key\_deletion\_window\_in\_days | Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days. | `string` | `30` | no |
| name | The display name of the alias. The name must start with the word "alias" followed by a forward slash (alias/). | `string` | `"alias/dnssec"` | no |
| tags | Tags applied to the KMS key. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| aws\_kms\_alias\_arn | The Amazon Resource Name (ARN) of the key alias. |
| aws\_kms\_alias\_name | The display name of the alias. |
| aws\_kms\_key\_arn | The Amazon Resource Name (ARN) of the key. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
