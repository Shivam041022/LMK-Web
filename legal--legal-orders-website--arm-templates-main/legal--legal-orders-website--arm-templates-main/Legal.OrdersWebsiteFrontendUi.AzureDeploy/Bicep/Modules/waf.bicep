param waf object
param tags object

output id string = wafResource.id

resource wafResource 'Microsoft.Network/FrontDoorWebApplicationFirewallPolicies@2020-11-01' = {
  name: waf.name
  location: 'global'
  tags: tags
  sku: {
    name: 'Classic_AzureFrontDoor'
  }
  properties: {
    policySettings: {
      enabledState: 'Enabled'
      mode: 'Prevention'
      customBlockResponseStatusCode: 403
      customBlockResponseBody: 'Rm9yYmlkZGVu'
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'DefaultRuleSet'
          ruleSetVersion: '1.0'
        }
      ]
    }
    customRules: {
      rules: [
        {
          name: 'rasterDataWmsAllowHex'
          enabledState: 'Enabled'
          priority: 10
          ruleType: 'MatchRule'
          matchConditions: [
            {
              matchVariable: 'RequestUri'
              selector: null
              operator: 'Contains'
              negateCondition: false
              matchValue: [
                'mapping-mfe-bff/application/wms'
              ]
              transforms: [
                'Lowercase'
              ]
            }
            {
              matchVariable: 'RequestUri'
              selector: null
              operator: 'RegEx'
              negateCondition: false
              matchValue: [
                'bgcolor=0x[a-fA-F0-9]{6,6}(&.+)?$'
              ]
              transforms: []
            }
          ]
          action: 'Allow'
        }
        {
          name: 'AllowAuth0Cookies'
          enabledState: 'Enabled'
          priority: 100
          ruleType: 'MatchRule'
          action: 'Allow'
          matchConditions: [
            {
              matchVariable: 'RequestHeader'
              selector: 'Cookie'
              operator: 'Contains'
              negateCondition: false
              matchValue: [
                'a0.spajs.txs'
              ]
              transforms: [
                'Lowercase'
              ]
            }
          ]
        }
      ]
    }
  }
}
