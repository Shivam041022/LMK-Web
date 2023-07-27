param frontDoor object
param tags object
param wafId string
param logAnalyticsId string
param staticSiteHostname string

var frontEndEndpointDefaultHostName = '${frontDoor.name}.azurefd.net'
var frontEndEndpointDefaultName = replace(frontEndEndpointDefaultHostName, '.', '-')
var frontEndEndpointCustomName = replace(frontDoor.customDomainName, '.', '-')
var backendPoolsWebsiteHostname = replace(replace(staticSiteHostname, 'https://', ''), '/', '')


resource frontDoorResource 'Microsoft.Network/frontDoors@2020-05-01' = {
  name: frontDoor.name
  location: 'global'
  tags: tags
  properties: {
    enabledState: 'Enabled'
    friendlyName: frontDoor.name
    frontendEndpoints: [
      {
        name: frontEndEndpointDefaultName
        properties: {
          hostName: frontEndEndpointDefaultHostName
          sessionAffinityEnabledState: 'Disabled'
          webApplicationFirewallPolicyLink: {
            id: wafId
          }
        }
      }
      {
        name: frontEndEndpointCustomName
        properties: {
          hostName: frontDoor.customDomainName
          sessionAffinityEnabledState: 'Disabled'
          webApplicationFirewallPolicyLink: {
            id: wafId
          }
        }
      }
    ]
    loadBalancingSettings: [
      {
        name: 'loadBalancingSettings'
        properties: {
          sampleSize: 4
          successfulSamplesRequired: 2
          additionalLatencyMilliseconds: 0
        }
      }
    ]
    healthProbeSettings: [
      {
        name: 'healthProbeSettings'
        properties: {
          enabledState: 'Disabled'
          path: '/'
          protocol: 'Https'
          intervalInSeconds: 255
          healthProbeMethod: 'HEAD'
        }
      }
    ]
    backendPools: [
      {
        name: 'website'
        properties: {
          backends: [
            {
              address: backendPoolsWebsiteHostname
              backendHostHeader: backendPoolsWebsiteHostname
              enabledState: 'Enabled'
              httpPort: 80
              httpsPort: 443
              priority: 1
              weight: 50
            }
          ]
          healthProbeSettings: {
            id: resourceId('Microsoft.Network/frontDoors/healthProbeSettings', frontDoor.name, 'healthProbeSettings')
          }
          loadBalancingSettings: {
            id: resourceId('Microsoft.Network/frontDoors/loadBalancingSettings', frontDoor.name, 'loadBalancingSettings')
          }
        }
      }
      {
        name: 'apihub'
        properties: {
          backends: [
            {
              address: frontDoor.backendPoolsApiHubHostname
              backendHostHeader: frontDoor.backendPoolsApiHubHostname
              enabledState: 'Enabled'
              httpPort: 80
              httpsPort: 443
              priority: 1
              weight: 50
            }
          ]
          healthProbeSettings: {
            id: resourceId('Microsoft.Network/frontDoors/healthProbeSettings', frontDoor.name, 'healthProbeSettings')
          }
          loadBalancingSettings: {
            id: resourceId('Microsoft.Network/frontDoors/loadBalancingSettings', frontDoor.name, 'loadBalancingSettings')
          }
        }
      }
      {
        name: 'mfe'
        properties: {
          backends: [
            {
              address: frontDoor.backendPoolsMfeHostname
              backendHostHeader: frontDoor.backendPoolsMfeHostname
              enabledState: 'Enabled'
              httpPort: 80
              httpsPort: 443
              priority: 1
              weight: 50
            }
          ]
          healthProbeSettings: {
            id: resourceId('Microsoft.Network/frontDoors/healthProbeSettings', frontDoor.name, 'healthProbeSettings')
          }
          loadBalancingSettings: {
            id: resourceId('Microsoft.Network/frontDoors/loadBalancingSettings', frontDoor.name, 'loadBalancingSettings')
          }
        }
      }
    ]
    routingRules: [
      {
        name: 'redirect-http-to-https'
        properties: {
          frontendEndpoints: [
            {
              id: resourceId('Microsoft.Network/frontDoors/frontEndEndpoints', frontDoor.name, frontEndEndpointCustomName)
            }
          ]
          acceptedProtocols: [
            'Http'
          ]
          patternsToMatch: [
            '/*'
          ]
          routeConfiguration: {
            '@odata.type': '#Microsoft.Azure.FrontDoor.Models.FrontdoorRedirectConfiguration'
            redirectType: 'Found'
            redirectProtocol: 'HttpsOnly'
          }
          enabledState: 'Enabled'
        }
      }
      {
        name: 'forward-https-to-website'
        properties: {
          frontendEndpoints: [
            {
              id: resourceId('Microsoft.Network/frontDoors/frontEndEndpoints', frontDoor.name, frontEndEndpointCustomName)
            }
          ]
          acceptedProtocols: [
            'Https'
          ]
          patternsToMatch: [
            '/*'
          ]
          routeConfiguration: {
            '@odata.type': '#Microsoft.Azure.FrontDoor.Models.FrontdoorForwardingConfiguration'
            forwardingProtocol: 'HttpsOnly'
            backendPool: {
              id: resourceId('Microsoft.Network/frontDoors/backEndPools', frontDoor.name, 'website')
            }
          }
          enabledState: 'Enabled'
        }
      }
      {
        name: 'forward-https-to-apihub'
        properties: {
          frontendEndpoints: [
            {
              id: resourceId('Microsoft.Network/frontDoors/frontEndEndpoints', frontDoor.name, frontEndEndpointCustomName)
            }
          ]
          acceptedProtocols: [
            'Https'
          ]
          patternsToMatch: [
            '/api/*'
          ]
          routeConfiguration: {
            '@odata.type': '#Microsoft.Azure.FrontDoor.Models.FrontdoorForwardingConfiguration'
            forwardingProtocol: 'HttpsOnly'
            backendPool: {
              id: resourceId('Microsoft.Network/frontDoors/backEndPools', frontDoor.name, 'apihub')
            }
            customForwardingPath: '/'
          }
          enabledState: 'Enabled'
        }
      }
      {
        name: 'forward-https-to-mfe'
        properties: {
          frontendEndpoints: [
            {
              id: resourceId('Microsoft.Network/frontDoors/frontEndEndpoints', frontDoor.name, frontEndEndpointCustomName)
            }
          ]
          acceptedProtocols: [
            'Https'
          ]
          patternsToMatch: [
            '/mfe/*'
          ]
          routeConfiguration: {
            '@odata.type': '#Microsoft.Azure.FrontDoor.Models.FrontdoorForwardingConfiguration'
            forwardingProtocol: 'HttpsOnly'
            backendPool: {
              id: resourceId('Microsoft.Network/frontDoors/backEndPools', frontDoor.name, 'mfe')
            }
          }
          enabledState: 'Enabled'
        }
      }
    ]
  }
  resource frontendEndpointResource 'frontendEndpoints' existing = {
    name: frontEndEndpointCustomName
  }
}

resource customHttpsConfiguration 'Microsoft.Network/frontdoors/frontendEndpoints/customHttpsConfiguration@2020-07-01' = {
  parent: frontDoorResource::frontendEndpointResource
  name: 'default'
  properties: {
    protocolType: 'ServerNameIndication'
    certificateSource: 'FrontDoor'
    frontDoorCertificateSourceParameters: {
      certificateType: 'Dedicated'
    }
    minimumTlsVersion: '1.2'
  }
}

resource diagnosticsSettingsResource 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: frontDoorResource
  name: frontDoor.name
  properties: {
    workspaceId: logAnalyticsId
    logs: [
      {
        category: 'FrontdoorAccessLog'
        enabled: true
      }
      {
        category: 'FrontdoorWebApplicationFirewallLog'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}
