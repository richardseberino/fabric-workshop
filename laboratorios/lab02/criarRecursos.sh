sudo mkdir -p /blockchain/postgres
kubectl apply -f postgres.yaml
sudo mkdir -p /blockchain/certificados
sudo cp fabric-ca-server-config.yaml /blockchain/certificados
sudo cp criaUsuario.sh /blockchain/certificados

mkdir -p /tmp/crypto
export DIRATUAL=$PWD

cd /tmp/crypto
$DIRATUAL/bin/cryptogen generate --config=$DIRATUAL/crypto-config.yaml

cd crypto-config
sudo cp ordererOrganizations/ibm.com/ca/*_sk /blockchain/certificados/keyfile
sudo cp ordererOrganizations/ibm.com/ca/ca.ibm.com-cert.pem /blockchain/certificados
sleep 10
cd $DIRATUAL
kubectl apply -f fabric-ca.yaml
