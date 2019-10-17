mkdir -p /tmp/cryptoRedhat
export DIRATUAL=$PWD
echo "Criando a estrutura da Organizacao Redhat"

cd /tmp/cryptoRedhat
$DIRATUAL/bin/cryptogen generate --config=$DIRATUAL/crypto-config.yaml
cd crypto-config
cp $DIRATUAL/configtx.yaml .
$DIRATUAL/bin/configtxgen -printOrg redhat > redhat.json

sudo mkdir -p /blockchain/peer00
sudo cp -r /tmp/cryptoRedhat/crypto-config/peerOrganizations/redhat.com/peers/peer0.redhat.com/tls /blockchain/peer00
sudo mkdir /blockchain/peer00/msp
sudo cp -r /tmp/cryptoRedhat/crypto-config/peerOrganizations/redhat.com/users /blockchain/peer00/msp

sudo cp -r /tmp/cryptoRedhat/crypto-config/peerOrganizations/redhat.com/peers/* /blockchain/certificados
sudo cp -r /tmp/cryptoRedhat/crypto-config/peerOrganizations/redhat.com/users/Admin@redhat.com /blockchain/certificados


cd $DIRATUAL

echo "Criando a base de dados couchDB para o Peer da Redhat"
kubectl apply -f couchDbRedhat.yaml
sleep 10
echo "Criando o Peer externo da organizacao RedHat"
kubectl apply -f peerRedhat.yaml
kubectl apply -f peerCliRedhat.yaml

sudo cp /tmp/cryptoRedhat/crypto-config/redhat.json /blockchain/certificados
sudo cp atualizarCanal.sh /blockchain/certificados/peer0.redhat.com
sudo cp incluirOrganizacao.sh /blockchain/certificados/peer1.ibm.com

echo "Incluindo a organizacao RedHat a Rede Blockchain IBM"
kubectl exec -ti cli-peer1-pod bash /opt/gopath/src/github.com/hyperledger/fabric/peer/peer1.ibm.com/incluirOrganizacao.sh
sleep 3
echo "Fazendo Join no Peer RedHat ao canal ibm-channel"
kubectl exec -ti cli-peer0-pod bash /opt/gopath/src/github.com/hyperledger/fabric/peer/peer0.redhat.com/atualizarCanal.sh
