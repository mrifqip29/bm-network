"use strict";

var { Gateway, Wallets } = require("fabric-network");
const path = require("path");
const FabricCAServices = require("fabric-ca-client");
const fs = require("fs");

const util = require("util");

const getCCP = async (org) => {
  let ccpPath;
  if (org == "Penangkar") {
    ccpPath = path.resolve(
      __dirname,
      "..",
      "config",
      "connection-penangkar.json"
    );
  } else if (org == "Petani") {
    ccpPath = path.resolve(__dirname, "..", "config", "connection-petani.json");
  } else if (org == "Pengumpul") {
    ccpPath = path.resolve(
      __dirname,
      "..",
      "config",
      "connection-pengumpul.json"
    );
  } else if (org == "Pedagang") {
    ccpPath = path.resolve(
      __dirname,
      "..",
      "config",
      "connection-pedagang.json"
    );
  } else return null;
  const ccpJSON = fs.readFileSync(ccpPath, "utf8");
  const ccp = JSON.parse(ccpJSON);
  return ccp;
};

const getCaUrl = async (org, ccp) => {
  let caURL;
  if (org == "Penangkar") {
    caURL = ccp.certificateAuthorities["ca.penangkar.example.com"].url;
  } else if (org == "Petani") {
    caURL = ccp.certificateAuthorities["ca.petani.example.com"].url;
  } else if (org == "Pengumpul") {
    caURL = ccp.certificateAuthorities["ca.pengumpul.example.com"].url;
  } else if (org == "Pedagang") {
    caURL = ccp.certificateAuthorities["ca.pedagang.example.com"].url;
  } else return null;
  return caURL;
};

const getWalletPath = async (org) => {
  let walletPath;
  if (org == "Penangkar") {
    walletPath = path.join(process.cwd(), "penangkar-wallet");
  } else if (org == "Petani") {
    walletPath = path.join(process.cwd(), "petani-wallet");
  } else if (org == "Pengumpul") {
    walletPath = path.join(process.cwd(), "pengumpul-wallet");
  } else if (org == "Pedagang") {
    walletPath = path.join(process.cwd(), "pedagang-wallet");
  } else return null;
  return walletPath;
};

// TODO: make affiliation

const getAffiliation = async (org) => {
  if (org == "Penangkar") {
    return "org1.department1";
  } else if (org == "Petani") {
    return "org1.department1";
  } else if (org == "Pengumpul") {
    return "org1.department1";
  } else if (org == "Pedagang") {
    return "org1.department1";
  } else return null;
};

