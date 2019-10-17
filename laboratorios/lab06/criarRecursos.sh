sudo mkdir /blockchain/prometheus
sudo cp prometheus.yaml /blockchain/prometheus

kubectl apply -f prometheuspod.yaml
kubectl apply -f grafana.yaml
