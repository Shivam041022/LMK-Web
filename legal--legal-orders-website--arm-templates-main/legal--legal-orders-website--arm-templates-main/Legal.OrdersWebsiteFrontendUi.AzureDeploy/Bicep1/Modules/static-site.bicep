param staticSite object
param tags object

output defaultHostname string = staticSiteResource.properties.defaultHostname

resource staticSiteResource 'Microsoft.Web/staticSites@2021-03-01' = {
  name: staticSite.name
  location: 'West Europe'
  tags: tags
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
  properties: {
    provider: 'Custom'
    buildProperties: {
      skipGithubActionWorkflowGeneration: true
    }
    stagingEnvironmentPolicy: 'Disabled'
    allowConfigFileUpdates: true
  }
}
