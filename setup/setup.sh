#
brew install kind

# starting a new cluster
kind create cluster -n crossplane-devenv-automation

brew install helm
helm repo add crossplane-stable https://charts.crossplane.io/stable
helm repo update

helm install crossplane --namespace crossplane-system crossplane-stable/crossplane --create-namespace

# make shure endpoints are there
kubectl api-resources | grep crossplane

k get crds

# make sure to have 1.14
kubectl -n crossplane-system get deployments.apps crossplane -o json | jq '.metadata.labels."app.kubernetes.io/version"' 

# hub and spoke
# access to aws

k apply -f providers/provider-aws.yaml       

kubectl create secret \
generic aws-secret \
-n crossplane-system \
--from-file=creds=./aws-credentials.txt

cd application/webserver
go mod init stillforward.de/crossplane-dev-env-automation-webserver 
go mod tidy

go build .
docker build . -t tomdoc/crossplane-dev-env-automation-webserver:latest
docker push tomdoc/crossplane-dev-env-automation-webserver:latest

docker push <docker-hub-username>/<repository-name>:<tag>

k apply -f cr