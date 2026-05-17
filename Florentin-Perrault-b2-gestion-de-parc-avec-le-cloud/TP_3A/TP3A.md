# TP3A : Terraform + Azure

Un Network Security Group ou NSG for short, c'est un genre de firewall géré par Azure.

On peut affecter un NSG à une interface réseau.

En configurant ce NSG, on pourra alors faire du filtrage réseau, comme par exemple : n'autoriser les connexions que sur un certain port.

## 2. Ajouter un NSG au déploiement

🌞 Ajouter un NSG à votre déploiement Terraform
```
vortix@fedora:~/terraform_tp$ cat network.tf 

resource "azurerm_network_security_group" "example" {
  name                = "fw2ouf"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Production"
  }
}
vortix@fedora:~/terraform_tp$ 
```
3. Proofs !

🌞 Prouver que ça fonctionne, rendu attendu :

la sortie du terraform apply

une commande az pour obtenir toutes les infos liées à la VM

    on doit y voir le NSG

une commande ssh fonctionnelle 

```
vortix@fedora:~/terraform_tp$ tf apply
azurerm_resource_group.main: Refreshing state... [id=/subscriptions/a3f8d291-7c4b-4e8a-9d2f-1b6e5c8a4d12/resourceGroups/rg-tp3-terraform]
azurerm_public_ip.main: Refreshing state... [id=/subscriptions/a3f8d291-7c4b-4e8a-9d2f-1b6e5c8a4d12/resourceGroups/rg-tp3-terraform/providers/Microsoft.Network/publicIPAddresses/vm-ip]
azurerm_virtual_network.main: Refreshing state... [id=/subscriptions/a3f8d291-7c4b-4e8a-9d2f-1b6e5c8a4d12/resourceGroups/rg-tp3-terraform/providers/Microsoft.Network/virtualNetworks/vm-vnet]
azurerm_subnet.main: Refreshing state... [id=/subscriptions/a3f8d291-7c4b-4e8a-9d2f-1b6e5c8a4d12/resourceGroups/rg-tp3-terraform/providers/Microsoft.Network/virtualNetworks/vm-vnet/subnets/vm-subnet]
azurerm_network_interface.main: Refreshing state... [id=/subscriptions/a3f8d291-7c4b-4e8a-9d2f-1b6e5c8a4d12/resourceGroups/rg-tp3-terraform/providers/Microsoft.Network/networkInterfaces/vm-nic]
azurerm_linux_virtual_machine.main: Refreshing state... [id=/subscriptions/a3f8d291-7c4b-4e8a-9d2f-1b6e5c8a4d12/resourceGroups/rg-tp3-terraform/providers/Microsoft.Compute/virtualMachines/super-vm]

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # azurerm_network_security_group.example will be created
  + resource "azurerm_network_security_group" "example" {
      + id                  = (known after apply)
      + location            = "denmarkeast"
      + name                = "fw2ouf"
      + resource_group_name = "rg-tp3-terraform"
      + security_rule       = [
          + {
              + access                                     = "Allow"
              + destination_address_prefix                 = "*"
              + destination_address_prefixes               = []
              + destination_application_security_group_ids = []
              + destination_port_range                     = "22"
              + destination_port_ranges                    = []
              + direction                                  = "Inbound"
              + name                                       = "ssh"
              + priority                                   = 100
              + protocol                                   = "Tcp"
              + source_address_prefix                      = "*"
              + source_address_prefixes                    = []
              + source_application_security_group_ids      = []
              + source_port_range                          = "*"
              + source_port_ranges                         = []
                # (1 unchanged attribute hidden)
            },
        ]
      + tags                = {
          + "environment" = "Production"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

azurerm_network_security_group.example: Creating...
azurerm_network_security_group.example: Creation complete after 9s [id=/subscriptions/a3f8d291-7c4b-4e8a-9d2f-1b6e5c8a4d12/resourceGroups/rg-tp3-terraform/providers/Microsoft.Network/networkSecurityGroups/fw2ouf]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```
```
az>> az network nsg list
```
```
az>> vm show --resource-group  rg-tp3-terraform -n super-vm --show-details --output json
{
  "diagnosticsProfile": {
    "bootDiagnostics": {
      "enabled": false
    }
  },
  "etag": "\"6\"",
  "extensionsTimeBudget": "PT1H30M",
  "fqdns": "",
  "hardwareProfile": {
    "vmSize": "Standard_B1s"
  },
  "id": "/subscriptions/a3f8d291-7c4b-4e8a-9d2f-1b6e5c8a4d12/resourceGroups/rg-tp3-terraform/providers/Microsoft.Compute/virtualMachines/super-vm",
  "location": "denmarkeast",
  "macAddresses": "00-22-48-B7-2E-91",
  "name": "super-vm",
  "networkProfile": {
    "networkInterfaces": [
      {
        "id": "/subscriptions/a3f8d291-7c4b-4e8a-9d2f-1b6e5c8a4d12/resourceGroups/rg-tp3-terraform/providers/Microsoft.Network/networkInterfaces/vm-nic",
        "primary": true,
        "resourceGroup": "rg-tp3-terraform"
      }
    ]
  },
  "osProfile": {
    "adminUsername": "azureuser",
    "allowExtensionOperations": true,
    "computerName": "super-vm",
    "linuxConfiguration": {
      "disablePasswordAuthentication": true,
      "patchSettings": {
        "assessmentMode": "ImageDefault",
        "patchMode": "ImageDefault"
      },
      "provisionVMAgent": true,
      "ssh": {
        "publicKeys": [
          {
            "keyData": "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK8nP4qV2mRtH7xJ9kL3sD6fG8wB5cN1eY4uM0iA2zX7 TP cloud\n",
            "path": "/home/azureuser/.ssh/authorized_keys"
          }
        ]
      }
    },
    "requireGuestProvisionSignal": true,
    "secrets": []
  },
  "powerState": "VM running",
  "priority": "Regular",
  "privateIps": "10.0.1.4",
  "provisioningState": "Succeeded",
  "publicIps": "20.31.92.156",
  "resourceGroup": "rg-tp3-terraform",
  "storageProfile": {
    "dataDisks": [],
    "diskControllerType": "SCSI",
    "imageReference": {
      "exactVersion": "10.1.202512150",
      "offer": "almalinux-x86_64",
      "publisher": "almalinux",
      "sku": "10-gen2",
      "version": "latest"
    },
    "osDisk": {
      "caching": "ReadWrite",
      "createOption": "FromImage",
      "deleteOption": "Detach",
      "diskSizeGB": 30,
      "managedDisk": {
        "id": "/subscriptions/a3f8d291-7c4b-4e8a-9d2f-1b6e5c8a4d12/resourceGroups/RG-TP3-TERRAFORM/providers/Microsoft.Compute/disks/vm-os-disk",
        "resourceGroup": "RG-TP3-TERRAFORM",
        "storageAccountType": "Standard_LRS"
      },
      "name": "vm-os-disk",
      "osType": "Linux",
      "writeAcceleratorEnabled": false
    }
  },
  "tags": {},
  "timeCreated": "2026-03-23T14:12:58.7705355+00:00",
  "type": "Microsoft.Compute/virtualMachines",
  "vmId": "e7b3c821-5a4d-4e9f-8c2b-6d1a4e8b3c75"
}
az>> 
```

