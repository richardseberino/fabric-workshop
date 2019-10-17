peer channel create -o orderer-svc:7050 -c ibm-channel -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/tlsca.ibm.com-cert.pem
peer channel fetch config -o orderer-svc:7050 -c ibm-channel --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/tlsca.ibm.com-cert.pem
peer channel join -b ibm-channel_config.block --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/tlsca.ibm.com-cert.pem
peer channel getinfo -c ibm-channel
