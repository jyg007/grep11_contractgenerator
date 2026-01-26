images: {} 
compose:
  archive: "$COMPOSE"
auths:
  "$REGISTRY_URL":
    password: "$REGISTRY_PASSWORD"
    username: "$REGISTRY_USERNAME"
type: workload
