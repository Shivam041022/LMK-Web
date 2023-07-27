param logAnalytics object
param resourceGroup object
param tags object

output id string = logAnalyticsResource.id

resource logAnalyticsResource 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: logAnalytics.name
  location: resourceGroup.location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: logAnalytics.retentionInDays
    workspaceCapping: {
      dailyQuotaGb: logAnalytics.dailyQuotaGb
    }
  }
}
