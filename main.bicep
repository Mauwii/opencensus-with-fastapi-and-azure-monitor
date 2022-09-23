param name string = 'fastapi-opencensus'
param location string = resourceGroup().location
param sku string = 'Free'
param skuName string = 'F1'
// param skuCapacity int = 1
param dockerRegistryUrl string = 'https://index.docker.io'
param dockerRegistryUsername string = 'mauwii'
// param linuxFxVersion string = 'DOCKER|mauwii/fastapi-opencensus:latest'

// @secure()
// param dockerRegistryPassword string
// param dockerRegistryStartupCommand string

var uniqueName = '${name}-${substring(uniqueString(resourceGroup().id), 0, 4)}'
var appServiceName = 'app-${uniqueName}'
var appServicePlanName = 'asp-${uniqueName}'
var appInsightsName = 'ai-${uniqueName}'
// var linuxFxVersion = 'DOCKER|${dockerRegistryUsername}/${name}:latest'

resource appServicePlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: appServicePlanName
  location: location
  kind: 'linux'
  properties: {
    targetWorkerSizeId: 0
    reserved: true
  }
  sku: {
    tier: sku
    name: skuName
  }
}

resource appService 'Microsoft.Web/sites@2018-11-01' = {
  name: appServiceName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  dependsOn: []
  properties: {
    serverFarmId: appServicePlan.id
    reserved: true
    httpsOnly: true
    siteConfig: {
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'XDT_MicrosoftApplicationInsights_Mode'
          value: 'Recommended'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: dockerRegistryUrl
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: dockerRegistryUsername
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: ''
        }
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'WEBSITE_PORT'
          value: '8000'
        }
      ]
      minTlsVersion: '1.2'
      linuxFxVersion: 'DOCKER|mauwii/fastapi-opencensus:tagname'
      appCommandLine: ''
      alwaysOn: false
      ftpsState: 'Disabled'
    }
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: appInsightsName
  location: location
  kind: 'linux'
  tags: {
  }
  properties: {
    Application_Type: 'web'
  }
}