``` 
changement de port :

modifiez le port d'écoute du serveur OpenSSH sur la VM pour le port 2222/tcp
prouvez que le serveur OpenSSH écoute sur ce nouveau port (avec une commande ss sur la VM)
prouvez qu'une nouvelle connexion sur ce port 2222/tcp ne fonctionne pas à cause du NSG

vortix@fedora:~/terraform_tp$ ssh azureuser@20.31.92.156
The authenticity of host '20.31.92.156 (20.31.92.156)' can't be established.
ED25519 key fingerprint is SHA256:Tq7nM5xRp3vL8sJ2yH6dF4cB0eA9wG1zU+iVrK7oN5pE.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '20.31.92.156' (ED25519) to the list of known hosts.
[azureuser@super-vm ~]$ 
[azureuser@super-vm ~]$ 
[azureuser@super-vm ~]$ 
[azureuser@super-vm ~]$ 
[azureuser@super-vm ~]$ 
[azureuser@super-vm ~]$ 
[azureuser@super-vm ~]$ 
[azureuser@super-vm ~]$ 
```
```
vortix@fedora:~/terraform_tp$ sudo vim /etc/ssh/sshd_config
vortix@fedora:~/terraform_tp$ sudo setenforce 0
vortix@fedora:~/terraform_tp$ systemctl restart sshd
vortix@fedora:~/terraform_tp$ sudo ss -lntp | grep 2222
LISTEN 0      128          0.0.0.0:2222      0.0.0.0:*    users:(("sshd",pid=98205,fd=6))           
LISTEN 0      128             [::]:2222         [::]:*    users:(("sshd",pid=98205,fd=7))           
vortix@fedora:~/terraform_tp$ 

```
## II. Un ptit nom DNS

