# To interact with fabric-CA Server , we need another tool on our side.It can be either a Fabric-CA-Client or a Fabric SDKs.
# Steps to follow to generate crypto materials:

#1 Bring up the Fabric CA server which is used as the CA of that organization.
#2 Use Fabric CA client to enroll a CA admin
#3 With the CA admin, use Fabric CA client to register and enroll every entity(peer, orderer, and user) one by one to the Fabric CA server.
#4 Move the result material to the directory structure.

source scriptUtils.sh
export PATH=${PWD}/../bin:$PATH

certificatesForHospitals() {
    echo
    echo "Enroll the CA admin"
    echo
    mkdir -p consortium/crypto-config/peerOrganizatione/hospital/
    export FABRIC_CA_CLIENT_HOME=${PWD}/consortium/crypto-config/peerOrganizations/hospital/

    # To go back to the previous folder
    # echo "S{PWD%/[^/]*}"
    #Following Command creates public and private keys for the CA admin
    
    fabric-ca-client enroll -u https://admin:adminpw@localhost:1010 --caname ca.hospital --tls.certfiles ${PWD}/consortium/fabric-ca/hospital/tls-cert.pem

    # Create a config.yaml file to enable the OU identifiers,
    # and keep the oU identifiers for each type of entity.
    # They are peer, orderer, client and admin.
    echo 'NodeOUs:
    Enable: true
    clientOUIdentifier:
        Certificate: cacerts/localhost-1010-ca-hospital.pem
        OrganizationalUnitIdentifier: client
    PeerOUIdentifier:
        Certificate: cacerts/localhost-1010-ca-hospital. pem
        OrganizationalUnitIdentifier: peer
    AdminOUIdentifier:
        Certificate: cacerts/localhost-1010-ca-hospital.pem
        OrganizationalUnitIdentifier: admin
    OrdererOUIdentifier:
        Certificate: cacerts/localhost-1010-ca-hospital.pem
        OrganizationalUnitIdentifier: orderer' >${PWD}/consortium/crypto-config/peerOrganizations/hospital/msp/config.yaml

    echo
    echo "Register peer0"
    echo
    fabric-ca-client register --caname ca.hospital --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/consortium/fabric-ca/hospital/tls-cert.pem

    echo
    echo "Register peer1"
    echo
    fabric-ca-client register --caname ca.hospital --1d.name peer1 --1d.secret peer1pw --id.type peer --tls.certfiles ${PWD}/consortium/fabric-ca/hospital/tls-cert.pem

    echo
    echo "Register user"
    echo
    fabric-ca-client register --caname ca.hospital --id.name user1 --id.secret user1pw --id. type client --tls.certfiles ${PWD}/consortium/fabric-ca/hospital/tls-cert.pem

    echo
    echo "Register the org admin"
    echo
    fabric-ca-client register --caname ca.hospital --id.name hospitaladmin --id.secret hospitaladminpw --id.type admin --tls.certfiles ${PWD}/consortium/fabric-ca/hospital/tls-cert.pem

    # Create a directory for peers
    mkdir -p consortium/crypto-config/peerOrganizations/hospital/peers

    ######################################################################################################################
    # Peer 0
    mkdir -p consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital

    echo
    echo "## Generate the peer0 msp"
    echo
    fabric-ca-client enroll -u http|://peer0:peer@pw@localhost:1010 --caname ca.hospital -M S{PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/msp --csr.hosts peer0.hospital --tls certifiles ${PWD}/consortium/fabric-ca/hospital/tls-cert.pem

    cp ${PWD}/consortium/crypto-config/peerOrganizations/hospital/msp/config.yaml ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/msp/config.yaml

    echo
    echo "## Generate the peer0-tls certificates"
    echo
    fabric-ca-client enroll -u https://peer0:peer0pw@localhost:1010 -- caname ca.hospital -M ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/tls --enrollment.profile tls --csr.hosts peer0.hospital --tls.certfiles ${PWD}/consortium/fabric-ca/hospital/tls-cert.pem

    cp ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/tls/tlscacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/tls/ca.crt
    cp ${PwD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/tls/signcerts/* ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/tls/server.crt
    cp s{PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/tls/keystore/* ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/tls/server.key

    mkdir S{PWD}/consortium/crypto-config/peerorganizations/hospital/msp/tlscacerts
    cp S{PWD}/consortium/crypto-config/peerorganizations/hospital/peers/peer0.hospital/tls/tlscacerts/* ${PWD}/consortium/crypto-config/peerorganizations/hospital/msp/tlsc

    mkdir ${PWD}/consortium/crypto-config/peerOrganizations/hospital/tlsca
    cp ${PWD}/consortium/crypto-config/peerorganizations/hospital/peers/peere.hospital/tls/tlscacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/hospital/tlsca/tl

}