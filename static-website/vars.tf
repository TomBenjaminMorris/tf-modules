variable "project_name" {
  type        = string
  description = "The name of the project."
}

variable "domain_name" {
  type        = string
  description = "The domain name for the website."
}

variable "root_domain_zone" {
  type        = string
  description = "The root domain name for the website."
}

variable "allowed_locations" {
  type        = list(string)
  description = "List of allowed countries"
  default     = []
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags you want applied to all components."
}