const getRegisteredUser = async (username, userOrg, isJson) => {
  let ccp = await getCCP(userOrg);

  console.log(`Got ccp :   ${ccp}`);

  const caURL = await getCaUrl(userOrg, ccp);

  console.log(`Got caURL :   ${caURL}`);

  const ca = new FabricCAServices(caURL);

  console.log(`Got ca :   ${ca}`);

  const walletPath = await getWalletPath(userOrg);

  console.log(`Got walletPath : ${walletPath}`);
  console.log(typeof walletPath);

  console.log(`Masuk await Wallets.newFileSystemWallet(walletPath);`);

  const wallet = await Wallets.newFileSystemWallet(walletPath);

  console.log(`Keluar await Wallets.newFileSystemWallet(walletPath);`);
  console.log(`Wallet path: ${walletPath}`);

  const userIdentity = await wallet.get(username);
  if (userIdentity) {
    console.log(
      `An identity for the user ${username} already exists in the wallet`
    );
    var response = {
      success: true,
      message: username + " enrolled Successfully",
    };
    return response;
  }

  // Check to see if we've already enrolled the admin user.
  let adminIdentity = await wallet.get("admin");
  if (!adminIdentity) {
    console.log(
      'An identity for the admin user "admin" does not exist in the wallet'
    );
    await enrollAdmin(userOrg, ccp);
    adminIdentity = await wallet.get("admin");
    console.log("Admin Enrolled Successfully");
  }

  // build a user object for authenticating with the CA
  const provider = wallet.getProviderRegistry().getProvider(adminIdentity.type);
  const adminUser = await provider.getUserContext(adminIdentity, "admin");
  let secret;
  try {
    // Register the user, enroll the user, and import the new identity into the wallet.
    secret = await ca.register(
      {
        affiliation: await getAffiliation(userOrg),
        enrollmentID: username,
        role: "client",
      },
      adminUser
    );
    // const secret = await ca.register({ affiliation: 'org1.department1', enrollmentID: username, role: 'client', attrs: [{ name: 'role', value: 'approver', ecert: true }] }, adminUser);
  } catch (error) {
    return error.message;
  }

  const enrollment = await ca.enroll({
    enrollmentID: username,
    enrollmentSecret: secret,
  });
  // const enrollment = await ca.enroll({ enrollmentID: username, enrollmentSecret: secret, attr_reqs: [{ name: 'role', optional: false }] });

  let x509Identity;
  if (userOrg == "Penangkar") {
    x509Identity = {
      credentials: {
        certificate: enrollment.certificate,
        privateKey: enrollment.key.toBytes(),
      },
      mspId: "PenangkarMSP",
      type: "X.509",
    };
  } else if (userOrg == "Petani") {
    x509Identity = {
      credentials: {
        certificate: enrollment.certificate,
        privateKey: enrollment.key.toBytes(),
      },
      mspId: "PetaniMSP",
      type: "X.509",
    };
  } else if (userOrg == "Pengumpul") {
    x509Identity = {
      credentials: {
        certificate: enrollment.certificate,
        privateKey: enrollment.key.toBytes(),
      },
      mspId: "PengumpulMSP",
      type: "X.509",
    };
  } else if (userOrg == "Pedagang") {
    x509Identity = {
      credentials: {
        certificate: enrollment.certificate,
        privateKey: enrollment.key.toBytes(),
      },
      mspId: "PedagangMSP",
      type: "X.509",
    };
  }

  await wallet.put(username, x509Identity);
  console.log(
    `Successfully registered and enrolled admin user ${username} and imported it into the wallet`
  );

  var response = {
    success: true,
    message: username + " enrolled Successfully",
  };
  return response;
};

const isUserRegistered = async (username, userOrg) => {
  const walletPath = await getWalletPath(userOrg);
  const wallet = await Wallets.newFileSystemWallet(walletPath);
  console.log(`Wallet path: ${walletPath}`);

  const userIdentity = await wallet.get(username);
  if (userIdentity) {
    console.log(`An identity for the user ${username} exists in the wallet`);
    return true;
  }
  return false;
};

const getCaInfo = async (org, ccp) => {
  let caInfo;
  if (org == "Penangkar") {
    caInfo = ccp.certificateAuthorities["ca.penangkar.example.com"];
  } else if (org == "Petani") {
    caInfo = ccp.certificateAuthorities["ca.petani.example.com"];
  } else if (org == "Pengumpul") {
    caInfo = ccp.certificateAuthorities["ca.pengumpul.example.com"];
  } else if (org == "Pedagang") {
    caInfo = ccp.certificateAuthorities["ca.pedagang.example.com"];
  } else return null;
  return caInfo;
};

