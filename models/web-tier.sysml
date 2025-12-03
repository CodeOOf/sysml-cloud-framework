block WebTier {
  attributes: loadBalancer, webServers
  operations: distributeTraffic(), serveContent()
}

