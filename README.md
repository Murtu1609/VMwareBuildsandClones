# VMwareBuildsandClones
A terraform module to build vmware virtual machines from a csv file, from existing templates or cloned from existing vms

# Pre-requisites
1) Vmware Vcentre server ip and credentials
2) existing templates to build vms from or existing vms to be cloned

# CSV File
download the example.csv zipped file and edit it as per your requirements

you can mention multipe disk sizes in the disksizes column seperated by -

mention 1 or 2 dns servers in dns and/or dns2 column seperated by ,

mention na in nic2 column if you do not require a second nic card

mention same datastore name as sysdatastore, in datadatastore, if vm has only one disk or if same datastore is to be used for remaining disks

ostype can be windows or linux

# Example Usage
you may use the below provider block or create your own

copy below code into a .tf file, edit the variables and csv files as per your requirement and run terraform init, terraform validate and terraform apply
```

provider "vsphere" {
  user           = "username"
  password       = "password"
  vsphere_server = "vsphere server ip"

  # If you have a self-signed cert
  allow_unverified_ssl = true
}


module "vmbuilds" {

  source = "github.com/murtu1609/VMwareBuildsandClones"

  dc                  = "nameofdatacenter"

  # Please use null (without quotes) to NOT add to domain (for windows boxes)
  windowsdomain       = "windowsdomainname"       
  domainadminuser     = "domainadminuser"
  domainadminpassword = "domainadmminpassword"
  
  localadminpassword  = "localadminpassword"   //for windows boxes

  linuxdomain         = "development.local"

  vmbuilds = "D:/VmwareTerraform/vmbuilds8/example.csv"   //path of downloaded csv

}
