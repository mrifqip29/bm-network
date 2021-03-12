createcertificatesForPenangkar() {
  echo
  echo "Enroll the CA admin"
  echo
  mkdir -p ../crypto-config/peerOrganizations/penangkar.example.com/
  export FABRIC_CA_CLIENT_HOME=${PWD}/../crypto-config/peerOrganizations/penangkar.example.com/

   
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca.penangkar.example.com --tls.certfiles ${PWD}/fabric-ca/penangkar/tls-cert.pem
   

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-penangkar-example-com.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-penangkar-example-com.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-penangkar-example-com.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-penangkar-example-com.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/../crypto-config/peerOrganizations/penangkar.example.com/msp/config.yaml

  echo
  echo "Register peer0"
  echo
  fabric-ca-client register --caname ca.penangkar.example.com --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/fabric-ca/penangkar/tls-cert.pem

  echo
  echo "Register user"
  echo
  fabric-ca-client register --caname ca.penangkar.example.com --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/fabric-ca/penangkar/tls-cert.pem

  echo
  echo "Register the org admin"
  echo
  fabric-ca-client register --caname ca.penangkar.example.com --id.name penangkaradmin --id.secret penangkaradminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/penangkar/tls-cert.pem

  mkdir -p ../crypto-config/peerOrganizations/penangkar.example.com/peers

  # -----------------------------------------------------------------------------------
  #  Peer 0
  mkdir -p ../crypto-config/peerOrganizations/penangkar.example.com/peers/peer0.penangkar.example.com

  echo
  echo "## Generate the peer0 msp"
  echo
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca.penangkar.example.com -M ${PWD}/../crypto-config/peerOrganizations/penangkar.example.com/peers/peer0.penangkar.example.com/msp --csr.hosts peer0.penangkar.example.com --tls.certfiles ${PWD}/fabric-ca/penangkar/tls-cert.pem

  cp ${PWD}/../crypto-config/peerOrganizations/penangkar.example.com/msp/config.yaml ${PWD}/../crypto-config/peerOrganizations/penangkar.example.com/peers/peer0.penangkar.example.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca.penangkar.example.com -M ${PWD}/../crypto-config/peerOrganizations/penangkar.example.com/peers/peer0.penangkar.example.com/tls --enrollment.profile tls --csr.hosts peer0.penangkar.example.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/penangkar/tls-cert.pem

  cp ${PWD}/../crypto-config/peerOrganizations/penangkar.example.com/peers/peer0.penangkar.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/penangkar.example.com/peers/peer0.penangkar.example.com/tls/ca.crt
  cp ${PWD}/../crypto-config/peerOrganizations/penangkar.example.com/peers/peer0.penangkar.example.com/tls/signcerts/* ${PWD}/../crypto-config/peerOrganizations/penangkar.example.com/peers/peer0.penangkar.example.com/tls/server.crt
  cp ${PWD}/../crypto-config/peerOrganizations/penangkar.example.com/peers/peer0.penangkar.example.com/tls/keystore/* ${PWD}/../crypto-config/peerOrganizations/penangkar.example.com/peers/peer0.penangkar.example.com/tls/server.key

  mkdir ${PWD}/../crypto-config/peerOrganizations/penangkar.example.com/msp/tlscacerts
  cp ${PWD}/../crypto-config/peerOrganizations/penangkar.example.com/peers/peer0.penangkar.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/penangkar.example.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/../crypto-config/peerOrganizations/penangkar.example.com/tlsca
  cp ${PWD}/../crypto-config/peerOrganizations/penangkar.example.com/peers/peer0.penangkar.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/penangkar.example.com/tlsca/tlsca.penangkar.example.com-cert.pem

  mkdir ${PWD}/../crypto-config/peerOrganizations/penangkar.example.com/ca
  cp ${PWD}/../crypto-config/peerOrganizations/penangkar.example.com/peers/peer0.penangkar.example.com/msp/cacerts/* ${PWD}/../crypto-config/peerOrganizations/penangkar.example.com/ca/ca.penangkar.example.com-cert.pem

  # --------------------------------------------------------------------------------------------------

  mkdir -p ../crypto-config/peerOrganizations/penangkar.example.com/users
  mkdir -p ../crypto-config/peerOrganizations/penangkar.example.com/users/User1@penangkar.example.com

  echo
  echo "## Generate the user msp"
  echo
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca.penangkar.example.com -M ${PWD}/../crypto-config/peerOrganizations/penangkar.example.com/users/User1@penangkar.example.com/msp --tls.certfiles ${PWD}/fabric-ca/penangkar/tls-cert.pem

  mkdir -p ../crypto-config/peerOrganizations/penangkar.example.com/users/Admin@penangkar.example.com

  echo
  echo "## Generate the org admin msp"
  echo
  fabric-ca-client enroll -u https://penangkaradmin:penangkaradminpw@localhost:7054 --caname ca.penangkar.example.com -M ${PWD}/../crypto-config/peerOrganizations/penangkar.example.com/users/Admin@penangkar.example.com/msp --tls.certfiles ${PWD}/fabric-ca/penangkar/tls-cert.pem

  cp ${PWD}/../crypto-config/peerOrganizations/penangkar.example.com/msp/config.yaml ${PWD}/../crypto-config/peerOrganizations/penangkar.example.com/users/Admin@penangkar.example.com/msp/config.yaml

}

# createcertificatesForPenangkar

createCertificatesForPetani() {
  echo
  echo "Enroll the CA admin"
  echo
  mkdir -p /../crypto-config/peerOrganizations/petani.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/../crypto-config/peerOrganizations/petani.example.com/

   
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca.petani.example.com --tls.certfiles ${PWD}/fabric-ca/petani/tls-cert.pem
   

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-petani-example-com.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-petani-example-com.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-petani-example-com.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-petani-example-com.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/../crypto-config/peerOrganizations/petani.example.com/msp/config.yaml

  echo
  echo "Register peer0"
  echo
   
  fabric-ca-client register --caname ca.petani.example.com --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/fabric-ca/petani/tls-cert.pem
   

  echo
  echo "Register user"
  echo
   
  fabric-ca-client register --caname ca.petani.example.com --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/fabric-ca/petani/tls-cert.pem
   

  echo
  echo "Register the org admin"
  echo
   
  fabric-ca-client register --caname ca.petani.example.com --id.name petaniadmin --id.secret petaniadminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/petani/tls-cert.pem
   

  mkdir -p ../crypto-config/peerOrganizations/petani.example.com/peers
  mkdir -p ../crypto-config/peerOrganizations/petani.example.com/peers/peer0.petani.example.com

  # --------------------------------------------------------------
  # Peer 0
  echo
  echo "## Generate the peer0 msp"
  echo
   
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca.petani.example.com -M ${PWD}/../crypto-config/peerOrganizations/petani.example.com/peers/peer0.petani.example.com/msp --csr.hosts peer0.petani.example.com --tls.certfiles ${PWD}/fabric-ca/petani/tls-cert.pem
   

  cp ${PWD}/../crypto-config/peerOrganizations/petani.example.com/msp/config.yaml ${PWD}/../crypto-config/peerOrganizations/petani.example.com/peers/peer0.petani.example.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
   
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca.petani.example.com -M ${PWD}/../crypto-config/peerOrganizations/petani.example.com/peers/peer0.petani.example.com/tls --enrollment.profile tls --csr.hosts peer0.petani.example.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/petani/tls-cert.pem
   

  cp ${PWD}/../crypto-config/peerOrganizations/petani.example.com/peers/peer0.petani.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/petani.example.com/peers/peer0.petani.example.com/tls/ca.crt
  cp ${PWD}/../crypto-config/peerOrganizations/petani.example.com/peers/peer0.petani.example.com/tls/signcerts/* ${PWD}/../crypto-config/peerOrganizations/petani.example.com/peers/peer0.petani.example.com/tls/server.crt
  cp ${PWD}/../crypto-config/peerOrganizations/petani.example.com/peers/peer0.petani.example.com/tls/keystore/* ${PWD}/../crypto-config/peerOrganizations/petani.example.com/peers/peer0.petani.example.com/tls/server.key

  mkdir ${PWD}/../crypto-config/peerOrganizations/petani.example.com/msp/tlscacerts
  cp ${PWD}/../crypto-config/peerOrganizations/petani.example.com/peers/peer0.petani.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/petani.example.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/../crypto-config/peerOrganizations/petani.example.com/tlsca
  cp ${PWD}/../crypto-config/peerOrganizations/petani.example.com/peers/peer0.petani.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/petani.example.com/tlsca/tlsca.petani.example.com-cert.pem

  mkdir ${PWD}/../crypto-config/peerOrganizations/petani.example.com/ca
  cp ${PWD}/../crypto-config/peerOrganizations/petani.example.com/peers/peer0.petani.example.com/msp/cacerts/* ${PWD}/../crypto-config/peerOrganizations/petani.example.com/ca/ca.petani.example.com-cert.pem

  # --------------------------------------------------------------------------------
 
  mkdir -p ../crypto-config/peerOrganizations/petani.example.com/users
  mkdir -p ../crypto-config/peerOrganizations/petani.example.com/users/User1@petani.example.com

  echo
  echo "## Generate the user msp"
  echo
   
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca.petani.example.com -M ${PWD}/../crypto-config/peerOrganizations/petani.example.com/users/User1@petani.example.com/msp --tls.certfiles ${PWD}/fabric-ca/petani/tls-cert.pem
   

  mkdir -p ../crypto-config/peerOrganizations/petani.example.com/users/Admin@petani.example.com

  echo
  echo "## Generate the org admin msp"
  echo
   
  fabric-ca-client enroll -u https://petaniadmin:petaniadminpw@localhost:8054 --caname ca.petani.example.com -M ${PWD}/../crypto-config/peerOrganizations/petani.example.com/users/Admin@petani.example.com/msp --tls.certfiles ${PWD}/fabric-ca/petani/tls-cert.pem
   

  cp ${PWD}/../crypto-config/peerOrganizations/petani.example.com/msp/config.yaml ${PWD}/../crypto-config/peerOrganizations/petani.example.com/users/Admin@petani.example.com/msp/config.yaml

}

# createCertificateForPetani

createCertificatesForPengumpul() {
  echo
  echo "Enroll the CA admin"
  echo
  mkdir -p /../crypto-config/peerOrganizations/pengumpul.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/../crypto-config/peerOrganizations/pengumpul.example.com/

   
  fabric-ca-client enroll -u https://admin:adminpw@localhost:10054 --caname ca.pengumpul.example.com --tls.certfiles ${PWD}/fabric-ca/pengumpul/tls-cert.pem
   

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-pengumpul-example-com.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-pengumpul-example-com.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-pengumpul-example-com.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-pengumpul-example-com.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/../crypto-config/peerOrganizations/pengumpul.example.com/msp/config.yaml

  echo
  echo "Register peer0"
  echo
   
  fabric-ca-client register --caname ca.pengumpul.example.com --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/fabric-ca/pengumpul/tls-cert.pem
   

  echo
  echo "Register user"
  echo
   
  fabric-ca-client register --caname ca.pengumpul.example.com --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/fabric-ca/pengumpul/tls-cert.pem
   

  echo
  echo "Register the org admin"
  echo
   
  fabric-ca-client register --caname ca.pengumpul.example.com --id.name pengumpuladmin --id.secret pengumpuladminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/pengumpul/tls-cert.pem
   

  mkdir -p ../crypto-config/peerOrganizations/pengumpul.example.com/peers
  mkdir -p ../crypto-config/peerOrganizations/pengumpul.example.com/peers/peer0.pengumpul.example.com

  # --------------------------------------------------------------
  # Peer 0
  echo
  echo "## Generate the peer0 msp"
  echo
   
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:10054 --caname ca.pengumpul.example.com -M ${PWD}/../crypto-config/peerOrganizations/pengumpul.example.com/peers/peer0.pengumpul.example.com/msp --csr.hosts peer0.pengumpul.example.com --tls.certfiles ${PWD}/fabric-ca/pengumpul/tls-cert.pem
   

  cp ${PWD}/../crypto-config/peerOrganizations/pengumpul.example.com/msp/config.yaml ${PWD}/../crypto-config/peerOrganizations/pengumpul.example.com/peers/peer0.pengumpul.example.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
   
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:10054 --caname ca.pengumpul.example.com -M ${PWD}/../crypto-config/peerOrganizations/pengumpul.example.com/peers/peer0.pengumpul.example.com/tls --enrollment.profile tls --csr.hosts peer0.pengumpul.example.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/pengumpul/tls-cert.pem
   

  cp ${PWD}/../crypto-config/peerOrganizations/pengumpul.example.com/peers/peer0.pengumpul.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/pengumpul.example.com/peers/peer0.pengumpul.example.com/tls/ca.crt
  cp ${PWD}/../crypto-config/peerOrganizations/pengumpul.example.com/peers/peer0.pengumpul.example.com/tls/signcerts/* ${PWD}/../crypto-config/peerOrganizations/pengumpul.example.com/peers/peer0.pengumpul.example.com/tls/server.crt
  cp ${PWD}/../crypto-config/peerOrganizations/pengumpul.example.com/peers/peer0.pengumpul.example.com/tls/keystore/* ${PWD}/../crypto-config/peerOrganizations/pengumpul.example.com/peers/peer0.pengumpul.example.com/tls/server.key

  mkdir ${PWD}/../crypto-config/peerOrganizations/pengumpul.example.com/msp/tlscacerts
  cp ${PWD}/../crypto-config/peerOrganizations/pengumpul.example.com/peers/peer0.pengumpul.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/pengumpul.example.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/../crypto-config/peerOrganizations/pengumpul.example.com/tlsca
  cp ${PWD}/../crypto-config/peerOrganizations/pengumpul.example.com/peers/peer0.pengumpul.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/pengumpul.example.com/tlsca/tlsca.pengumpul.example.com-cert.pem

  mkdir ${PWD}/../crypto-config/peerOrganizations/pengumpul.example.com/ca
  cp ${PWD}/../crypto-config/peerOrganizations/pengumpul.example.com/peers/peer0.pengumpul.example.com/msp/cacerts/* ${PWD}/../crypto-config/peerOrganizations/pengumpul.example.com/ca/ca.pengumpul.example.com-cert.pem

  # --------------------------------------------------------------------------------

  mkdir -p ../crypto-config/peerOrganizations/pengumpul.example.com/users
  mkdir -p ../crypto-config/peerOrganizations/pengumpul.example.com/users/User1@pengumpul.example.com

  echo
  echo "## Generate the user msp"
  echo
   
  fabric-ca-client enroll -u https://user1:user1pw@localhost:10054 --caname ca.pengumpul.example.com -M ${PWD}/../crypto-config/peerOrganizations/pengumpul.example.com/users/User1@pengumpul.example.com/msp --tls.certfiles ${PWD}/fabric-ca/pengumpul/tls-cert.pem
   

  mkdir -p ../crypto-config/peerOrganizations/pengumpul.example.com/users/Admin@pengumpul.example.com

  echo
  echo "## Generate the org admin msp"
  echo
   
  fabric-ca-client enroll -u https://pengumpuladmin:pengumpuladminpw@localhost:10054 --caname ca.pengumpul.example.com -M ${PWD}/../crypto-config/peerOrganizations/pengumpul.example.com/users/Admin@pengumpul.example.com/msp --tls.certfiles ${PWD}/fabric-ca/pengumpul/tls-cert.pem
   

  cp ${PWD}/../crypto-config/peerOrganizations/pengumpul.example.com/msp/config.yaml ${PWD}/../crypto-config/peerOrganizations/pengumpul.example.com/users/Admin@pengumpul.example.com/msp/config.yaml

}

createCertificatesForPedagang() {
  echo
  echo "Enroll the CA admin"
  echo
  mkdir -p /../crypto-config/peerOrganizations/pedagang.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/../crypto-config/peerOrganizations/pedagang.example.com/

   
  fabric-ca-client enroll -u https://admin:adminpw@localhost:11054 --caname ca.pedagang.example.com --tls.certfiles ${PWD}/fabric-ca/pedagang/tls-cert.pem
   

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-pedagang-example-com.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-pedagang-example-com.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-pedagang-example-com.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-pedagang-example-com.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/../crypto-config/peerOrganizations/pedagang.example.com/msp/config.yaml

  echo
  echo "Register peer0"
  echo
   
  fabric-ca-client register --caname ca.pedagang.example.com --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/fabric-ca/pedagang/tls-cert.pem
   

  echo
  echo "Register user"
  echo
   
  fabric-ca-client register --caname ca.pedagang.example.com --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/fabric-ca/pedagang/tls-cert.pem
   

  echo
  echo "Register the org admin"
  echo
   
  fabric-ca-client register --caname ca.pedagang.example.com --id.name pedagangadmin --id.secret pedagangadminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/pedagang/tls-cert.pem
   

  mkdir -p ../crypto-config/peerOrganizations/pedagang.example.com/peers
  mkdir -p ../crypto-config/peerOrganizations/pedagang.example.com/peers/peer0.pedagang.example.com

  # --------------------------------------------------------------
  # Peer 0
  echo
  echo "## Generate the peer0 msp"
  echo
   
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:11054 --caname ca.pedagang.example.com -M ${PWD}/../crypto-config/peerOrganizations/pedagang.example.com/peers/peer0.pedagang.example.com/msp --csr.hosts peer0.pedagang.example.com --tls.certfiles ${PWD}/fabric-ca/pedagang/tls-cert.pem
   

  cp ${PWD}/../crypto-config/peerOrganizations/pedagang.example.com/msp/config.yaml ${PWD}/../crypto-config/peerOrganizations/pedagang.example.com/peers/peer0.pedagang.example.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
   
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:11054 --caname ca.pedagang.example.com -M ${PWD}/../crypto-config/peerOrganizations/pedagang.example.com/peers/peer0.pedagang.example.com/tls --enrollment.profile tls --csr.hosts peer0.pedagang.example.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/pedagang/tls-cert.pem
   

  cp ${PWD}/../crypto-config/peerOrganizations/pedagang.example.com/peers/peer0.pedagang.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/pedagang.example.com/peers/peer0.pedagang.example.com/tls/ca.crt
  cp ${PWD}/../crypto-config/peerOrganizations/pedagang.example.com/peers/peer0.pedagang.example.com/tls/signcerts/* ${PWD}/../crypto-config/peerOrganizations/pedagang.example.com/peers/peer0.pedagang.example.com/tls/server.crt
  cp ${PWD}/../crypto-config/peerOrganizations/pedagang.example.com/peers/peer0.pedagang.example.com/tls/keystore/* ${PWD}/../crypto-config/peerOrganizations/pedagang.example.com/peers/peer0.pedagang.example.com/tls/server.key

  mkdir ${PWD}/../crypto-config/peerOrganizations/pedagang.example.com/msp/tlscacerts
  cp ${PWD}/../crypto-config/peerOrganizations/pedagang.example.com/peers/peer0.pedagang.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/pedagang.example.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/../crypto-config/peerOrganizations/pedagang.example.com/tlsca
  cp ${PWD}/../crypto-config/peerOrganizations/pedagang.example.com/peers/peer0.pedagang.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/pedagang.example.com/tlsca/tlsca.pedagang.example.com-cert.pem

  mkdir ${PWD}/../crypto-config/peerOrganizations/pedagang.example.com/ca
  cp ${PWD}/../crypto-config/peerOrganizations/pedagang.example.com/peers/peer0.pedagang.example.com/msp/cacerts/* ${PWD}/../crypto-config/peerOrganizations/pedagang.example.com/ca/ca.pedagang.example.com-cert.pem

  # --------------------------------------------------------------------------------

  mkdir -p ../crypto-config/peerOrganizations/pedagang.example.com/users
  mkdir -p ../crypto-config/peerOrganizations/pedagang.example.com/users/User1@pedagang.example.com

  echo
  echo "## Generate the user msp"
  echo
   
  fabric-ca-client enroll -u https://user1:user1pw@localhost:11054 --caname ca.pedagang.example.com -M ${PWD}/../crypto-config/peerOrganizations/pedagang.example.com/users/User1@pedagang.example.com/msp --tls.certfiles ${PWD}/fabric-ca/pedagang/tls-cert.pem
   

  mkdir -p ../crypto-config/peerOrganizations/pedagang.example.com/users/Admin@pedagang.example.com

  echo
  echo "## Generate the org admin msp"
  echo
   
  fabric-ca-client enroll -u https://pedagangadmin:pedagangadminpw@localhost:11054 --caname ca.pedagang.example.com -M ${PWD}/../crypto-config/peerOrganizations/pedagang.example.com/users/Admin@pedagang.example.com/msp --tls.certfiles ${PWD}/fabric-ca/pedagang/tls-cert.pem
   

  cp ${PWD}/../crypto-config/peerOrganizations/pedagang.example.com/msp/config.yaml ${PWD}/../crypto-config/peerOrganizations/pedagang.example.com/users/Admin@pedagang.example.com/msp/config.yaml

}


createCretificatesForOrderer() {
  echo
  echo "Enroll the CA admin"
  echo
  mkdir -p ../crypto-config/ordererOrganizations/example.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/../crypto-config/ordererOrganizations/example.com

   
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-orderer --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/../crypto-config/ordererOrganizations/example.com/msp/config.yaml

  echo
  echo "Register orderer"
  echo
   
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  echo
  echo "Register orderer2"
  echo
   
  fabric-ca-client register --caname ca-orderer --id.name orderer2 --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  echo
  echo "Register orderer3"
  echo
   
  fabric-ca-client register --caname ca-orderer --id.name orderer3 --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  echo
  echo "Register the orderer admin"
  echo
   
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  mkdir -p ../crypto-config/ordererOrganizations/example.com/orderers
  # mkdir -p ../crypto-config/ordererOrganizations/example.com/orderers/example.com

  # ---------------------------------------------------------------------------
  #  Orderer

  mkdir -p ../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com

  echo
  echo "## Generate the orderer msp"
  echo
   
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/../crypto-config/ordererOrganizations/example.com/msp/config.yaml ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/config.yaml

  echo
  echo "## Generate the orderer-tls certificates"
  echo
   
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls --enrollment.profile tls --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt
  cp ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/signcerts/* ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt
  cp ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/keystore/* ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key

  mkdir ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts
  cp ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  mkdir ${PWD}/../crypto-config/ordererOrganizations/example.com/msp/tlscacerts
  cp ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  # -----------------------------------------------------------------------
  #  Orderer 2

  mkdir -p ../crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com

  echo
  echo "## Generate the orderer msp"
  echo
   
  fabric-ca-client enroll -u https://orderer2:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/msp --csr.hosts orderer2.example.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/../crypto-config/ordererOrganizations/example.com/msp/config.yaml ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/msp/config.yaml

  echo
  echo "## Generate the orderer-tls certificates"
  echo
   
  fabric-ca-client enroll -u https://orderer2:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls --enrollment.profile tls --csr.hosts orderer2.example.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/ca.crt
  cp ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/signcerts/* ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/server.crt
  cp ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/keystore/* ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/server.key

  mkdir ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/msp/tlscacerts
  cp ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  # mkdir ${PWD}/../crypto-config/ordererOrganizations/example.com/msp/tlscacerts
  # cp ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  # ---------------------------------------------------------------------------
  #  Orderer 3
  mkdir -p ../crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com

  echo
  echo "## Generate the orderer msp"
  echo
   
  fabric-ca-client enroll -u https://orderer3:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/msp --csr.hosts orderer3.example.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/../crypto-config/ordererOrganizations/example.com/msp/config.yaml ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/msp/config.yaml

  echo
  echo "## Generate the orderer-tls certificates"
  echo
   
  fabric-ca-client enroll -u https://orderer3:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls --enrollment.profile tls --csr.hosts orderer3.example.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/ca.crt
  cp ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/signcerts/* ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/server.crt
  cp ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/keystore/* ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/server.key

  mkdir ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/msp/tlscacerts
  cp ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  # mkdir ${PWD}/../crypto-config/ordererOrganizations/example.com/msp/tlscacerts
  # cp ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  # ---------------------------------------------------------------------------

  mkdir -p ../crypto-config/ordererOrganizations/example.com/users
  mkdir -p ../crypto-config/ordererOrganizations/example.com/users/Admin@example.com

  echo
  echo "## Generate the admin msp"
  echo
   
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9054 --caname ca-orderer -M ${PWD}/../crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/../crypto-config/ordererOrganizations/example.com/msp/config.yaml ${PWD}/../crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp/config.yaml

}

# createCretificateForOrderer

sudo rm -rf ../crypto-config/*
# sudo rm -rf fabric-ca/*
createcertificatesForPenangkar
createCertificatesForPetani
createCertificatesForPengumpul
createCertificatesForPedagang

createCretificatesForOrderer

