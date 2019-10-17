export DIRATUAL=$PWD
#cd /tmp/crypto/crypto-config
#export CHANNEL_NAME="ibm-channel"

#sudo cp ordererOrganizations/ibm.com/ca/*_sk /blockchain/certificados/keyfile
#sudo cp ordererOrganizations/ibm.com/ca/ca.ibm.com-cert.pem /blockchain/certificados
#cd $DIRATUAL

sudo mkdir -p /blockchain/peer01
sudo mkdir -p /blockchain/peer02

#sudo cp /tmp/crypto/crypto-config/genesis.block /blockchain/order01
#sudo cp /tmp/crypto/crypto-config/genesis.block /blockchain/order02

sudo cp -r /tmp/crypto/crypto-config/peerOrganizations/ibm.com/peers/peer1.ibm.com/tls /blockchain/peer01
sudo cp -r /tmp/crypto/crypto-config/peerOrganizations/ibm.com/peers/peer2.ibm.com/tls /blockchain/peer02
sudo mkdir /blockchain/peer01/msp
sudo mkdir /blockchain/peer02/msp
sudo cp -r /tmp/crypto/crypto-config/peerOrganizations/ibm.com/users /blockchain/peer01/msp
sudo cp -r /tmp/crypto/crypto-config/peerOrganizations/ibm.com/users /blockchain/peer02/msp

sudo cp -r /tmp/crypto/crypto-config/peerOrganizations/ibm.com/peers/* /blockchain/certificados
sudo cp -r /tmp/crypto/crypto-config/peerOrganizations/ibm.com/users/Admin@ibm.com /blockchain/certificados
sudo cp -r /tmp/crypto/crypto-config/ordererOrganizations/ibm.com/orderers/orderer1.ibm.com/msp/tlscacerts/tlsca.ibm.com-cert.pem /blockchain/certificados
sudo cp -r /tmp/crypto/crypto-config/channel.tx /blockchain/certificados
sudo cp -r /tmp/crypto/crypto-config/ibmanchors.tx /blockchain/certificados
sudo cp criarCanal.sh /blockchain/certificados/peer1.ibm.com
sudo cp joinCanal.sh /blockchain/certificados/peer2.ibm.com
echo "Criando os bancos de dados couchDb para armazenar o ledger em cada peer"
kubectl apply -f couchdb.yaml
sleep 10
echo "Criando os Pods dos Peers da organizacao IBM"
kubectl apply -f peers.yaml

echo "Criando os clientes para os Peers da ogranizacao IBM"
kubectl apply -f peerCli.yaml

sleep 10

echo "Criando o canal pelo peer1"
kubectl exec -ti cli-peer1-pod bash /opt/gopath/src/github.com/hyperledger/fabric/peer/peer1.ibm.com/criarCanal.sh
echo "Adicionando peer2 ao canal "
kubectl exec -ti cli-peer2-pod bash /opt/gopath/src/github.com/hyperledger/fabric/peer/peer2.ibm.com/joinCanal.sh
