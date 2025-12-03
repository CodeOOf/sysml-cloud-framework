block DomainController {
  attributes: userAuth, groupPolicy
  operations: authenticateUser(), enforcePolicy()
}

