# README #

### Implementing common tags for all resources ###

The goal is to use a more centralized approach to tagging resources. 
In order to add, remove or change tags one must currently edit a lot 
of files and do a lot of pull requests. By having all the default tags 
in one place replacing tags will just happen automatically next time 
a production code pipeline that uses this repo is run.

### Using this module ###

#### Using common-tags directly in a non-module ####

**main.tf**
```terraform

module "common"  {
  source = "git@github.com:simployer/terraform-modules-common.git"

  # Mandatory variables, replace with var.environment or whatever you use
  environment = "myenvironment" 
  project = "myproject"

}

resource "azurerm_resource_group" "just_another_rg" {
  name     = "pool-rg"
  location = "West Europe"
  tags = merge(
	{
	  mytag = "because I can"
	},
	module.common.tags)
}


```

