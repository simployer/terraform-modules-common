# README #

### Implementing common tags for all resources ###

The goal is to use a more centralized approach to tagging resources. 
In order to add, remove or change tags one must currently edit a lot 
of files and do a lot of pull requests. By having all the default tags 
in one place replacing tags will just happen automatically next time 
a production code pipeline that uses this repo is run.

### Lifecycle blocks ###

No, you cant get anything for free when it comes to the lifecycle block. It does not allow for anythong else other than attribute access and constant key indexing. So we can't have a setup where we add specific tags to lifecycle->ignore_changes automatically from this module.

Here is the error message, enjoy: `A single static variable reference is required: only attribute access and indexing with constant keys. No calculations, function calls, template expressions, etc are allowed here.`

### Using this module ###



#### Using common-tags directly in a non-module ####

**main.tf**
```terraform

provider "azurerm" { 
  features {} 
}


module "common-tags"  {
  source = "bitbucket.org/simployer/public-common-tags.git"

  # Mandatory variables, replace with var.environment or whatever you use
  environment = "myenvironment" 
  project = "myproject"

}

locals {
	tags      = module.common-tags.tags
}

resource "azurerm_resource_group" "just_another_rg" {
  name     = "pool-rg"
  location = "West Europe"
  tags = merge(
	{
	  why = "because I can"
	},
	local.tags)
}

output "tags_on_rg" {
  value = azurerm_resource_group.just_another_rg.tags
}


```

Resulting in this:

```bash

$ terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the
following symbols:
  + create

Terraform will perform the following actions:

  # azurerm_resource_group.just_another_rg will be created
  + resource "azurerm_resource_group" "just_another_rg" {
      + id       = (known after apply)
      + location = "westeurope"
      + name     = "pool-rg"
      + tags     = {
          + "created-by-terraform"       = "true"
          + "environment"                = "myenvironment"
          + "intilityImplementationGuid" = "notSet"
          + "intilityManaged"            = "FALSE"
          + "modifiedOn"                 = ""
          + "project"                    = "myproject"
          + "why"                        = "because I can"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + tags_on_rg = {
      + "created-by-terraform"       = "true"
      + "environment"                = "myenvironment"
      + "intilityImplementationGuid" = "notSet"
      + "intilityManaged"            = "FALSE"
      + "modifiedOn"                 = ""
      + "project"                    = "myproject"
      + "why"                        = "because I can"
    }

```

#### If developing a module ####

You can incorporate common-tags into another module. The example below 
provides support for setting tags in your top level code, ship those tags to the module, which ships them to common-tags which adds the default tags and then you use the your-module.tags in the top level code.


**modules/mymodule/variables.tf**

```terraform

module "common-tags"  {
  source = "bitbucket.org/simployer/common-tags.git"

  # Mandatory variables
  environment = var.environment
  project = var.project

  # My local tag
  tags = var.mycustomtags
}

locals {
	tags      = module.common-tags.tags
}

variable "environment" {
  description = "Development environment"
  type        = string
}

variable "project" {
  description = "project"
  type        = string
}

variable "name" {
  description = "name"
  type        = string
}

# Support for one more level of includes
output "tags" {
	value = local.tags
}

variable "mycustomtags" {
	description = "tags as argument if this is used as a module"
	type = map(string)
	default = {}
}


```

**modules/mymodule/main.tf**
```terraform
provider "azurerm" { 
  features {} 
}

resource "azurerm_resource_group" "mymodulerg" {
  name     = var.name
  location = "West Europe"
  tags = local.tags
}

```

**appgateway-test/main.tf**
```terraform

module "myenvironment" {
  source = "./modules/mymodule"

  name = "appgatewaytest"
  environment = "test"
  project = "Manhattan"

  mycustomtags = {
    productionstate = "not ready"
    lastrun = timestamp()
  }
}

output "final_tags" {
  value = module.myenvironment.tags
}

```

When running it you will get something like this, including the mandatory tags:

```bash

$ terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the
following symbols:
  + create

Terraform will perform the following actions:

  # module.myenvironment.azurerm_resource_group.mymodulerg will be created
  + resource "azurerm_resource_group" "mymodulerg" {
      + id       = (known after apply)
      + location = "westeurope"
      + name     = "appgatewaytest"
      + tags     = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + final_tags = {
      + created-by-terraform       = true
      + environment                = "test"
      + intilityImplementationGuid = "notSet"
      + intilityManaged            = "FALSE"
      + lastrun                    = (known after apply)
      + modifiedOn                 = ""
      + productionstate            = "not ready"
      + project                    = "Manhattan"
    }

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

module.myenvironment.azurerm_resource_group.mymodulerg: Creating...
module.myenvironment.azurerm_resource_group.mymodulerg: Creation complete after 1s [id=/subscriptions/*******/resourceGroups/appgatewaytest]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

final_tags = {
  "created-by-terraform" = true
  "environment" = "test"
  "intilityImplementationGuid" = "notSet"
  "intilityManaged" = "FALSE"
  "lastrun" = "2022-05-12T07:38:20Z"
  "modifiedOn" = ""
  "productionstate" = "not ready"
  "project" = "Manhattan"
}

```