### 1. Adapter le plan Terraform¶

🌞 Donner un nom DNS à votre VM

```
  resource "azurerm_private_dns_zone" "dnsvortix" {
  name                = "dnsvortix.com"
  resource_group_name = azurerm_resource_group.main.name
}
```

### 2. Ajouter un output custom à terraform apply¶

🌞 Un ptit output nan ?

créez un fichier outputs.tf à côté de votre main.tf
doit afficher l'IP publique et le nom DNS de la VM

```
vortix@fedora:~/terraform_tp$ terraform apply
azurerm_resource_group.main: Refreshing state... [id=/subscriptions/a3f8d291-7c4b-4e8a-9d2f-1b6e5c8a4d12/resourceGroups/rg-tp3-terraform]
azurerm_public_ip.main: Refreshing state... [id=/netoft.Network/networkSecurityGroups/fw2ouf]
azurerm_linux_virtual_machine.main: Refreshing state... [id=/subscriptions/a3f8d291-7c4b-4e8a-9d2f-1b6e5c8a4d12/resourceGroups/rg-tp3-terraform/providers/Microsoft.Compute/virtualMachines/super-vm]

Changes to Outputs:
  + vm_dns_name  = "dnsvortix.com"
  + vm_public_ip = "20.31.92.156"

You can apply this plan to save these new output values to the Terraform state, without changing any real infrastructure.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes


Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

vm_dns_name = "dnsvortix.com"
vm_public_ip = "20.31.92.156"
vortix@fedora:~/terraform_tp$ 
```

## III. Blob storage

2. Let's go

🌞 Compléter votre plan Terraform pour déployer du Blob Storage pour votre VM

3. Proooooooofs¶

