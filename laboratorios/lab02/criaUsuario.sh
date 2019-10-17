
##
# fabric
echo "127.0.0.1   ca.ibm.com" > /etc/hosts
echo "" > /etc/resolv.conf


fabric-ca-client enroll -u https://admin:adminpw@ca.ibm.com:7054 --tls.certfiles /etc/hyperledger/fabric-ca-server-config/ca.ibm.com-cert.pem
fabric-ca-client register  --id.name ibm01 --id.type client --id.secret ibm123 -u https://admin:adminpw@ca.ibm.com:7054 --tls.certfiles /etc/hyperledger/fabric-ca-server-config/ca.ibm.com-cert.pem


fabric-ca-client enroll -u https://ibm01:ibm123@ca.ibm.com:7054 --tls.certfiles /etc/hyperledger/fabric-ca-server-config/ca.ibm.com-cert.pem