const enrollAdmin = async (org, ccp) => {
  console.log("calling enroll Admin method");

  try {
    const caInfo = await getCaInfo(org, ccp); //ccp.certificateAuthorities['ca.org1.example.com'];
    const caTLSCACerts = caInfo.tlsCACerts.pem;
    const ca = new FabricCAServices(
      caInfo.url,
      { trustedRoots: caTLSCACerts, verify: false },
      caInfo.caName
    );

    // Create a new file system based wallet for managing identities.
    const walletPath = await getWalletPath(org); //path.join(process.cwd(), 'wallet');
    const wallet = await Wallets.newFileSystemWallet(walletPath);
    console.log(`Wallet path: ${walletPath}`);

    // Check to see if we've already enrolled the admin user.
    const identity = await wallet.get("admin");
    if (identity) {
      console.log(
        'An identity for the admin user "admin" already exists in the wallet'
      );
      return;
    }

    // Enroll the admin user, and import the new identity into the wallet.
    const enrollment = await ca.enroll({
      enrollmentID: "admin",
      enrollmentSecret: "adminpw",
    });
    let x509Identity;
    if (org == "Penangkar") {
      x509Identity = {
        credentials: {
          certificate: enrollment.certificate,
          privateKey: enrollment.key.toBytes(),
        },
        mspId: "PenangkarMSP",
        type: "X.509",
      };
    } else if (org == "Petani") {
      x509Identity = {
        credentials: {
          certificate: enrollment.certificate,
          privateKey: enrollment.key.toBytes(),
        },
        mspId: "PetaniMSP",
        type: "X.509",
      };
    } else if (org == "Pengumpul") {
      x509Identity = {
        credentials: {
          certificate: enrollment.certificate,
          privateKey: enrollment.key.toBytes(),
        },
        mspId: "PengumpulMSP",
        type: "X.509",
      };
    } else if (org == "Pedagang") {
      x509Identity = {
        credentials: {
          certificate: enrollment.certificate,
          privateKey: enrollment.key.toBytes(),
        },
        mspId: "PedagangMSP",
        type: "X.509",
      };
    }

    await wallet.put("admin", x509Identity);
    console.log(
      'Successfully enrolled admin user "admin" and imported it into the wallet'
    );
    return;
  } catch (error) {
    console.error(`Failed to enroll admin user "admin": ${error}`);
  }
};

const registerAndGerSecret = async (username, userOrg) => {
  let ccp = await getCCP(userOrg);

  const caURL = await getCaUrl(userOrg, ccp);
  const ca = new FabricCAServices(caURL);

  const walletPath = await getWalletPath(userOrg);
  const wallet = await Wallets.newFileSystemWallet(walletPath);
  console.log(`Wallet path: ${walletPath}`);

  const userIdentity = await wallet.get(username);
  if (userIdentity) {
    console.log(
      `An identity for the user ${username} already exists in the wallet`
    );
    var response = {
      success: true,
      message: username + " enrolled Successfully",
    };
    return response;
  }

  // Check to see if we've already enrolled the admin user.
  let adminIdentity = await wallet.get("admin");
  if (!adminIdentity) {
    console.log(
      'An identity for the admin user "admin" does not exist in the wallet'
    );
    await enrollAdmin(userOrg, ccp);
    adminIdentity = await wallet.get("admin");
    console.log("Admin Enrolled Successfully");
  }

  // build a user object for authenticating with the CA
  const provider = wallet.getProviderRegistry().getProvider(adminIdentity.type);
  const adminUser = await provider.getUserContext(adminIdentity, "admin");
  let secret;
  try {
    // Register the user, enroll the user, and import the new identity into the wallet.
    secret = await ca.register(
      {
        affiliation: await getAffiliation(userOrg),
        enrollmentID: username,
        role: "client",
      },
      adminUser
    );
    // const secret = await ca.register({ affiliation: 'org1.department1', enrollmentID: username, role: 'client', attrs: [{ name: 'role', value: 'approver', ecert: true }] }, adminUser);
  } catch (error) {
    return error.message;
  }

  var response = {
    success: true,
    message: username + " enrolled Successfully",
    secret: secret,
  };
  return response;
};

exports.getRegisteredUser = getRegisteredUser;

module.exports = {
  getCCP: getCCP,
  getWalletPath: getWalletPath,
  getRegisteredUser: getRegisteredUser,
  isUserRegistered: isUserRegistered,
  registerAndGerSecret: registerAndGerSecret,
};
