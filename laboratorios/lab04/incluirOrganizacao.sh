peer channel fetch config config_block.pb -o orderer-svc:7050 -c ibm-channel --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/tlsca.ibm.com-cert.pem
configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config > config.json
jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups": {"redhat":.[1]}}}}}' config.json /opt/gopath/src/github.com/hyperledger/fabric/peer/redhat.json > modified_config.json
configtxlator proto_encode --input config.json --type common.Config --output config.pb
configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb
configtxlator compute_update --channel_id ibm-channel --original config.pb  --updated modified_config.pb --output redhat_update.pb
configtxlator proto_decode --input redhat_update.pb --type common.ConfigUpdate | jq . > redhat_update.json

echo '{"payload":{"header":{"channel_header":{"channel_id":"ibm-channel", "type":2}},"data":{"config_update":'$(cat redhat_update.json)'}}}' | jq . > redhat_update_in_envelope.json
configtxlator proto_encode --input redhat_update_in_envelope.json --type common.Envelope --output redhat_update_in_envelope.pb
peer channel signconfigtx -f redhat_update_in_envelope.pb
peer channel update -f redhat_update_in_envelope.pb -c ibm-channel -o orderer-svc:7050  --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/tlsca.ibm.com-cert.pem