🌞 Prouvez que tout est bien configuré, depuis la VM Azure

    installez azcopy dans la VM (suivez la doc officielle pour l'installer dans votre VM Azure)
    azcopy login --identity pour vous authentifier automatiquement
    utilisez azcopy pour écrire un fichier dans le Storage Container que vous avez créé
    utilisez azcopy pour lire le fichier que vous venez de push

```
sudo dnf install wget tar -y
```
```
wget https://aka.ms/downloadazcopy-v10-linux
```
```
tar -xvf downloadazcopy-v10-linux
```
```
sudo cp ./azcopy_linux_amd64_*/azcopy /usr/bin/
```
```
sudo chmod +x /usr/bin/azcopy
```
authentification :
```
[azureuser@super-vm ~]$ azcopy login --identity
INFO: Login with identity succeeded.
```

🌞 Déterminez comment azcopy login --identity vous a authentifié

  
```
Pour faire simple, l'authentification s'est faite sans mot de passe grâce à l'Identité Managée d'Azure.

depuis mon code Terraform, j'ai doté ma machine virtuelle d'une "carte d'identité" invisible ( avec le bloc SystemAssigned dans le main) et je lui ai donné le droit d'écrire sur mon compte de stockage.

donc en tapant la commande, azcopy a interrogé sans que je sache l'infrastructure interne d'Azure.

Azure a reconnu ma machine, a vérifié ses droits, et lui a délivré un jeton d'accès temporaire pour qu'elle puisse s'authentifier instantanément et de manière sécurisée.
```


🌞 Requêtez un JWT d'authentification auprès du service que vous venez d'identifier, manuellement

depuis la VM
avec une commande curl
à priori ce sera une requête vers 169.254.169.254
```
[azureuser@super-vm ~]$ curl -H "Metadata: true" -s "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://storage.azure.com/"
{"access_token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6IkFCQzEyM1hZWiIsImtpZCI6IkFCQzEyM1hZWiJ9.eyJhdWQiOiJodHRwczovL3N0b3JhZ2UuYXp1cmUuY29tLyIsImlzcyI6Imh0dHBzOi8vc3RzLndpbmRvd3MubmV0L0FCQy8iLCJleHAiOjE3NzQ5ODQ5NzUsImFwcGlkIjoiQ0xJRU5UX0lEX1JFREFDVEVEIn0.REDACTED_SIGNATURE_PLACEHOLDER_xxxxxxxxxxxxxxxxxxxx","client_id":"c8d4f617-9e2a-4b5c-8f3d-7a1e6c9b4f25","expires_in":"86400","expires_on":"1774984975","ext_expires_in":"86399","not_before":"1774898275","resource":"https://storage.azure.com/","token_type":"Bearer"}[azureuser@super-vm ~]$ 
``` 
🌞 Expliquez comment l'IP 169.254.169.254 peut être joignable

petit hint : table de routage de la VM !
```
donc ip route ??

L'adresse 169.254.169.254 est link-Local non routable, genre une adresse fantome . ip route indique que ce trafic part vers la passerelle par défaut. Mais en réalité, le paquet est directement intercepté par l'hyperviseur physique d'Azure qui héberge ma VM. Le trafic ne passe jamais par un réseau externe, c'est le serveur hôte qui me donne directement le token.
```

## IV. Monitoring

### 2. Une alerte CPU¶

🌞 Compléter votre plan Terraform et mettez en place une alerte CPU

### 3. Alerte mémoire

🌞 Compléter votre plan Terraform et mettez en place une alerte mémoire

## 4. Proofs

A. Voir les alertes avec az¶

🌞 Une commande az qui permet de lister les alertes actuellement configurées
```
vortix@fedora:~/terraform_tp$ az monitor metrics alert list --resource-group rg-tp3-terraform --output table
AutoMitigate    Description                         Enabled    EvaluationFrequency    Location    Name                ResourceGroup     Severity    TargetResourceRegion    TargetResourceType    WindowSize
--------------  ----------------------------------  ---------  ---------------------  ----------  ------------------  ----------------  ----------  ----------------------  --------------------  ------------
True            Alerte si la RAM dispo est < 512Mo  True       PT1M                   global      ram-alert-super-vm  rg-tp3-terraform  2                                                         PT5M
True            Alerte si le CPU dépasse 70%        True       PT1M                   global      cpu-alert-super-vm  rg-tp3-terraform  2                                                         PT5M
vortix@fedora:~/terraform_tp$ 
```

B. Stress pour fire les alertes¶

🌞 Stress de la machine
```
vortix@fedora:~/terraform_tp$ stress-ng --cpu 4 --timeout 600
stress-ng: info:  [16464] setting to a 10 mins run per stressor
stress-ng: info:  [16464] dispatching hogs: 4 cpu
```
```
vortix@fedora:~/terraform_tp$ stress-ng --vm 1 --vm-bytes 1200M --timeout 600
stress-ng: info:  [16772] setting to a 10 mins run per stressor
stress-ng: info:  [16772] dispatching hogs: 1 vm
stress-ng: info:  [16773] vm: using 1.17GB per stressor instance (total 1.17GB of 1.93GB available memory)
```

🌞 Vérifier que des alertes ont été fired

```
vortix@fedora:~/terraform_tp$ az monitor activity-log list --resource-group rg-tp3-terraform --offset 1h --output table | grep -i -E "alert|fired|activated"
vortix@protonmail.com  ea8cbf61-2728-0637-b15f-63d5ce32a2ab                 2d47a7fb-ebae-4512-9af4-08c1747c66c9  2026-03-25T19:42:09.3969572Z  Informational  5f7a0499-7be7-41c1-85f3-7341be67c409  rg-tp3-terraform  rg-tp3-terraform     /subscriptions/a3f8d291-7c4b-4e8a-9d2f-1b6e5c8a4d12/resourceGroups/rg-tp3-terraform/providers/Microsoft.Insights/metricAlerts/cpu-alert-super-vm  2026-03-25T19:43:32Z   a3f8d291-7c4b-4e8a-9d2f-1b6e5c8a4d12  b5e9c427-3d8f-4a1b-8e6c-9f2a7d3b5e18
vortix@protonmail.com  ea8cbf61-2728-0637-b15f-63d5ce32a2ab                 d5e0350f-92ba-41e7-8b6a-b3840428e7aa  2026-03-25T19:42:08.2101088Z  Informational  dc9b5ce9-fbf0-4fb6-a1e8-edcef0a4718f  rg-tp3-terraform  rg-tp3-terraform     /subscriptions/a3f8d291-7c4b-4e8a-9d2f-1b6e5c8a4d12/resourceGroups/rg-tp3-terraform/providers/Microsoft.Insights/metricAlerts/ram-alert-super-vm  2026-03-25T19:44:04Z   a3f8d291-7c4b-4e8a-9d2f-1b6e5c8a4d12  b5e9c427-3d8f-4a1b-8e6c-9f2a7d3b5e18
vortix@protonmail.com  ea8cbf61-2728-0637-b15f-63d5ce32a2ab                 891906fc-b731-4b2c-b683-dd0c7bb3d7b3  2026-03-25T19:42:03.7563639Z  Informational  5f7a0499-7be7-41c1-85f3-7341be67c409  rg-tp3-terraform  rg-tp3-terraform     /subscriptions/a3f8d291-7c4b-4e8a-9d2f-1b6e5c8a4d12/resourceGroups/rg-tp3-terraform/providers/Microsoft.Insights/metricAlerts/cpu-alert-super-vm  2026-03-25T19:43:32Z   a3f8d291-7c4b-4e8a-9d2f-1b6e5c8a4d12  b5e9c427-3d8f-4a1b-8e6c-9f2a7d3b5e18
vortix@protonmail.com  ea8cbf61-2728-0637-b15f-63d5ce32a2ab                 ab6744a4-420e-4deb-8a7f-1266d9c67662  2026-03-25T19:42:02.3498115Z  Informational  dc9b5ce9-fbf0-4fb6-a1e8-edcef0a4718f  rg-tp3-terraform  rg-tp3-terraform     /subscriptions/a3f8d291-7c4b-4e8a-9d2f-1b6e5c8a4d12/resourceGroups/rg-tp3-terraform/providers/Microsoft.Insights/metricAlerts/ram-alert-super-vm  2026-03-25T19:44:04Z   a3f8d291-7c4b-4e8a-9d2f-1b6e5c8a4d12  b5e9c427-3d8f-4a1b-8e6c-9f2a7d3b5e18
vortix@protonmail.com  ea8cbf61-2728-0637-b15f-63d5ce32a2ab                 f66260a2-fb78-4560-a77c-8196903d729a  2026-03-25T19:41:56.1971024Z  Informational  5a902043-5c2b-46cf-a9c7-9413f8d422c8  rg-tp3-terraform  rg-tp3-terraform     /subscriptions/a3f8d291-7c4b-4e8a-9d2f-1b6e5c8a4d12/resourceGroups/rg-tp3-terraform/providers/Microsoft.Insights/actionGroups/ag-tp3-alerts       2026-03-25T19:42:33Z   a3f8d291-7c4b-4e8a-9d2f-1b6e5c8a4d12  b5e9c427-3d8f-4a1b-8e6c-9f2a7d3b5e18
vortix@protonmail.com  ea8cbf61-2728-0637-b15f-63d5ce32a2ab                 57f8e4db-671b-4735-b743-6aa07cfae553  2026-03-25T19:41:54.6658541Z  Informational  5a902043-5c2b-46cf-a9c7-9413f8d422c8  rg-tp3-terraform  rg-tp3-terraform     /subscriptions/a3f8d291-7c4b-4e8a-9d2f-1b6e5c8a4d12/resourceGroups/rg-tp3-terraform/providers/Microsoft.Insights/actionGroups/ag-tp3-alerts       2026-03-25T19:42:33Z   a3f8d291-7c4b-4e8a-9d2f-1b6e5c8a4d12  b5e9c427-3d8f-4a1b-8e6c-9f2a7d3b5e18
vortix@fedora:~/terraform_tp$ 
```
j'ai tours reçu,  mon Action Group s'est réveillé (ag-tp3-alerts).

mon alerte RAM qui a bien crié (ram-alert-super-vm).

mon alerte CPU qui a suivi derrière (cpu-alert-super-vm).

Et azure m'as bien contacté par mail.


## V. Azure Vault
intro : 

➜ Une Vault est un terme générique (démocratisé un peu par HashiCorp Vault) pour un machin qui permet de stocker, gérer et récupérer des secrets.

C'est un cas plutôt récurrent désormais, avec l'ère du Cloud et des outils comme Terraform : on écrit des secrets en clair un peu partout si on fait rien de particulier.

L'idée d'une Vault est donc de proposer un endroit centralisé et sécurisé où stocker ces secrets.

On peut ensuite accéder à ces secrets après authentification (lecture/écriture). Souvent ça passe par le protocole HTTP (une API REST quoi) pour la plupart des Vaults.

➜ Azure propose une Vault, permettant de partager des secrets entre plusieurs VMs ou ressources.

Et avec Terraform, on peut les définir à la volée de façon aléatoire, ou les prédéfinir manuellement.

### 2. Do it !

🌞 Compléter votre plan Terraform et mettez en place une Azure Key Vault

###   3. Proof proof proof¶

🌞 Avec une commande az, afficher le secret

depuis votre poste, et votre compte Azure, vous avez les droits pour voir le secret normalement
ça va se faire avec un az keyvault secret show --name "<Le nom de ton secret ici>" --vault-name "<Le nom de ta Azure Key Vault ici>"

```
vortix@fedora:~/terraform_tp$ az keyvault secret show --name "mon-secret-tp3" --vault-name "vault-vortix-tp3-2026" --query value
"xK9mPq2RvT8nHbE("
vortix@fedora:~/terraform_tp$ 
```

🌞 Depuis la VM, afficher le secret

il faut donc faire une requête à la Azure Key Vault depuis la VM Azure
un ptit script shell ça le fait !

```
[azureuser@super-vm ~]$ cat recup_secret.sh 
#!/bin/bash

TOKEN=$(curl -s -H "Metadata: true" "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://vault.azure.net" | sed -E 's/.*"access_token":"([^"]+)".*/\1/')

curl -s -H "Authorization: Bearer $TOKEN" "https://vault-vortix-tp3-2026.vault.azure.net/secrets/mon-secret-tp3?api-version=7.4" | sed -E 's/.*"value":"([^"]+)".*/\1/'
[azureuser@super-vm ~]$ 

```
```
[azureuser@super-vm ~]$ ./recup_secret.sh
xK9mPq2RvT8nHbE
```