# TP2 - Azure first steps 

## A. Choix de l'algorithme de chiffrement

🌞 Déterminer quel algorithme de chiffrement utiliser pour vos clés 

donner une source fiable qui explique pourquoi on évite RSA désormais (pour les connexions SSH notamment) :

https://www.forbes.com/councils/forbestechcouncil/2021/05/06/rsa-is-dead---we-just-haventaccepted-ityet/

donner une source fiable qui recommande un autre algorithme de chiffrement (pour les connexions SSH notamment)

https://goteleport.com/blog/comparing-ssh-keys/


## B. Génération de votre paire de clés

🌞 Générer une paire de clés pour ce TP

```
vortix@fedora:~$ mkdir -p ~/.ssh
vortix@fedora:~$ ssh-keygen -t ed25519 -f ~/.ssh/cloud_tp1 -C "TP cloud"
Generating public/private ed25519 key pair.
Enter passphrase for "/home/vortix/.ssh/cloud_tp1" (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/vortix/.ssh/cloud_tp1
Your public key has been saved in /home/vortix/.ssh/cloud_tp1.pub
The key fingerprint is:
SHA256:Kp9mN3xQr7vL2sT8yF4hJ6dB1cE5wG0aZuX+nVrM9oI TP cloud
The key's randomart image is:
+--[ED25519 256]--+
|          . ..o+.|
|         . +..+..|
|        . +..o  .|
|         o ..  .o|
|  E     S    o .o|
|  ..        o = .|
| ..o        .* =.|
|. =o... .  .o.*o.|
| +=+.ooo.ooo.+**.|
+----[SHA256]-----+
vortix@fedora:~$
```

## C. Agent SSH

🌞 Configurer un agent SSH sur votre poste

```
vortix@fedora:~$ eval $(ssh-agent -s)
Agent pid 234185
vortix@fedora:~$ ssh-add ~/.ssh/cloud_tp1
Enter passphrase for /home/vortix/.ssh/cloud_tp1: 
Identity added: /home/vortix/.ssh/cloud_tp1 (TP cloud)
vortix@fedora:~$ 
```
## II. Spawn des VMs

🌞 Connectez-vous en SSH à la VM pour preuve
```
vortix@fedora:~$ ssh azureuser@20.31.45.122
Welcome to Ubuntu 24.04.4 LTS (GNU/Linux 6.17.0-1008-azure x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Mon Mar 23 10:02:44 UTC 2026

  System load:  0.32              Processes:             117
  Usage of /:   5.7% of 28.02GB   Users logged in:       0
  Memory usage: 29%               IPv4 address for eth0: 10.0.0.4
  Swap usage:   0%


Expanded Security Maintenance for Applications is not enabled.

0 updates can be applied immediately.

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status


The list of available updates is more than a week old.
To check for new updates run: sudo apt update


The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

azureuser@vm-web:~$ 
azureuser@vm-web:~$ 
azureuser@vm-web:~$ 
azureuser@vm-web:~$ 
azureuser@vm-web:~$ 
```

## 2. az : a programmatic approach

🌞 Créez une VM depuis le Azure CLI

```
vm create -g rg-tp2-cli -n vm-cli --size Standard_B1s --image almalinux:almalinux-x86_64:10-gen2:10.1.202512150 --admin-username azureuser --public-ip-sku Standard --ssh-key-values "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK8nP4qV2mRtH7xJ9kL3sD6fG8wB5
Consider upgrading security for your workloads using Azure Trusted Launch VMs. To know more about Trusted Launch, please visit https://aka.ms/TrustedLaunch.
{
  "fqdns": "",
  "id": "/subscriptions/****-****-****/resourceGroups/rg-tp2-cli/providers/Microsoft.Compute/virtualMachines/vm-cli",
  "location": "denmarkeast",
  "macAddress": "00-22-48-A3-5B-7C",
  "powerState": "VM running",
  "privateIpAddress": "10.0.0.4",
  "publicIpAddress": "20.31.78.45",
  "resourceGroup": "rg-tp2-cli"
}
az>> 

```
🌞 Assurez-vous que vous pouvez vous connecter à la VM en SSH sur son IP publique

```
vortix@fedora:~$ ssh azureuser@20.31.78.45
The authenticity of host '20.31.78.45 (20.31.78.45)' can't be established.
ED25519 key fingerprint is SHA256:Bn8vK4mR2yQt6sL9pH3jF7dC1eW5xA0gZuY+oVrN9pI.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '20.31.78.45' (ED25519) to the list of known hosts.
[azureuser@vm-cli ~]$ 
```
🌞 Une fois connecté, prouvez la présence...

