

resource "vsphere_virtual_machine" "vm" {
  for_each = toset(local.vm.*.name)

  name                       = each.value
  resource_pool_id           = data.vsphere_compute_cluster.cluster[local.vm[index(local.vm.*.name,each.key)].cluster].resource_pool_id
  datastore_id               = data.vsphere_datastore.sysdatastore[local.vm[index(local.vm.*.name,each.key)].sysdatastore].id
  num_cpus                   = local.vm[index(local.vm.*.name,each.key)].vcpus
  num_cores_per_socket       = local.vm[index(local.vm.*.name,each.key)].corespersocket
  memory                     = local.vm[index(local.vm.*.name,each.key)].memory * 1024
  guest_id                   = data.vsphere_virtual_machine.template[local.vm[index(local.vm.*.name,each.key)].template].guest_id
  folder                     = local.vm[index(local.vm.*.name,each.key)].folder
  wait_for_guest_net_timeout = 0

  dynamic "disk" {
    for_each = split("-",local.vm[index(local.vm.*.name,each.key)].disksizes)
    content {
      label            = "disk${disk.key}"
      size             = disk.value
      thin_provisioned = lower(local.vm[index(local.vm.*.name,each.key)].thinprovision)
      unit_number      = disk.key
      datastore_id     = disk.key == 0 ? data.vsphere_datastore.sysdatastore[local.vm[index(local.vm.*.name,each.key)].sysdatastore].id : data.vsphere_datastore.datadatastore[local.vm[index(local.vm.*.name,each.key)].datadatastore].id
    }
  }

  network_interface {
    network_id = data.vsphere_network.network[local.vm[index(local.vm.*.name,each.key)].network].id
  }

  dynamic network_interface {
    for_each = local.vm[index(local.vm.*.name,each.key)].nic2 != "na" ? [local.vm[index(local.vm.*.name,each.key)].nic2] : []
    content {
      network_id = data.vsphere_network.network2[network_interface.value].id
    }
  }

cdrom {
    client_device = true
  }

  clone {

    template_uuid = data.vsphere_virtual_machine.template[local.vm[index(local.vm.*.name,each.key)].template].id
    timeout       = 120

    customize {

      timeout = 0

      dynamic windows_options {
        for_each = local.vm[index(local.vm.*.name,each.key)].ostype == "windows" ? ["1"] : []
        content {
          computer_name         = each.key
          admin_password        = var.localadminpassword
          join_domain           = var.windowsdomain
          domain_admin_user     = var.domainadminuser
          domain_admin_password = var.domainadminpassword
          auto_logon            = true
        }
      }

      dynamic linux_options {
        for_each = local.vm[index(local.vm.*.name,each.key)].ostype == "linux" ? ["1"] : []
        content {
          host_name = each.key
          domain    = var.linuxdomain
        }
      }

      network_interface {
        ipv4_address    = local.vm[index(local.vm.*.name,each.key)].ip
        ipv4_netmask    = local.vm[index(local.vm.*.name,each.key)].mask
        dns_server_list = split(",",local.vm[index(local.vm.*.name,each.key)].dns)
      }

      dynamic network_interface {
        for_each = local.vm[index(local.vm.*.name,each.key)].nic2 != "na" ? [local.vm[index(local.vm.*.name,each.key)].nic2] : []
        content {
          ipv4_address    = local.vm[index(local.vm.*.name,each.key)].ip2
          ipv4_netmask    = local.vm[index(local.vm.*.name,each.key)].mask2
          dns_server_list = split(",",local.vm[index(local.vm.*.name,each.key)].dns2)
        }
      }

      ipv4_gateway = local.vm[index(local.vm.*.name,each.key)].gateway
      dns_server_list = split(",",local.vm[index(local.vm.*.name,each.key)].dns)
    }
  }
}

