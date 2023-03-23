
variable "tags" {
  description = "Tags from calling module"
  type        = map(string)
  default     = {}
}

# Enforces environment and project to be set
variable "environment" {
  description = "Development environment"
  type        = string
}

variable "project" {
  description = "project"
  type        = string

}
