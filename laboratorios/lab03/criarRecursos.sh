export DIRATUAL=$PWD
cd /tmp/crypto/crypto-config
cp $DIRATUAL/configtx.yaml .
export FABRIC_CFG_PATH=$PWD
export CHANNEL_NAME="ibm-channel"
$DIRATUAL/bin/configtxgen -profile ModeKafkaOrderer -channelID ibm-system-channel -outputBlock /tmp/crypto/crypto-config/genesis.block
$DIRATUAL/bin/configtxgen -profile ModeKafkaChannel -outputCreateChannelTx /tmp/crypto/crypto-config/channel.tx -channelID $CHANNEL_NAME
$DIRATUAL/bin/configtxgen -profile ModeKafkaChannel -outputAnchorPeersUpdate /tmp/crypto/crypto-config/ibmanchors.tx -channelID $CHANNEL_NAME -asOrg ibm

sudo cp ordererOrganizations/ibm.com/ca/*_sk /blockchain/certificados/keyfile
sudo cp ordererOrganizations/ibm.com/ca/ca.ibm.com-cert.pem /blockchain/certificados
cd $DIRATUAL

sudo mkdir -p /blockchain/order01
sudo mkdir -p /blockchain/order02
sudo mkdir -p /blockchain/order03

sudo cp /tmp/crypto/crypto-config/genesis.block /blockchain/order01
sudo cp /tmp/crypto/crypto-config/genesis.block /blockchain/order02
sudo cp /tmp/crypto/crypto-config/genesis.block /blockchain/order03

sudo cp -r /tmp/crypto/crypto-config/ordererOrganizations/ibm.com/orderers/orderer1.ibm.com/tls /blockchain/order01
sudo cp -r /tmp/crypto/crypto-config/ordererOrganizations/ibm.com/orderers/orderer2.ibm.com/tls /blockchain/order02
sudo cp -r /tmp/crypto/crypto-config/ordererOrganizations/ibm.com/orderers/orderer3.ibm.com/tls /blockchain/order03
sudo cp -r /tmp/crypto/crypto-config/ordererOrganizations/ibm.com/orderers/orderer1.ibm.com/msp /blockchain/order01
sudo cp -r /tmp/crypto/crypto-config/ordererOrganizations/ibm.com/orderers/orderer2.ibm.com/msp /blockchain/order02
sudo cp -r /tmp/crypto/crypto-config/ordererOrganizations/ibm.com/orderers/orderer3.ibm.com/msp /blockchain/order03

kubectl apply -f zookeeper.yaml
sleep 5
kubectl apply -f kafka.yaml
sleep 5
kubectl apply -f orderer.yaml
