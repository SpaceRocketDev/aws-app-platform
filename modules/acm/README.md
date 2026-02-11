# ACM Module

Terraform module that provisions and validates an **AWS Certificate Manager (ACM)** certificate for use with a public **Application Load Balancer (ALB)**.

This module is intended to be consumed by upstream stacks (for example, your base stack) and then passed into downstream modules (for example, `modules/alb` as `main_cert_arn`).

## What This Module Provisions

* An ACM certificate (`aws_acm_certificate`)
* DNS validation records in Route53 (`aws_route53_record`) for each domain/SAN
* Certificate validation resource (`aws_acm_certificate_validation`)
* Outputs for the validated certificate ARN and related metadata

## Usage

### Example

```hcl
module "acm_certs" {
  source = "../../modules/acm"
  acm_config = local.acm_config
}

locals {
  acm_config = {
    cert_arn = var.cert_arn
  }
}
```

> [!NOTE]
> In this demo, `local.acm_config` only includes `cert_arn`, which implies the certificate is already created externally and the module is being used as a thin wrapper.
>
> In a typical setup, the ACM module would instead create the certificate from `domain_name` and `subject_alternative_names` and perform DNS validation.

## Inputs

This module is configured using a single object input: `acm_config`.

| Name       | Description                                                   | Type   | Default            | Required |
| ---------- | ------------------------------------------------------------- | ------ | ------------------ | -------- |
| acm_config | Composite config for ACM certificate creation and validation. | object | see `variables.tf` | No       |

---

## acm_config schema

| Field    | Description                                                                                    | Type   | Required |
| -------- | ---------------------------------------------------------------------------------------------- | ------ | -------- |
| cert_arn | Existing ACM certificate ARN to reference (if you are not creating a new cert in this module). | string | no       |

> [!IMPORTANT]
> If this module is responsible for creating the certificate (recommended for end to end automation), it should accept domain inputs (for example: `domain_name`, `subject_alternative_names`) and a Route53 zone context for DNS validation.
>
> If you keep the “wrapper” style that only takes `cert_arn`, then **validation and issuance happen outside Terraform** and this module should clearly document that boundary.

## Outputs

| Name     | Description                                                   |
| -------- | ------------------------------------------------------------- |
| cert_arn | ARN of the ACM certificate (validated and ready for ALB use). |

## Notes

* ACM certificates for an ALB must be in the **same region** as the ALB.
* If you use DNS validation, ensure the domain is hosted in Route53 and Terraform has permissions to create validation records.
* Downstream usage: pass this cert ARN into `modules/alb` as `alb_config.main_cert_arn`.

## Related Projects

* `modules/alb` consumes the ACM certificate ARN as `main_cert_arn` for the HTTPS listener.
* `modules/network` typically supplies the hosted zone context indirectly via your base stack.
