
# Defines common tags for all projects
locals {
	
	mandatory_tags = {
    		intilityImplementationGuid = "notSet"
    		intilityManaged            = "FALSE"
    		modifiedOn                 = ""
    		environment                = var.environment
    		project                    = var.project
			created-by-terraform	   = true
  	}
	
	#tags = merge(var.tags, local.mandatory_tags)
	tags = merge(local.mandatory_tags, var.tags)
}

# Expose local tags and lifecycle to callers of this module
output "tags" {
  value = local.tags
}


# Allows for adding tags locally
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

