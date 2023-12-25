targetScope = 'subscription'
param envname string

param moduleList object =loadJsonContent('./moduleList.json')

param miscParams object = (envname == 'dev') ? loadJsonContent('dev/misc_var.json'):(envname == 'stg')?loadJsonContent('stg/misc_var.json'):(envname == 'prd' ? loadJsonContent('prd/misc_var.json'):{})
param vnetParams object = (envname == 'dev') ? loadJsonContent('dev/vnet_var.json'):(envname == 'stg')?loadJsonContent('stg/vnet_var.json'):(envname == 'prd' ? loadJsonContent('prd/vnet_var.json'):{})
param nsgParams object = (envname == 'dev') ? loadJsonContent('dev/nsg_var.json'):(envname == 'stg')?loadJsonContent('stg/nsg_var.json'):(envname == 'prd' ? loadJsonContent('prd/nsg_var.json'):{})
param vmParams object = (envname == 'dev') ? loadJsonContent('dev/vm_var.json'):(envname == 'stg')?loadJsonContent('stg/vm_var.json'):(envname == 'prd' ? loadJsonContent('prd/vm_var.json'):{})

var tags = {
  env: miscParams.env
}

module vnets '../modules/vnet.bicep' = [for vnet in items(vnetParams):if(moduleList.vnet == 1){
  name: 'deploy-${vnet.value.vnetName}'
  scope: resourceGroup(miscParams.resourceGroupName)
  params: {
    vnetName: vnet.value.vnetName
    addressPrefix: vnet.value.addressPrefix
    subnets: vnet.value.subnets
    tags: tags
  }
}]

module nsgs '../modules/nsg.bicep' = [for nsg in items(nsgParams):if(moduleList.nsg == 1){
  name: 'deploy-${nsg.value.nsgName}'
  scope: resourceGroup(miscParams.resourceGroupName)
  params: {
    nsgName: nsg.value.nsgName
    securityRules: nsg.value.securityRules
    tags: tags
  }
}]

module vms '../modules/vm.bicep' = [for vm in items(vmParams):if(moduleList.vm == 1){
  name: 'deploy-${vm.value.vmName}'
  scope: resourceGroup(miscParams.resourceGroupName)
  dependsOn:[
    vnets
    nsgs
  ]
  params: {
    vmName: vm.value.vmName
    vmSize: vm.value.vmSize
    subnetid: '/subscriptions/${miscParams.subscriptionId}/resourceGroups/${miscParams.resourceGroupName}/providers/Microsoft.Network/virtualNetworks/${vm.value.vnet}/subnets/${vm.value.subnet}'
    nsgid: '/subscriptions/${miscParams.subscriptionId}/resourceGroups/${miscParams.resourceGroupName}/providers/Microsoft.Network/networkSecurityGroups/${vm.value.nsg}'
    OSVersion: vm.value.OSVersion
    OSDiskType: vm.value.OSDiskType
    adminUsername: vm.value.adminUsername
    adminPassword: vm.value.adminPassword
    tags: tags
  }
}]


