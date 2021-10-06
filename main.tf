/**
 * ## Usage
 *
 * Creates a KMS key for DNSSEC. Must be in us-east-1.
 *
 * Read the more about [Working with customer managed CMKs for DNSSEC](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-configuring-dnssec-cmk-requirements.html)
 *
 * Using directly (assuming in us-east-1):
 *
 * ```hcl
 * module "dnssec_kms_key" {
 *   source = "dod-iac/dnssec-kms-key/aws"
 *
 *   tags = {
 *     Application = var.application
 *     Environment = var.environment
 *     Automation  = "Terraform"
 *   }
 * }
 * ```
 *
 * If you need to set a separate provider for the us-east-1 region:
 *
 * ```hcl
 * provider "aws" {
 *   alias   = "us-east-1"
 *   region  = "us-east-1"
 * }
 *
 * module "dnssec_kms_key" {
 *   source = "dod-iac/dnssec-kms-key/aws"
 *
 *   providers = {
 *     aws = aws.us-east-1
 *   }
 *
 *   tags = {
 *     Application = var.application
 *     Environment = var.environment
 *     Automation  = "Terraform"
 *   }
 * }
 * ```
 *
 * ## Terraform Version
 *
 * Terraform 0.13. Pin module version to ~> 1.0.0 . Submit pull-requests to main branch.
 *
 * Terraform 0.11 and 0.12 are not supported.
 *
 * ## License
 *
 * This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.
 */

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

# https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/access-control-managing-permissions.html#KMS-key-policy-for-DNSSEC
data "aws_iam_policy_document" "dnssec" {
  statement {
    sid    = "Route 53 DNSSEC Permissions"
    effect = "Allow"
    actions = [
      "kms:DescribeKey",
      "kms:GetPublicKey",
      "kms:Sign",
    ]
    principals {
      type = "Service"
      identifiers = [
        "api-service.dnssec.route53.aws.internal",
        "dnssec-route53.amazonaws.com",
      ]
    }
    resources = ["*"]
  }

  statement {
    sid    = "Allow Route 53 DNSSEC to CreateGrant"
    effect = "Allow"
    actions = [
      "kms:CreateGrant",
    ]
    principals {
      type = "Service"
      identifiers = [
        "api-service.dnssec.route53.aws.internal",
        "dnssec-route53.amazonaws.com",
      ]
    }
    resources = ["*"]
    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values = [
        true,
      ]
    }
  }

  statement {
    sid = "Enable IAM User Permissions"
    actions = [
      "kms:*",
    ]
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        format(
          "arn:%s:iam::%s:root",
          data.aws_partition.current.partition,
          data.aws_caller_identity.current.account_id
        )
      ]
    }
    resources = ["*"]
  }
}

resource "aws_kms_key" "dnssec" {
  description             = var.description
  deletion_window_in_days = var.key_deletion_window_in_days

  # DO NOT CHANGE THESE SETTINGS
  customer_master_key_spec = "ECC_NIST_P256"
  key_usage                = "SIGN_VERIFY"

  policy = data.aws_iam_policy_document.dnssec.json
  tags   = var.tags
}

resource "aws_kms_alias" "dnssec" {
  name          = var.name
  target_key_id = aws_kms_key.dnssec.key_id
}
