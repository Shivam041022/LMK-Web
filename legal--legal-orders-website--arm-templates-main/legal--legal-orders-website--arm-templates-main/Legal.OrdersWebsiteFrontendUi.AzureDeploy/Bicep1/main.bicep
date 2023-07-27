targetScope = 'subscription'

param tagsParam object = {}
param resourceGroupParam object
param logAnalyticsParam object
param applicationInsightsParam object
param wafParam object
param staticSiteParam object
param frontDoorParam object

var serviceName = 'legalorderswebsitefrontend'

module resourceGroupUKS 'Modules/resource-group.bicep' = {
  name: '${serviceName}--resource-group'
  scope: subscription()
  params: {
    resourceGroup: resourceGroupParam
    tags: tagsParam
  }
}

module logAnalytics 'Modules/log-analytics.bicep' = {
  name: '${serviceName}--log-analytics'
  scope: resourceGroup(resourceGroupParam.name)
  dependsOn: [
    resourceGroupUKS
  ]
  params: {
    logAnalytics: logAnalyticsParam
    resourceGroup: resourceGroupParam
    tags: tagsParam
  }
}

module applicationInsights 'Modules/application-insights.bicep' = {
  scope: resourceGroup(resourceGroupParam.name)
  dependsOn: [
    resourceGroupUKS
    logAnalytics
  ]
  name: '${serviceName}--application-insights'
  params: {
    applicationInsights: applicationInsightsParam
    resourceGroup: resourceGroupParam
    logAnalyticsId: logAnalytics.outputs.id
    tags: tagsParam
  }
}

module waf 'Modules/waf.bicep' = {
  name: '${serviceName}--waf'
  scope: resourceGroup(resourceGroupParam.name)
  dependsOn: [
    resourceGroupUKS
  ]
  params: {
    waf: wafParam
    tags: tagsParam
  }
}

module staticSite 'Modules/static-site.bicep' = {
  name: '${serviceName}--static-site'
  scope: resourceGroup(resourceGroupParam.name)
  dependsOn: [
    resourceGroupUKS
  ]
  params: {
    staticSite: staticSiteParam
    tags: tagsParam
  }
}

module frontDoor 'Modules/front-door.bicep' = {
  name: '${serviceName}--front-door'
  scope: resourceGroup(resourceGroupParam.name)
  dependsOn: [
    resourceGroupUKS
  ]
  params: {
    frontDoor: frontDoorParam
    tags: tagsParam
    logAnalyticsId: logAnalytics.outputs.id
    wafId: waf.outputs.id
    staticSiteHostname: staticSite.outputs.defaultHostname
  }
}
