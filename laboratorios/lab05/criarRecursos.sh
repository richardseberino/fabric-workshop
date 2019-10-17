sudo cp empacotaAssinaChaincode.sh /blockchain/certificados/peer1.ibm.com
sudo cp instalaChainCode.sh /blockchain/certificados/peer1.ibm.com
sudo cp instanciaChaincode.sh /blockchain/certificados/peer1.ibm.com
sudo cp instalaChainCode.sh /blockchain/certificados/peer2.ibm.com
sudo cp instalaChainCode.sh /blockchain/certificados/peer0.redhat.com

sudo cp executaContratoPeer1.sh /blockchain/certificados/peer1.ibm.com
sudo cp executaContratoPeer2.sh /blockchain/certificados/peer2.ibm.com
sudo cp executaContratoPeer0.sh /blockchain/certificados/peer0.redhat.com

sudo cp -R chaincode /blockchain/certificados

echo "Empacotando e Assinando o Chaincode"
kubectl exec -ti cli-peer1-pod bash /opt/gopath/src/github.com/hyperledger/fabric/peer/peer1.ibm.com/empacotaAssinaChaincode.sh

echo "Instalando chaincode em todos os peers"
kubectl exec -ti cli-peer1-pod bash /opt/gopath/src/github.com/hyperledger/fabric/peer/peer1.ibm.com/instalaChainCode.sh
kubectl exec -ti cli-peer2-pod bash /opt/gopath/src/github.com/hyperledger/fabric/peer/peer2.ibm.com/instalaChainCode.sh
kubectl exec -ti cli-peer0-pod bash /opt/gopath/src/github.com/hyperledger/fabric/peer/peer0.redhat.com/instalaChainCode.sh

sleep 10
echo "Instanciando o Chaincode no canal"
kubectl exec -ti cli-peer0-pod bash /opt/gopath/src/github.com/hyperledger/fabric/peer/peer1.ibm.com/instanciaChaincode.sh
