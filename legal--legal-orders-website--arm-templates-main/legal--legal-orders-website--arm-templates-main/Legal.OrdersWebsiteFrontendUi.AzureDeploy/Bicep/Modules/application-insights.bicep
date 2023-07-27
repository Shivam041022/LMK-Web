param applicationInsights object
param logAnalyticsId string
param resourceGroup object
param tags object

resource applicationInsightsResource 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsights.name
  location: resourceGroup.location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsId
  }
}
