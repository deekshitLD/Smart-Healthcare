# To interact with Fabric-CA Server, we need another tool on our side. It can be either a Fabric-CA Client or Fabric SDKs.
# Steps to follow to generate crypto materials:

# 1. Bring up the Fabric-CA Server which is used as the CA of that organization.
# 2. Use Fabric-CA Client to enroll a CA Admin.
# 3. With the CA Admin, use Fabric-CA Client to register and enroll every entity (peer, orderer, user, etc) one by one to the Fabric-CA Server.
# 4. Move the result material to the directory structure.

source scriptUtils.sh
export PATH=${PWD}/../bin:$PATH

certificatesForHospital() {
    echo
    echo "Enroll the CA admin"
    echo
    mkdir -p consortium/crypto-config/peerOrganizations/hospital/
    export FABRIC_CA_CLIENT_HOME=${PWD}/consortium/crypto-config/peerOrganizations/hospital/

    # To go back to the previous folder
    # echo "${PWD%/[^/]*}"

    fabric-ca-client enroll -u https://admin:adminpw@localhost:1010 --caname ca.hospital --tls.certfiles ${PWD}/consortium/fabric-ca/hospital/tls-cert.pem

    # Create a config.yaml file to enable the OU identifiers,
    # and keep the OU identifiers for each type of entity.
    # They are peer, orderer, client and admin.
    echo 'NodeOUs:
    Enable: true
    ClientOUIdentifier:
        Certificate: cacerts/localhost-1010-ca-hospital.pem
        OrganizationalUnitIdentifier: client
    PeerOUIdentifier:
        Certificate: cacerts/localhost-1010-ca-hospital.pem
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
    fabric-ca-client register --caname ca.hospital --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles ${PWD}/consortium/fabric-ca/hospital/tls-cert.pem

    echo
    echo "Register user"
    echo
    fabric-ca-client register --caname ca.hospital --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/consortium/fabric-ca/hospital/tls-cert.pem

    echo
    echo "Register the org admin"
    echo
    fabric-ca-client register --caname ca.hospital --id.name hospitaladmin --id.secret hospitaladminpw --id.type admin --tls.certfiles ${PWD}/consortium/fabric-ca/hospital/tls-cert.pem

    # Create a directory for peers
    mkdir -p consortium/crypto-config/peerOrganizations/hospital/peers

    ###########################################################################################################
    #  Peer 0
    mkdir -p consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital

    echo
    echo "## Generate the peer0 msp"
    echo
    fabric-ca-client enroll -u https://peer0:peer0pw@localhost:1010 --caname ca.hospital -M ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/msp --csr.hosts peer0.hospital --tls.certfiles ${PWD}/consortium/fabric-ca/hospital/tls-cert.pem

    cp ${PWD}/consortium/crypto-config/peerOrganizations/hospital/msp/config.yaml ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/msp/config.yaml

    echo
    echo "## Generate the peer0-tls certificates"
    echo
    fabric-ca-client enroll -u https://peer0:peer0pw@localhost:1010 --caname ca.hospital -M ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/tls --enrollment.profile tls --csr.hosts peer0.hospital --csr.hosts localhost --tls.certfiles ${PWD}/consortium/fabric-ca/hospital/tls-cert.pem

    cp ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/tls/tlscacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/tls/ca.crt
    cp ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/tls/signcerts/* ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/tls/server.crt
    cp ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/tls/keystore/* ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/tls/server.key

    mkdir ${PWD}/consortium/crypto-config/peerOrganizations/hospital/msp/tlscacerts
    cp ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/tls/tlscacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/hospital/msp/tlscacerts/ca.crt

    mkdir ${PWD}/consortium/crypto-config/peerOrganizations/hospital/tlsca
    cp ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/tls/tlscacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/hospital/tlsca/tlsca.hospital-cert.pem

    mkdir ${PWD}/consortium/crypto-config/peerOrganizations/hospital/ca
    cp ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/msp/cacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/hospital/ca/ca.hospital-cert.pem
    cp ${PWD}/consortium/crypto-config/peerOrganizations/hospital/msp/keystore/* ${PWD}/consortium/crypto-config/peerOrganizations/hospital/ca/

    ###########################################################################################################

    # Peer1

    mkdir -p consortium/crypto-config/peerOrganizations/hospital/peers/peer1.hospital

    echo
    echo "## Generate the peer1 msp"
    echo
    fabric-ca-client enroll -u https://peer1:peer1pw@localhost:1010 --caname ca.hospital -M ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer1.hospital/msp --csr.hosts peer1.hospital --tls.certfiles ${PWD}/consortium/fabric-ca/hospital/tls-cert.pem

    cp ${PWD}/consortium/crypto-config/peerOrganizations/hospital/msp/config.yaml ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer1.hospital/msp/config.yaml

    echo
    echo "## Generate the peer1-tls certificates"
    echo
    fabric-ca-client enroll -u https://peer1:peer1pw@localhost:1010 --caname ca.hospital -M ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer1.hospital/tls --enrollment.profile tls --csr.hosts peer1.hospital --csr.hosts localhost --tls.certfiles ${PWD}/consortium/fabric-ca/hospital/tls-cert.pem

    cp ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer1.hospital/tls/tlscacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer1.hospital/tls/ca.crt
    cp ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer1.hospital/tls/signcerts/* ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer1.hospital/tls/server.crt
    cp ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer1.hospital/tls/keystore/* ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer1.hospital/tls/server.key

    ###########################################################################################################

    mkdir -p consortium/crypto-config/peerOrganizations/hospital/users
    mkdir -p consortium/crypto-config/peerOrganizations/hospital/users/User1

    echo
    echo "## Generate the user msp"
    echo
    fabric-ca-client enroll -u https://user1:user1pw@localhost:1010 --caname ca.hospital -M ${PWD}/consortium/crypto-config/peerOrganizations/hospital/users/User1/msp --tls.certfiles ${PWD}/consortium/fabric-ca/hospital/tls-cert.pem

    mkdir -p consortium/crypto-config/peerOrganizations/hospital/users/Admin@hospital

    echo
    echo "## Generate the org admin msp"
    echo
    fabric-ca-client enroll -u https://hospitaladmin:hospitaladminpw@localhost:1010 --caname ca.hospital -M ${PWD}/consortium/crypto-config/peerOrganizations/hospital/users/Admin@hospital/msp --tls.certfiles ${PWD}/consortium/fabric-ca/hospital/tls-cert.pem

    cp ${PWD}/consortium/crypto-config/peerOrganizations/hospital/msp/config.yaml ${PWD}/consortium/crypto-config/peerOrganizations/hospital/users/Admin@hospital/msp/config.yaml
}

certificatesForLaboratory() {
    echo
    echo "Enroll the CA admin"
    echo
    mkdir -p consortium/crypto-config/peerOrganizations/laboratory/
    export FABRIC_CA_CLIENT_HOME=${PWD}/consortium/crypto-config/peerOrganizations/laboratory/


    fabric-ca-client enroll -u https://admin:adminpw@localhost:1020 --caname ca.laboratory --tls.certfiles ${PWD}/consortium/fabric-ca/laboratory/tls-cert.pem

    # Create a config.yaml file to enable the OU identifiers,
    # and keep the OU identifiers for each type of entity.
    # They are peer, orderer, client and admin.
    echo 'NodeOUs:
    Enable: true
    ClientOUIdentifier:
        Certificate: cacerts/localhost-1020-ca-laboratory.pem
        OrganizationalUnitIdentifier: client
    PeerOUIdentifier:
        Certificate: cacerts/localhost-1020-ca-laboratory.pem
        OrganizationalUnitIdentifier: peer
    AdminOUIdentifier:
        Certificate: cacerts/localhost-1020-ca-laboratory.pem
        OrganizationalUnitIdentifier: admin
    OrdererOUIdentifier:
        Certificate: cacerts/localhost-1020-ca-laboratory.pem
        OrganizationalUnitIdentifier: orderer' >${PWD}/consortium/crypto-config/peerOrganizations/laboratory/msp/config.yaml

    echo
    echo "Register peer0"
    echo
    fabric-ca-client register --caname ca.laboratory --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/consortium/fabric-ca/laboratory/tls-cert.pem

    echo
    echo "Register peer1"
    echo
    fabric-ca-client register --caname ca.laboratory --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles ${PWD}/consortium/fabric-ca/laboratory/tls-cert.pem

    echo
    echo "Register user"
    echo
    fabric-ca-client register --caname ca.laboratory --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/consortium/fabric-ca/laboratory/tls-cert.pem

    echo
    echo "Register the org admin"
    echo
    fabric-ca-client register --caname ca.laboratory --id.name laboratoryadmin --id.secret laboratoryadminpw --id.type admin --tls.certfiles ${PWD}/consortium/fabric-ca/laboratory/tls-cert.pem

    # Create a directory for peers
    mkdir -p consortium/crypto-config/peerOrganizations/laboratory/peers

    ###########################################################################################################
    #  Peer 0
    mkdir -p consortium/crypto-config/peerOrganizations/laboratory/peers/peer0.laboratory

    echo
    echo "## Generate the peer0 msp"
    echo
    fabric-ca-client enroll -u https://peer0:peer0pw@localhost:1020 --caname ca.laboratory -M ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/peers/peer0.laboratory/msp --csr.hosts peer0.laboratory --tls.certfiles ${PWD}/consortium/fabric-ca/laboratory/tls-cert.pem

    cp ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/msp/config.yaml ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/peers/peer0.laboratory/msp/config.yaml

    echo
    echo "## Generate the peer0-tls certificates"
    echo
    fabric-ca-client enroll -u https://peer0:peer0pw@localhost:1020 --caname ca.laboratory -M ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/peers/peer0.laboratory/tls --enrollment.profile tls --csr.hosts peer0.laboratory --csr.hosts localhost --tls.certfiles ${PWD}/consortium/fabric-ca/laboratory/tls-cert.pem

    cp ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/peers/peer0.laboratory/tls/tlscacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/peers/peer0.laboratory/tls/ca.crt
    cp ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/peers/peer0.laboratory/tls/signcerts/* ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/peers/peer0.laboratory/tls/server.crt
    cp ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/peers/peer0.laboratory/tls/keystore/* ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/peers/peer0.laboratory/tls/server.key

    mkdir ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/msp/tlscacerts
    cp ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/peers/peer0.laboratory/tls/tlscacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/msp/tlscacerts/ca.crt

    mkdir ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/tlsca
    cp ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/peers/peer0.laboratory/tls/tlscacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/tlsca/tlsca.laboratory-cert.pem

    mkdir ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/ca
    cp ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/peers/peer0.laboratory/msp/cacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/ca/ca.laboratory-cert.pem
    cp ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/msp/keystore/* ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/ca/

    ###########################################################################################################

    # Peer1

    mkdir -p consortium/crypto-config/peerOrganizations/laboratory/peers/peer1.laboratory

    echo
    echo "## Generate the peer1 msp"
    echo
    fabric-ca-client enroll -u https://peer1:peer1pw@localhost:1020 --caname ca.laboratory -M ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/peers/peer1.laboratory/msp --csr.hosts peer1.laboratory --tls.certfiles ${PWD}/consortium/fabric-ca/laboratory/tls-cert.pem

    cp ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/msp/config.yaml ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/peers/peer1.laboratory/msp/config.yaml

    echo
    echo "## Generate the peer1-tls certificates"
    echo
    fabric-ca-client enroll -u https://peer1:peer1pw@localhost:1020 --caname ca.laboratory -M ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/peers/peer1.laboratory/tls --enrollment.profile tls --csr.hosts peer1.laboratory --csr.hosts localhost --tls.certfiles ${PWD}/consortium/fabric-ca/laboratory/tls-cert.pem

    cp ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/peers/peer1.laboratory/tls/tlscacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/peers/peer1.laboratory/tls/ca.crt
    cp ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/peers/peer1.laboratory/tls/signcerts/* ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/peers/peer1.laboratory/tls/server.crt
    cp ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/peers/peer1.laboratory/tls/keystore/* ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/peers/peer1.laboratory/tls/server.key

    ###########################################################################################################

    mkdir -p consortium/crypto-config/peerOrganizations/laboratory/users
    mkdir -p consortium/crypto-config/peerOrganizations/laboratory/users/User1@laboratory

    echo
    echo "## Generate the user msp"
    echo
    fabric-ca-client enroll -u https://user1:user1pw@localhost:1020 --caname ca.laboratory -M ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/users/User1@laboratory/msp --tls.certfiles ${PWD}/consortium/fabric-ca/laboratory/tls-cert.pem

    mkdir -p consortium/crypto-config/peerOrganizations/laboratory/users/Admin@laboratory

    echo
    echo "## Generate the org admin msp"
    echo
    fabric-ca-client enroll -u https://laboratoryadmin:laboratoryadminpw@localhost:1020 --caname ca.laboratory -M ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/users/Admin@laboratory/msp --tls.certfiles ${PWD}/consortium/fabric-ca/laboratory/tls-cert.pem

    cp ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/msp/config.yaml ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/users/Admin@laboratory/msp/config.yaml
}

certificatesForPharmacy() {
    echo
    echo "Enroll the CA admin"
    echo
    mkdir -p consortium/crypto-config/peerOrganizations/pharmacy/
    export FABRIC_CA_CLIENT_HOME=${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/

    # To go back to the previous folder
    # echo "${PWD%/[^/]*}"

    fabric-ca-client enroll -u https://admin:adminpw@localhost:1040 --caname ca.pharmacy --tls.certfiles ${PWD}/consortium/fabric-ca/pharmacy/tls-cert.pem

    # Create a config.yaml file to enable the OU identifiers,
    # and keep the OU identifiers for each type of entity.
    # They are peer, orderer, client and admin.
    echo 'NodeOUs:
    Enable: true
    ClientOUIdentifier:
        Certificate: cacerts/localhost-1040-ca-pharmacy.pem
        OrganizationalUnitIdentifier: client
    PeerOUIdentifier:
        Certificate: cacerts/localhost-1040-ca-pharmacy.pem
        OrganizationalUnitIdentifier: peer
    AdminOUIdentifier:
        Certificate: cacerts/localhost-1040-ca-pharmacy.pem
        OrganizationalUnitIdentifier: admin
    OrdererOUIdentifier:
        Certificate: cacerts/localhost-1040-ca-pharmacy.pem
        OrganizationalUnitIdentifier: orderer' >${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/msp/config.yaml

    echo
    echo "Register peer0"
    echo
    fabric-ca-client register --caname ca.pharmacy --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/consortium/fabric-ca/pharmacy/tls-cert.pem

    echo
    echo "Register peer1"
    echo
    fabric-ca-client register --caname ca.pharmacy --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles ${PWD}/consortium/fabric-ca/pharmacy/tls-cert.pem

    echo
    echo "Register user"
    echo
    fabric-ca-client register --caname ca.pharmacy --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/consortium/fabric-ca/pharmacy/tls-cert.pem

    echo
    echo "Register the org admin"
    echo
    fabric-ca-client register --caname ca.pharmacy --id.name pharmacyadmin --id.secret pharmacyadminpw --id.type admin --tls.certfiles ${PWD}/consortium/fabric-ca/pharmacy/tls-cert.pem

    # Create a directory for peers
    mkdir -p consortium/crypto-config/peerOrganizations/pharmacy/peers

    ###########################################################################################################
    #  Peer 0
    mkdir -p consortium/crypto-config/peerOrganizations/pharmacy/peers/peer0.pharmacy

    echo
    echo "## Generate the peer0 msp"
    echo
    fabric-ca-client enroll -u https://peer0:peer0pw@localhost:1040 --caname ca.pharmacy -M ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/peers/peer0.pharmacy/msp --csr.hosts peer0.pharmacy --tls.certfiles ${PWD}/consortium/fabric-ca/pharmacy/tls-cert.pem

    cp ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/msp/config.yaml ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/peers/peer0.pharmacy/msp/config.yaml

    echo
    echo "## Generate the peer0-tls certificates"
    echo
    fabric-ca-client enroll -u https://peer0:peer0pw@localhost:1040 --caname ca.pharmacy -M ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/peers/peer0.pharmacy/tls --enrollment.profile tls --csr.hosts peer0.pharmacy --csr.hosts localhost --tls.certfiles ${PWD}/consortium/fabric-ca/pharmacy/tls-cert.pem

    cp ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/peers/peer0.pharmacy/tls/tlscacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/peers/peer0.pharmacy/tls/ca.crt
    cp ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/peers/peer0.pharmacy/tls/signcerts/* ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/peers/peer0.pharmacy/tls/server.crt
    cp ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/peers/peer0.pharmacy/tls/keystore/* ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/peers/peer0.pharmacy/tls/server.key

    mkdir ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/msp/tlscacerts
    cp ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/peers/peer0.pharmacy/tls/tlscacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/msp/tlscacerts/ca.crt

    mkdir ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/tlsca
    cp ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/peers/peer0.pharmacy/tls/tlscacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/tlsca/tlsca.pharmacy-cert.pem

    mkdir ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/ca
    cp ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/peers/peer0.pharmacy/msp/cacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/ca/ca.pharmacy-cert.pem
    cp ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/msp/keystore/* ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/ca/

    ###########################################################################################################

    # Peer1

    mkdir -p consortium/crypto-config/peerOrganizations/pharmacy/peers/peer1.pharmacy

    echo
    echo "## Generate the peer1 msp"
    echo
    fabric-ca-client enroll -u https://peer1:peer1pw@localhost:1040 --caname ca.pharmacy -M ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/peers/peer1.pharmacy/msp --csr.hosts peer1.pharmacy --tls.certfiles ${PWD}/consortium/fabric-ca/pharmacy/tls-cert.pem

    cp ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/msp/config.yaml ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/peers/peer1.pharmacy/msp/config.yaml

    echo
    echo "## Generate the peer1-tls certificates"
    echo
    fabric-ca-client enroll -u https://peer1:peer1pw@localhost:1040 --caname ca.pharmacy -M ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/peers/peer1.pharmacy/tls --enrollment.profile tls --csr.hosts peer1.pharmacy --csr.hosts localhost --tls.certfiles ${PWD}/consortium/fabric-ca/pharmacy/tls-cert.pem

    cp ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/peers/peer1.pharmacy/tls/tlscacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/peers/peer1.pharmacy/tls/ca.crt
    cp ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/peers/peer1.pharmacy/tls/signcerts/* ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/peers/peer1.pharmacy/tls/server.crt
    cp ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/peers/peer1.pharmacy/tls/keystore/* ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/peers/peer1.pharmacy/tls/server.key

    ###########################################################################################################

    mkdir -p consortium/crypto-config/peerOrganizations/pharmacy/users
    mkdir -p consortium/crypto-config/peerOrganizations/pharmacy/users/User1@pharmacy

    echo
    echo "## Generate the user msp"
    echo
    fabric-ca-client enroll -u https://user1:user1pw@localhost:1040 --caname ca.pharmacy -M ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/users/User1@pharmacy/msp --tls.certfiles ${PWD}/consortium/fabric-ca/pharmacy/tls-cert.pem

    mkdir -p consortium/crypto-config/peerOrganizations/pharmacy/users/Admin@pharmacy

    echo
    echo "## Generate the org admin msp"
    echo
    fabric-ca-client enroll -u https://pharmacyadmin:pharmacyadminpw@localhost:1040 --caname ca.pharmacy -M ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/users/Admin@pharmacy/msp --tls.certfiles ${PWD}/consortium/fabric-ca/pharmacy/tls-cert.pem

    cp ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/msp/config.yaml ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/users/Admin@pharmacy/msp/config.yaml
}

certificatesForInsProvider() {
    echo
    echo "Enroll the CA admin"
    echo
    mkdir -p consortium/crypto-config/peerOrganizations/ins-provider/
    export FABRIC_CA_CLIENT_HOME=${PWD}/consortium/crypto-config/peerOrganizations/ins-provider/

    # To go back to the previous folder
    # echo "${PWD%/[^/]*}"

    fabric-ca-client enroll -u https://admin:adminpw@localhost:1050 --caname ca.ins-provider --tls.certfiles ${PWD}/consortium/fabric-ca/ins-provider/tls-cert.pem

    # Create a config.yaml file to enable the OU identifiers,
    # and keep the OU identifiers for each type of entity.
    # They are peer, orderer, client and admin.
    echo 'NodeOUs:
    Enable: true
    ClientOUIdentifier:
        Certificate: cacerts/localhost-1050-ca-ins-provider.pem
        OrganizationalUnitIdentifier: client
    PeerOUIdentifier:
        Certificate: cacerts/localhost-1050-ca-ins-provider.pem
        OrganizationalUnitIdentifier: peer
    AdminOUIdentifier:
        Certificate: cacerts/localhost-1050-ca-ins-provider.pem
        OrganizationalUnitIdentifier: admin
    OrdererOUIdentifier:
        Certificate: cacerts/localhost-1050-ca-ins-provider.pem
        OrganizationalUnitIdentifier: orderer' >${PWD}/consortium/crypto-config/peerOrganizations/ins-provider/msp/config.yaml

    echo
    echo "Register peer0"
    echo
    fabric-ca-client register --caname ca.ins-provider --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/consortium/fabric-ca/ins-provider/tls-cert.pem

    echo
    echo "Register peer1"
    echo
    fabric-ca-client register --caname ca.ins-provider --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles ${PWD}/consortium/fabric-ca/ins-provider/tls-cert.pem

    echo
    echo "Register user"
    echo
    fabric-ca-client register --caname ca.ins-provider --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/consortium/fabric-ca/ins-provider/tls-cert.pem

    echo
    echo "Register the org admin"
    echo
    fabric-ca-client register --caname ca.ins-provider --id.name ins-provideradmin --id.secret ins-provideradminpw --id.type admin --tls.certfiles ${PWD}/consortium/fabric-ca/ins-provider/tls-cert.pem

    # Create a directory for peers
    mkdir -p consortium/crypto-config/peerOrganizations/ins-provider/peers

    ###########################################################################################################
    #  Peer 0
    mkdir -p consortium/crypto-config/peerOrganizations/ins-provider/peers/peer0.ins-provider

    echo
    echo "## Generate the peer0 msp"
    echo
    fabric-ca-client enroll -u https://peer0:peer0pw@localhost:1050 --caname ca.ins-provider -M ${PWD}/consortium/crypto-config/peerOrganizations/ins-provider/peers/peer0.ins-provider/msp --csr.hosts peer0.ins-provider --tls.certfiles ${PWD}/consortium/fabric-ca/ins-provider/tls-cert.pem

    cp ${PWD}/consortium/crypto-config/peerOrganizations/ins-provider/msp/config.yaml ${PWD}/consortium/crypto-config/peerOrganizations/ins-provider/peers/peer0.ins-provider/msp/config.yaml

    echo
    echo "## Generate the peer0-tls certificates"
    echo
    fabric-ca-client enroll -u https://peer0:peer0pw@localhost:1050 --caname ca.ins-provider -M ${PWD}/consortium/crypto-config/peerOrganizations/ins-provider/peers/peer0.ins-provider/tls --enrollment.profile tls --csr.hosts peer0.ins-provider --csr.hosts localhost --tls.certfiles ${PWD}/consortium/fabric-ca/ins-provider/tls-cert.pem

    cp ${PWD}/consortium/crypto-config/peerOrganizations/ins-provider/peers/peer0.ins-provider/tls/tlscacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/ins-provider/peers/peer0.ins-provider/tls/ca.crt
    cp ${PWD}/consortium/crypto-config/peerOrganizations/ins-provider/peers/peer0.ins-provider/tls/signcerts/* ${PWD}/consortium/crypto-config/peerOrganizations/ins-provider/peers/peer0.ins-provider/tls/server.crt
    cp ${PWD}/consortium/crypto-config/peerOrganizations/ins-provider/peers/peer0.ins-provider/tls/keystore/* ${PWD}/consortium/crypto-config/peerOrganizations/ins-provider/peers/peer0.ins-provider/tls/server.key

    mkdir ${PWD}/consortium/crypto-config/peerOrganizations/ins-provider/msp/tlscacerts
    cp ${PWD}/consortium/crypto-config/peerOrganizations/ins-provider/peers/peer0.ins-provider/tls/tlscacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/ins-provider/msp/tlscacerts/ca.crt

    mkdir ${PWD}/consortium/crypto-config/peerOrganizations/ins-provider/tlsca
    cp ${PWD}/consortium/crypto-config/peerOrganizations/ins-provider/peers/peer0.ins-provider/tls/tlscacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/ins-provider/tlsca/tlsca.ins-provider-cert.pem

    mkdir ${PWD}/consortium/crypto-config/peerOrganizations/ins-provider/ca
    cp ${PWD}/consortium/crypto-config/peerOrganizations/ins-provider/peers/peer0.ins-provider/msp/cacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/ins-provider/ca/ca.ins-provider-cert.pem
    cp ${PWD}/consortium/crypto-config/peerOrganizations/ins-provider/msp/keystore/* ${PWD}/consortium/crypto-config/peerOrganizations/ins-provider/ca/

    ###########################################################################################################

    # Peer1

    mkdir -p consortium/crypto-config/peerOrganizations/ins-provider/peers/peer1.ins-provider

    echo
    echo "## Generate the peer1 msp"
    echo
    fabric-ca-client enroll -u https://peer1:peer1pw@localhost:1050 --caname ca.ins-provider -M ${PWD}/consortium/crypto-config/peerOrganizations/ins-provider/peers/peer1.ins-provider/msp --csr.hosts peer1.ins-provider --tls.certfiles ${PWD}/consortium/fabric-ca/ins-provider/tls-cert.pem

    cp ${PWD}/consortium/crypto-config/peerOrganizations/ins-provider/msp/config.yaml ${PWD}/consortium/crypto-config/peerOrganizations/ins-provider/peers/peer1.ins-provider/msp/config.yaml

    echo
    echo "## Generate the peer1-tls certificates"
    echo
    fabric-ca-client enroll -u https://peer1:peer1pw@localhost:1050 --caname ca.ins-provider -M ${PWD}/consortium/crypto-config/peerOrganizations/ins-provider/peers/peer1.ins-provider/tls --enrollment.profile tls --csr.hosts peer1.ins-provider --csr.hosts localhost --tls.certfiles ${PWD}/consortium/fabric-ca/ins-provider/tls-cert.pem

    cp ${PWD}/consortium/crypto-config/peerOrganizations/ins-provider/peers/peer1.ins-provider/tls/tlscacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/ins-provider/peers/peer1.ins-provider/tls/ca.crt
    cp ${PWD}/consortium/crypto-config/peerOrganizations/ins-provider/peers/peer1.ins-provider/tls/signcerts/* ${PWD}/consortium/crypto-config/peerOrganizations/ins-provider/peers/peer1.ins-provider/tls/server.crt
    cp ${PWD}/consortium/crypto-config/peerOrganizations/ins-provider/peers/peer1.ins-provider/tls/keystore/* ${PWD}/consortium/crypto-config/peerOrganizations/ins-provider/peers/peer1.ins-provider/tls/server.key

    ###########################################################################################################

    mkdir -p consortium/crypto-config/peerOrganizations/ins-provider/users
    mkdir -p consortium/crypto-config/peerOrganizations/ins-provider/users/User1@ins-provider

    echo
    echo "## Generate the user msp"
    echo
    fabric-ca-client enroll -u https://user1:user1pw@localhost:1050 --caname ca.ins-provider -M ${PWD}/consortium/crypto-config/peerOrganizations/ins-provider/users/User1@ins-provider/msp --tls.certfiles ${PWD}/consortium/fabric-ca/ins-provider/tls-cert.pem

    mkdir -p consortium/crypto-config/peerOrganizations/ins-provider/users/Admin@ins-provider

    echo
    echo "## Generate the org admin msp"
    echo
    fabric-ca-client enroll -u https://ins-provideradmin:ins-provideradminpw@localhost:1050 --caname ca.ins-provider -M ${PWD}/consortium/crypto-config/peerOrganizations/ins-provider/users/Admin@ins-provider/msp --tls.certfiles ${PWD}/consortium/fabric-ca/ins-provider/tls-cert.pem

    cp ${PWD}/consortium/crypto-config/peerOrganizations/ins-provider/msp/config.yaml ${PWD}/consortium/crypto-config/peerOrganizations/ins-provider/users/Admin@ins-provider/msp/config.yaml
}

certificatesForOrderer() {
  echo
  echo "Enroll the CA admin"
  echo
  mkdir -p consortium/crypto-config/ordererOrganizations/example.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/consortium/crypto-config/ordererOrganizations/example.com


  fabric-ca-client enroll -u https://admin:adminpw@localhost:1030 --caname ca-orderer --tls.certfiles ${PWD}/consortium/fabric-ca/ordererOrg/tls-cert.pem


  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-1030-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-1030-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-1030-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-1030-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/consortium/crypto-config/ordererOrganizations/example.com/msp/config.yaml

  echo
  echo "Register orderer"
  echo

  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/consortium/fabric-ca/ordererOrg/tls-cert.pem


  echo
  echo "Register orderer2"
  echo

  fabric-ca-client register --caname ca-orderer --id.name orderer2 --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/consortium/fabric-ca/ordererOrg/tls-cert.pem


  echo
  echo "Register orderer3"
  echo

  fabric-ca-client register --caname ca-orderer --id.name orderer3 --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/consortium/fabric-ca/ordererOrg/tls-cert.pem


  echo
  echo "Register the orderer admin"
  echo

  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles ${PWD}/consortium/fabric-ca/ordererOrg/tls-cert.pem


  mkdir -p consortium/crypto-config/ordererOrganizations/example.com/orderers
  mkdir -p consortium/crypto-config/ordererOrganizations/example.com/orderers/example.com

  # ---------------------------------------------------------------------------
  #  Orderer

  mkdir -p consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com

  echo
  echo "## Generate the orderer msp"
  echo

  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:1030 --caname ca-orderer -M ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles ${PWD}/consortium/fabric-ca/ordererOrg/tls-cert.pem


  cp ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/msp/config.yaml ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/config.yaml

  echo
  echo "## Generate the orderer-tls certificates"
  echo

  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:1030 --caname ca-orderer -M ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls --enrollment.profile tls --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles ${PWD}/consortium/fabric-ca/ordererOrg/tls-cert.pem


  cp ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/* ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt
  cp ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/signcerts/* ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt
  cp ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/keystore/* ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key

  mkdir ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts
  cp ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/* ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  mkdir ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/msp/tlscacerts
  cp ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/* ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  mkdir ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/ca
  cp ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/keystore/* ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/ca/

  # -----------------------------------------------------------------------
  #  Orderer 2

  mkdir -p consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com

  echo
  echo "## Generate the orderer msp"
  echo

  fabric-ca-client enroll -u https://orderer2:ordererpw@localhost:1030 --caname ca-orderer -M ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/msp --csr.hosts orderer2.example.com --csr.hosts localhost --tls.certfiles ${PWD}/consortium/fabric-ca/ordererOrg/tls-cert.pem


  cp ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/msp/config.yaml ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/msp/config.yaml

  echo
  echo "## Generate the orderer-tls certificates"
  echo

  fabric-ca-client enroll -u https://orderer2:ordererpw@localhost:1030 --caname ca-orderer -M ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls --enrollment.profile tls --csr.hosts orderer2.example.com --csr.hosts localhost --tls.certfiles ${PWD}/consortium/fabric-ca/ordererOrg/tls-cert.pem


  cp ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/tlscacerts/* ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/ca.crt
  cp ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/signcerts/* ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/server.crt
  cp ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/keystore/* ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/server.key

  mkdir ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/msp/tlscacerts
  cp ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/tlscacerts/* ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  # mkdir ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/msp/tlscacerts
  # cp ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/tlscacerts/* ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  # ---------------------------------------------------------------------------
  #  Orderer 3
  mkdir -p consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com

  echo
  echo "## Generate the orderer msp"
  echo

  fabric-ca-client enroll -u https://orderer3:ordererpw@localhost:1030 --caname ca-orderer -M ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/msp --csr.hosts orderer3.example.com --csr.hosts localhost --tls.certfiles ${PWD}/consortium/fabric-ca/ordererOrg/tls-cert.pem


  cp ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/msp/config.yaml ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/msp/config.yaml

  echo
  echo "## Generate the orderer-tls certificates"
  echo

  fabric-ca-client enroll -u https://orderer3:ordererpw@localhost:1030 --caname ca-orderer -M ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls --enrollment.profile tls --csr.hosts orderer3.example.com --csr.hosts localhost --tls.certfiles ${PWD}/consortium/fabric-ca/ordererOrg/tls-cert.pem


  cp ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/tlscacerts/* ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/ca.crt
  cp ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/signcerts/* ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/server.crt
  cp ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/keystore/* ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/server.key

  mkdir ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/msp/tlscacerts
  cp ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/tlscacerts/* ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  mkdir ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/msp/tlscacerts
  cp ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/tlscacerts/* ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  # ---------------------------------------------------------------------------

  mkdir -p consortium/crypto-config/ordererOrganizations/example.com/users
  mkdir -p consortium/crypto-config/ordererOrganizations/example.com/users/Admin@example.com

  echo
  echo "## Generate the admin msp"
  echo

  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:1030 --caname ca-orderer -M ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp --tls.certfiles ${PWD}/consortium/fabric-ca/ordererOrg/tls-cert.pem


  cp ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/msp/config.yaml ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp/config.yaml

}

#certificate authorities compose file
COMPOSE_FILE_CA=docker/docker-compose-ca.yaml

IMAGE_TAG= docker-compose -f $COMPOSE_FILE_CA up -d 2>&1

sleep 6
docker ps

infoln "Creating Hospital Identities"
certificatesForHospital

infoln "Creating Laboratory Identities"
certificatesForLaboratory

infoln "Creating Pharmacy Identities"
certificatesForPharmacy

infoln "Creating Insurance Provider Identities"
certificatesForInsProvider

infoln "Creating Orderer Org Identities"
certificatesForOrderer

infoln "Generating CCP files for all the Organizations"
consortium/ccp-generate.sh