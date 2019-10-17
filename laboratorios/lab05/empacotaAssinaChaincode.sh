peer chaincode package -n contrato-ibm -v 1.0 -l node -p /opt/gopath/src/github.com/hyperledger/fabric/peer/chaincode -s -S /opt/gopath/src/github.com/hyperledger/fabric/peer/contrato_ibm_1.0.pkg
peer chaincode signpackage /opt/gopath/src/github.com/hyperledger/fabric/peer/contrato_ibm_1.0.pkg /opt/gopath/src/github.com/hyperledger/fabric/peer/contrato_ibm_1.0.signed