...du service waagent.service :
```
[azureuser@vm-cli ~]$ systemctl status waagent.service
● waagent.service - Azure Linux Agent
     Loaded: loaded (/usr/lib/systemd/system/waagent.service; enabled; preset: enabled)
     Active: active (running) since Mon 2026-03-23 10:18:50 UTC; 10min ago
 Invocation: fb32c88ea87f4083949d65f5651aca51
   Main PID: 1322 (python3)
      Tasks: 6 (limit: 5108)
     Memory: 47.9M (peak: 49.7M)
        CPU: 1.916s
     CGroup: /azure.slice/waagent.service
             ├─1322 /usr/bin/python3 -u /usr/sbin/waagent -daemon
             └─1454 /usr/bin/python3 -u bin/WALinuxAgent-2.15.0.1-py3.12.egg -run-exthandlers

Mar 23 10:18:56 vm-cli python3[1454]: 2: eth0    inet6 fe80::0022:48ff:fe37:9a31/64 scope link noprefixroute \       valid_lft forever preferred_lft forever
Mar 23 10:18:56 vm-cli python3[1454]: 2026-03-23T10:18:56.097343Z INFO ExtHandler ExtHandler Downloading agent manifest
Mar 23 10:18:56 vm-cli python3[1454]: 2026-03-23T10:18:56.099257Z WARNING EnvHandler ExtHandler Dhcp client is not running.
Mar 23 10:18:56 vm-cli python3[1454]: 2026-03-23T10:18:56.103682Z INFO EnvHandler ExtHandler Using iptables [version 1.8.11] to manage firewall rules
Mar 23 10:18:56 vm-cli python3[1454]: 2026-03-23T10:18:56.136903Z INFO ExtHandler ExtHandler
Mar 23 10:18:56 vm-cli python3[1454]: 2026-03-23T10:18:56.137056Z INFO ExtHandler ExtHandler ProcessExtensionsGoalState started [incarnation_1 channel: WireServer source: Fabric activity: ad238f15-95c0-4067-9dd1-084524233e10 correlation cc8b08e>
Mar 23 10:18:56 vm-cli python3[1454]: 2026-03-23T10:18:56.137487Z INFO ExtHandler ExtHandler No extension handlers found, not processing anything.
Mar 23 10:18:56 vm-cli python3[1454]: 2026-03-23T10:18:56.138033Z INFO ExtHandler ExtHandler ProcessExtensionsGoalState completed [incarnation_1 1 ms]
Mar 23 10:18:56 vm-cli python3[1454]: 2026-03-23T10:18:56.155815Z INFO ExtHandler ExtHandler Looking for existing remote access users.
Mar 23 10:18:56 vm-cli python3[1454]: 2026-03-23T10:18:56.159209Z INFO ExtHandler ExtHandler [HEARTBEAT] Agent WALinuxAgent-2.15.0.1 is running as the goal state agent [DEBUG HeartbeatCounter: 0;HeartbeatId: B41D5F6B-9066-468A-9DE4-3E57254D8269>
lines 1-22/22 (END)
```
...du service cloud-init.service
```
[azureuser@vm-cli ~]$ systemctl status cloud-init
● cloud-init.service - Cloud-init: Network Stage
     Loaded: loaded (/usr/lib/systemd/system/cloud-init.service; enabled; preset: enabled)
     Active: active (exited) since Mon 2026-03-23 10:18:50 UTC; 10min ago
 Invocation: 99fe379f55964fb4923bef7b35a5a000
   Main PID: 946 (code=exited, status=0/SUCCESS)
   Mem peak: 49.9M
        CPU: 950ms

Mar 23 10:18:50 vm-cli cloud-init[965]: |    .+.= * +  +  |
Mar 23 10:18:50 vm-cli cloud-init[965]: |      + O o o  ..|
Mar 23 10:18:50 vm-cli cloud-init[965]: |       = + . = E=|
Mar 23 10:18:50 vm-cli cloud-init[965]: |      . S  .o B==|
Mar 23 10:18:50 vm-cli cloud-init[965]: |            o+.*B|
Mar 23 10:18:50 vm-cli cloud-init[965]: |           .=.oo=|
Mar 23 10:18:50 vm-cli cloud-init[965]: |            .+. .|
Mar 23 10:18:50 vm-cli cloud-init[965]: |             ... |
Mar 23 10:18:50 vm-cli cloud-init[965]: +----[SHA256]-----+
Mar 23 10:18:50 vm-cli systemd[1]: Finished cloud-init.service - Cloud-init: Network Stage.
[azureuser@vm-cli ~]$ 
```

