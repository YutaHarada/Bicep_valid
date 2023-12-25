@description('Specifies the Azure location where the key vault should be created.')
param location string = resourceGroup().location
@description('Tag information for vnet')
param tags object = {}
@description('Virtual network name')
param vnetName string
@description('Address prefix for virtual network')
param addressPrefix string
@description('Subnets properties')
param subnets object
//@description('NetworkSecurityGroup for virtual network')
//param nsgid string

var subnetArray = [for subnet in items(subnets): {
  name: subnet.value.name
  properties: {
    addressPrefix: subnet.value.properties.addressPrefix
  }
}]

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: subnetArray

  }
}

output subnetid string = vnet.properties.subnets[0].id
