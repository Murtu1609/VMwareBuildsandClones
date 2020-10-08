
data "vsphere_datacenter" "dc" {
  name = var.dc
}

locals {
  vm = csvdecode(file(var.vmbuilds))
}

data "vsphere_datastore" "sysdatastore" {
  for_each      = toset(local.vm.*.sysdatastore)
  name          = each.value
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datadatastore" {
  for_each      = toset(local.vm.*.datadatastore)
  name          = each.value
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "cluster" {
  for_each      = toset(local.vm.*.cluster)
  name          = each.value
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  for_each      = toset(local.vm.*.network)
  name          = each.value
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  for_each      = toset(local.vm.*.template)
  name          = each.value
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network2" {
  for_each = { for nic in local.vm.*.nic2 :
    nic => nic...
  if nic != "na" }
  name          = each.key
  datacenter_id = data.vsphere_datacenter.dc.id
}