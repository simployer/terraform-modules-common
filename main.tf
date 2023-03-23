
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
	
	tags = merge(local.mandatory_tags, var.tags)
}

output "tags" {
  value = local.tags
}
output "buildsubnets" {
  value = ["/subscriptions/70981115-5fc9-4faa-a503-18e1541c0663/resourceGroups/shared/providers/Microsoft.Network/virtualNetworks/vnet-vd-cust-dev-tools-1/subnets/build1"]
}
output "internal_gateway_ips" {
  value = ["188.95.241.4","83.241.137.26","213.192.71.242","147.111.120.62","91.184.138.88"]
}


