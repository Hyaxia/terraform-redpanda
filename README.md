## Redpanda Terraform

The part where we set redpanda cluster, we follow the instructions in https://docs.redpanda.com/current/deploy/deployment-option/self-hosted/kubernetes/local-guide/?tab=tabs-3-helm-operator#explore-your-topic-in-redpanda-console

redpanda console - `kubectl --namespace kafka port-forward svc/redpanda-console 8080:8080`
redpanda cluster status - `kubectl get redpanda --namespace kafka --watch`
redpanda, show seed servers - `kubectl --namespace kafka exec redpanda-0 -c redpanda -- cat etc/redpanda/redpanda.yaml`