## 3. Terraforming planets infrastructures

🌞 Utilisez Terraform pour créer une VM dans Azure

```
vortix@fedora:~/terraform_tp$ ls
main.tf  terraform.tfvars  variables.tf
vortix@fedora:~/terraform_tp$ terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # azurerm_linux_virtual_machine.main will be created
  + resource "azurerm_linux_virtual_machine" "main" {
      + admin_username                                         = "azureuser"
      + allow_extension_operations                             = (known after apply)
      + bypass_platform_safety_checks_on_user_schedule_enabled = false
      + computer_name                                          = (known after apply)
      + disable_password_authentication                        = (known after apply)
      + disk_controller_type                                   = (known after apply)
      + extensions_time_budget                                 = "PT1H30M"
      + id                                                     = (known after apply)
      + location                                               = "denmarkeast"
      + max_bid_price                                          = -1
      + name                                                   = "super-vm"
      + network_interface_ids                                  = (known after apply)
      + os_managed_disk_id                                     = (known after apply)
      + patch_assessment_mode                                  = (known after apply)
      + patch_mode                                             = (known after apply)
      + platform_fault_domain                                  = -1
      + priority                                               = "Regular"
      + private_ip_address                                     = (known after apply)
      + private_ip_addresses                                   = (known after apply)
      + provision_vm_agent                                     = (known after apply)
      + public_ip_address                                      = (known after apply)
      + public_ip_addresses                                    = (known after apply)
      + resource_group_name                                    = "rg-tp3-terraform"
      + size                                                   = "Standard_B1s"
      + virtual_machine_id                                     = (known after apply)
      + vm_agent_platform_updates_enabled                      = (known after apply)

      + admin_ssh_key {
          + public_key = <<-EOT
                ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK8nP4qV2mRtH7xJ9kL3sD6fG8wB5cN1eY4uM0iA2zX7 TP cloud
            EOT
          + username   = "azureuser"
        }

      + os_disk {
          + caching                   = "ReadWrite"
          + disk_size_gb              = (known after apply)
          + id                        = (known after apply)
          + name                      = "vm-os-disk"
          + storage_account_type      = "Standard_LRS"
          + write_accelerator_enabled = false
        }

      + source_image_reference {
          + offer     = "almalinux-x86_64"
          + publisher = "almalinux"
          + sku       = "10-gen2"
          + version   = "latest"
        }

      + termination_notification (known after apply)
    }

  # azurerm_network_interface.main will be created
  + resource "azurerm_network_interface" "main" {
      + accelerated_networking_enabled = false
      + applied_dns_servers            = (known after apply)
      + id                             = (known after apply)
      + internal_domain_name_suffix    = (known after apply)
      + ip_forwarding_enabled          = false
      + location                       = "denmarkeast"
      + mac_address                    = (known after apply)
      + name                           = "vm-nic"
      + private_ip_address             = (known after apply)
      + private_ip_addresses           = (known after apply)
      + resource_group_name            = "rg-tp3-terraform"
      + virtual_machine_id             = (known after apply)

      + ip_configuration {
          + gateway_load_balancer_frontend_ip_configuration_id = (known after apply)
          + name                                               = "internal"
          + primary                                            = (known after apply)
          + private_ip_address                                 = (known after apply)
          + private_ip_address_allocation                      = "Dynamic"
          + private_ip_address_version                         = "IPv4"
          + public_ip_address_id                               = (known after apply)
          + subnet_id                                          = (known after apply)
        }
    }

  # azurerm_public_ip.main will be created
  + resource "azurerm_public_ip" "main" {
      + allocation_method       = "Static"
      + ddos_protection_mode    = "VirtualNetworkInherited"
      + fqdn                    = (known after apply)
      + id                      = (known after apply)
      + idle_timeout_in_minutes = 4
      + ip_address              = (known after apply)
      + ip_version              = "IPv4"
      + location                = "denmarkeast"
      + name                    = "vm-ip"
      + resource_group_name     = "rg-tp3-terraform"
      + sku                     = "Standard"
      + sku_tier                = "Regional"
    }

  # azurerm_resource_group.main will be created
  + resource "azurerm_resource_group" "main" {
      + id       = (known after apply)
      + location = "denmarkeast"
      + name     = "rg-tp3-terraform"
    }

  # azurerm_subnet.main will be created
  + resource "azurerm_subnet" "main" {
      + address_prefixes                              = [
          + "10.0.1.0/24",
        ]
      + default_outbound_access_enabled               = true
      + id                                            = (known after apply)
      + name                                          = "vm-subnet"
      + private_endpoint_network_policies             = "Disabled"
      + private_link_service_network_policies_enabled = true
      + resource_group_name                           = "rg-tp3-terraform"
      + virtual_network_name                          = "vm-vnet"
    }

  # azurerm_virtual_network.main will be created
  + resource "azurerm_virtual_network" "main" {
      + address_space                  = [
          + "10.0.0.0/16",
        ]
      + dns_servers                    = (known after apply)
      + guid                           = (known after apply)
      + id                             = (known after apply)
      + location                       = "denmarkeast"
      + name                           = "vm-vnet"
      + private_endpoint_vnet_policies = "Disabled"
      + resource_group_name            = "rg-tp3-terraform"
      + subnet                         = (known after apply)
    }

Plan: 6 to add, 0 to change, 0 to destroy.

─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
vortix@fedora:~/terraform_tp$ terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # azurerm_linux_virtual_machine.main will be created
  + resource "azurerm_linux_virtual_machine" "main" {
      + admin_username                                         = "azureuser"
      + allow_extension_operations                             = (known after apply)
      + bypass_platform_safety_checks_on_user_schedule_enabled = false
      + computer_name                                          = (known after apply)
      + disable_password_authentication                        = (known after apply)
      + disk_controller_type                                   = (known after apply)
      + extensions_time_budget                                 = "PT1H30M"
      + id                                                     = (known after apply)
      + location                                               = "denmarkeast"
      + max_bid_price                                          = -1
      + name                                                   = "super-vm"
      + network_interface_ids                                  = (known after apply)
      + os_managed_disk_id                                     = (known after apply)
      + patch_assessment_mode                                  = (known after apply)
      + patch_mode                                             = (known after apply)
      + platform_fault_domain                                  = -1
      + priority                                               = "Regular"
      + private_ip_address                                     = (known after apply)
      + private_ip_addresses                                   = (known after apply)
      + provision_vm_agent                                     = (known after apply)
      + public_ip_address                                      = (known after apply)
      + public_ip_addresses                                    = (known after apply)
      + resource_group_name                                    = "rg-tp3-terraform"
      + size                                                   = "Standard_B1s"
      + virtual_machine_id                                     = (known after apply)
      + vm_agent_platform_updates_enabled                      = (known after apply)

      + admin_ssh_key {
          + public_key = <<-EOT
                ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK8nP4qV2mRtH7xJ9kL3sD6fG8wB5cN1eY4uM0iA2zX7 TP cloud
            EOT
          + username   = "azureuser"
        }

      + os_disk {
          + caching                   = "ReadWrite"
          + disk_size_gb              = (known after apply)
          + id                        = (known after apply)
          + name                      = "vm-os-disk"
          + storage_account_type      = "Standard_LRS"
          + write_accelerator_enabled = false
        }

      + source_image_reference {
          + offer     = "almalinux-x86_64"
          + publisher = "almalinux"
          + sku       = "10-gen2"
          + version   = "latest"
        }

      + termination_notification (known after apply)
    }

  # azurerm_network_interface.main will be created
  + resource "azurerm_network_interface" "main" {
      + accelerated_networking_enabled = false
      + applied_dns_servers            = (known after apply)
      + id                             = (known after apply)
      + internal_domain_name_suffix    = (known after apply)
      + ip_forwarding_enabled          = false
      + location                       = "denmarkeast"
      + mac_address                    = (known after apply)
      + name                           = "vm-nic"
      + private_ip_address             = (known after apply)
      + private_ip_addresses           = (known after apply)
      + resource_group_name            = "rg-tp3-terraform"
      + virtual_machine_id             = (known after apply)

      + ip_configuration {
          + gateway_load_balancer_frontend_ip_configuration_id = (known after apply)
          + name                                               = "internal"
          + primary                                            = (known after apply)
          + private_ip_address                                 = (known after apply)
          + private_ip_address_allocation                      = "Dynamic"
          + private_ip_address_version                         = "IPv4"
          + public_ip_address_id                               = (known after apply)
          + subnet_id                                          = (known after apply)
        }
    }

  # azurerm_public_ip.main will be created
  + resource "azurerm_public_ip" "main" {
      + allocation_method       = "Static"
      + ddos_protection_mode    = "VirtualNetworkInherited"
      + fqdn                    = (known after apply)
      + id                      = (known after apply)
      + idle_timeout_in_minutes = 4
      + ip_address              = (known after apply)
      + ip_version              = "IPv4"
      + location                = "denmarkeast"
      + name                    = "vm-ip"
      + resource_group_name     = "rg-tp3-terraform"
      + sku                     = "Standard"
      + sku_tier                = "Regional"
    }

  # azurerm_resource_group.main will be created
  + resource "azurerm_resource_group" "main" {
      + id       = (known after apply)
      + location = "denmarkeast"
      + name     = "rg-tp3-terraform"
    }

  # azurerm_subnet.main will be created
  + resource "azurerm_subnet" "main" {
      + address_prefixes                              = [
          + "10.0.1.0/24",
        ]
      + default_outbound_access_enabled               = true
      + id                                            = (known after apply)
      + name                                          = "vm-subnet"
      + private_endpoint_network_policies             = "Disabled"
      + private_link_service_network_policies_enabled = true
      + resource_group_name                           = "rg-tp3-terraform"
      + virtual_network_name                          = "vm-vnet"
    }

  # azurerm_virtual_network.main will be created
  + resource "azurerm_virtual_network" "main" {
      + address_space                  = [
          + "10.0.0.0/16",
        ]
      + dns_servers                    = (known after apply)
      + guid                           = (known after apply)
      + id                             = (known after apply)
      + location                       = "denmarkeast"
      + name                           = "vm-vnet"
      + private_endpoint_vnet_policies = "Disabled"
      + resource_group_name            = "rg-tp3-terraform"
      + subnet                         = (known after apply)
    }

Plan: 6 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

azurerm_resource_group.main: Creating...
azurerm_resource_group.main: Still creating... [00m10s elapsed]
azurerm_resource_group.main: Still creating... [00m20s elapsed]
azurerm_resource_group.main: Still creating... [00m30s elapsed]
azurerm_resource_group.main: Creation complete after 34s [id=/subscriptions/a3f8d291-7c4b-4e8a-9d2f-1b6e5c8a4d12/resourceGroups/rg-tp3-terraform]
azurerm_virtual_network.main: Creating...
azurerm_public_ip.main: Creating...
azurerm_virtual_network.main: Still creating... [00m10s elapsed]
azurerm_public_ip.main: Still creating... [00m10s elapsed]
azurerm_public_ip.main: Creation complete after 12s [id=/subscriptions/a3f8d291-7c4b-4e8a-9d2f-1b6e5c8a4d12/resourceGroups/rg-tp3-terraform/providers/Microsoft.Network/publicIPAddresses/vm-ip]
azurerm_virtual_network.main: Creation complete after 17s [id=/subscriptions/a3f8d291-7c4b-4e8a-9d2f-1b6e5c8a4d12/resourceGroups/rg-tp3-terraform/providers/Microsoft.Network/virtualNetworks/vm-vnet]
azurerm_subnet.main: Creating...
azurerm_subnet.main: Still creating... [00m10s elapsed]
azurerm_subnet.main: Creation complete after 16s [id=/subscriptions/a3f8d291-7c4b-4e8a-9d2f-1b6e5c8a4d12/resourceGroups/rg-tp3-terraform/providers/Microsoft.Network/virtualNetworks/vm-vnet/subnets/vm-subnet]
azurerm_network_interface.main: Creating...
azurerm_network_interface.main: Creation complete after 9s [id=/subscriptions/a3f8d291-7c4b-4e8a-9d2f-1b6e5c8a4d12/resourceGroups/rg-tp3-terraform/providers/Microsoft.Network/networkInterfaces/vm-nic]
azurerm_linux_virtual_machine.main: Creating...
azurerm_linux_virtual_machine.main: Still creating... [00m10s elapsed]
azurerm_linux_virtual_machine.main: Still creating... [00m20s elapsed]
azurerm_linux_virtual_machine.main: Still creating... [00m30s elapsed]
azurerm_linux_virtual_machine.main: Creation complete after 33s [id=/subscriptions/a3f8d291-7c4b-4e8a-9d2f-1b6e5c8a4d12/resourceGroups/rg-tp3-terraform/providers/Microsoft.Compute/virtualMachines/super-vm]

Apply complete! Resources: 6 added, 0 changed, 0 destroyed.
vortix@fedora:~/terraform_tp$ 
```