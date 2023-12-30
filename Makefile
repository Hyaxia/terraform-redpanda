# - the reason we run `kubectl kustomize` is that terraform cant create CRD and use them in the same run - https://github.com/hashicorp/terraform-provider-kubernetes/issues/1917
# 	so we create CRD first and then run terraform
# - this is a version with a single node and single replica. if we want multiple nodes,
# 	we need to run the following command which will prevent nodes from being deployed on the control plane node:
# 	`kubectl taint node -l node-role.kubernetes.io/control-plane="" node-role.kubernetes.io/control-plane=:NoSchedule --overwrite`
infra-up:
	export KUBE_CONFIG_PATH=~/.kube/config
	minikube start
	kubectl kustomize https://github.com/redpanda-data/redpanda-operator//src/go/k8s/config/crd | kubectl apply -f -
	terraform init -upgrade
	terraform apply -auto-approve

infra-down:
	minikube delete
