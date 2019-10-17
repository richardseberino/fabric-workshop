peer channel fetch 0 ibm-channel_genesis.block -o orderer-svc:7050 -c ibm-channel --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/tlsca.ibm.com-cert.pem
peer channel join -b ibm-channel_genesis.block
