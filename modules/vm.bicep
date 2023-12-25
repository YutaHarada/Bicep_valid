@description('Virtual machine name')
param vmName string
@description('Specifies the Azure location where the key vault should be created.')
param location string = resourceGroup().location
@description('Tag information for vnet')
param tags object = {}
//@description('availabilitySet id')
//param availabilitySet string
@description('Virtual machine instance size')
param vmSize string
@description('Subnet id')
param subnetid string
@description('NetworkSecurityGroup id')
param nsgid string
@description('Managed Disk Type')
param OSDiskType string
@description('OS version')
param OSVersion string
@description('Admin User Name')
param adminUsername string
@description('Admin User Password')
@secure()
param adminPassword string
//@description('Uri of the storage account to use for placing the console output and screenshot')
//param storageUri string


resource vm 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: vmName
  location: location
  tags: tags
  properties: {
    //availabilitySet: {
    //  id: availabilitySet
    //}
    hardwareProfile: {
      vmSize: vmSize
    }
    networkProfile: {
      networkApiVersion: '2020-11-01'
      networkInterfaceConfigurations: [
        {
          name:'${vmName}-nic'
          properties: {
            deleteOption: 'Delete'
            ipConfigurations: [
              {
                name: 'ipconfig1'
                properties: {
                  publicIPAddressConfiguration: {
                    name: '${vmName}-ip'
                    properties: {
                      deleteOption: 'Delete'
                      publicIPAllocationMethod: 'Static'
                    }
                    sku: {
                      name: 'Standard'
                    }
                  }
                  subnet: {
                    id: subnetid
                  }
                }
              }
            ]
            networkSecurityGroup: {
              id: nsgid
            }
            //primary: bool
          }
        }
      ]
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: OSVersion
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        deleteOption: 'Delete'
        managedDisk: {
          storageAccountType: OSDiskType
        }
      }
      dataDisks: []
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      //  storageUri: storageUri
      }
    }
  }
}
