# Catalog DB secret (include both USER and USERNAME keys)
kubectl -n default create secret generic catalog-db \
  --from-literal=RETAIL_CATALOG_PERSISTENCE_USER="$CAT_USER" \
  --from-literal=RETAIL_CATALOG_PERSISTENCE_USERNAME="$CAT_USER" \
  --from-literal=RETAIL_CATALOG_PERSISTENCE_PASSWORD="$CAT_PASS" \
  --dry-run=client -o yaml | kubectl apply -f -


# Catalog DB secret (include both USER and USERNAME keys)
kubectl -n default create secret generic catalog-db \
  --from-literal=RETAIL_CATALOG_PERSISTENCE_USER="$CAT_USER" \
  --from-literal=RETAIL_CATALOG_PERSISTENCE_USERNAME="$CAT_USER" \
  --from-literal=RETAIL_CATALOG_PERSISTENCE_PASSWORD="$CAT_PASS" \
  --dry-run=client -o yaml | kubectl apply -f -


  

  kubectl -n default patch configmap catalog --type merge \
  -p "$(printf '{"data":{"RETAIL_CATALOG_PERSISTENCE_ENDPOINT":"%s"}}' "$MYSQL_EP")"

kubectl -n default patch configmap orders --type merge \
  -p "$(printf '{"data":{"RETAIL_ORDERS_PERSISTENCE_ENDPOINT":"%s"}}' "$PG_EP")"

# carts uses IRSA, just ensure region matches providers.tf (us-east-1)
kubectl -n default patch configmap carts --type merge \
  -p '{"data":{"AWS_REGION":"us-east-1"}}'
