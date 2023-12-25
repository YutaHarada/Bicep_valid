@description('Specifies the Azure location where the key vault should be created.')
param location string = resourceGroup().location
@description('Tag information for vnet')
param tags object
@description('nsgName for NSG')
param nsgName string
@description('securityRules for NSG')
param securityRules array

var securityRuleArray = [for securityRule in securityRules: {
  name: securityRule.name
  properties: {
    direction: securityRule.properties.direction
    sourceAddressPrefix: contains(securityRule.properties, 'sourceAddressPrefix') ? securityRule.properties.sourceAddressPrefix : ''
    sourceAddressPrefixes: contains(securityRule.properties, 'sourceAddressPrefixes') ? securityRule.properties.sourceAddressPrefixes : []
    sourcePortRange: contains(securityRule.properties, 'sourcePortRange') ? securityRule.properties.sourcePortRange : ''
    sourcePortRanges: contains(securityRule.properties, 'sourcePortRanges') ? securityRule.properties.sourcePortRanges : []
    destinationAddressPrefix: contains(securityRule.properties, 'destinationAddressPrefix') ? securityRule.properties.destinationAddressPrefix : ''
    destinationAddressPrefixes: contains(securityRule.properties, 'destinationAddressPrefixes') ? securityRule.properties.destinationAddressPrefixes : []
    destinationPortRange: contains(securityRule.properties, 'destinationPortRange') ? securityRule.properties.destinationPortRange : ''
    destinationPortRanges: contains(securityRule.properties, 'destinationPortRanges') ? securityRule.properties.destinationPortRanges : []
    protocol: securityRule.properties.protocol
    access: securityRule.properties.access
    priority: securityRule.properties.priority
    description: contains(securityRule.properties, 'description') ? securityRule.properties.description : ''
  }
}]

resource nsg 'Microsoft.Network/networkSecurityGroups@2022-05-01' = {
  name: nsgName
  location: location
  tags: tags
  properties: {
    securityRules: securityRuleArray
  }
}

output nsgid string = nsg.id
