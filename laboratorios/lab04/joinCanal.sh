peer channel fetch config -o orderer-svc:7050 -c ibm-channel --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/tlsca.ibm.com-cert.pem
peer channel join -b ibm-channel_config.block --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/tlsca.ibm.com-cert.pem
peer channel update -o orderer-svc:7050 -c ibm-channel -f /opt/gopath/src/github.com/hyperledger/fabric/peer/ibmanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/tlsca.ibm.com-cert.pem
