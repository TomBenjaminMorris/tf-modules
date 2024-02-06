# tf-modules

Current latest versions:
* static-website - v0.0.3

---
## About
This repo contains a series of Terraform modules, built by myself, that I use in my personal projects.

The following is a list of the available modules:
* **Static Website** - a grouping of CloudFront, S3, & Route53 resources that, together, form the basis of a statically hosted website

## Release Process
To release a new version of a module, merge the latest changes into `master` then run:
* `git tag <module name>-<version>` e.g. `git tag static-website-v0.0.3`
* `git push origin --tags`

## Example usage
### Static Website
Taken from: https://github.com/TomBenjaminMorris/hh_client/blob/master/terraform/main.tf
```
locals {
  project_name      = "admin-hapihour"
  domain_name       = "admin.hapihour.io"
  root_domain_name  = "hapihour.io"
  allowed_locations = ["GB"]
  common_tags = {
    Project = "admin.hapihour.io"
  }
}

module "static-website" {
  source = "git@github.com:TomBenjaminMorris/tf-modules.git//static-website?ref=static-website-v0.0.8"

  project_name      = local.project_name
  domain_name       = local.domain_name
  root_domain_zone  = local.root_domain_name
  allowed_locations = local.allowed_locations
  common_tags       = local.common_tags
}
```
