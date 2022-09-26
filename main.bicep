@description('Name that will be used to build associated artifacts')
param name string

@description('Location for all resources.')
param location string = resourceGroup().location

param sku string = 'Free'
param skuCode string = 'F1'

param containerRegistryUrl string
param containerRegistryUsername string
param containerTag string
param containerPort string

var uniqueName = toLower('${name}-${substring(uniqueString(resourceGroup().id), 0, 4)}')
var appServiceName = uniqueName
var appServicePlanName = 'asp-${uniqueName}'
var appInsightsName = 'insights-${uniqueName}'
var containerRegistry = replace(containerRegistryUrl, 'https://index.', '')
var linuxFxVersion = 'DOCKER|${containerRegistry}/${containerRegistryUsername}/${name}:${containerTag}'

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: appServicePlanName
  location: location
  kind: 'linux'
  sku: {
    tier: sku
    name: skuCode
  }
  properties: {
    targetWorkerSizeId: 0
    targetWorkerCount: 1
    reserved: true
  }
}

resource appService 'Microsoft.Web/sites@2020-06-01' = {
  name: appServiceName
  location: location
  kind: 'web,linux,container'
  properties: {
    httpsOnly: true
    serverFarmId: appServicePlan.id
    siteConfig: {
      detailedErrorLoggingEnabled: true
      ftpsState: 'FtpsOnly'
      httpLoggingEnabled: true
      linuxFxVersion: linuxFxVersion
      logsDirectorySizeLimit: 35
      minTlsVersion: '1.2'
      requestTracingEnabled: true
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
          value: containerRegistryUrl
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: containerRegistryUsername
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: ''
        }
        {
          name: 'WEBSITES_PORT'
          value: containerPort
        }
      ]
    }
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}

output webAppName string = appService.name
output webAppHostname string = appService.properties.defaultHostName
output insightsId string = appInsights.id
