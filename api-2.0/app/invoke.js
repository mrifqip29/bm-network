const {
  Gateway,
  Wallets,
  TxEventHandler,
  GatewayOptions,
  DefaultEventHandlerStrategies,
  TxEventHandlerFactory,
} = require("fabric-network");
const fs = require("fs");
const EventStrategies = require("fabric-network/lib/impl/event/defaulteventhandlerstrategies");
const path = require("path");
const log4js = require("log4js");
const logger = log4js.getLogger("BasicNetwork");
const util = require("util");

const helper = require("./helper");
const { blockListener, contractListener } = require("./Listeners");

const invokeTransaction = async (
  channelName,
  chaincodeName,
  fcn,
  args,
  username,
  orgName,
  transientData,
  peers
) => {
  try {
    const ccp = await helper.getCCP(orgName);

    const walletPath = await helper.getWalletPath(orgName);
    const wallet = await Wallets.newFileSystemWallet(walletPath);

    let identity = await wallet.get(username);
    if (!identity) {
      await helper.getRegisteredUser(username, orgName, true);
      identity = await wallet.get(username);
      return;
    }

    //if (orgName != "")

    const connectOptions = {
      wallet,
      identity: username,
      discovery: { 
        enabled: true, 
        asLocalhost: false 
      },
      eventHandlerOptions: EventStrategies.NONE,
    };

    const gateway = new Gateway();
    await gateway.connect(ccp, connectOptions);

    const network = await gateway.getNetwork(channelName);
    const contract = network.getContract(chaincodeName);

    // await contract.addContractListener(contractListener);
    // await network.addBlockListener(blockListener);

    // Multiple smartcontract in one chaincode
    let result;
    let message;
    let transaction;

    // Helper function to create transaction - let SDK handle endorsement automatically
    const createTransaction = (txName) => {
      return contract.createTransaction(txName);
    };

    switch (fcn) {
      case "CreateBenih":
        transaction = createTransaction("BawangContract:" + fcn);
        result = await transaction.submit(args[0]);
        result = { txid: result.toString() };
        break;
      case "PlantBenih":
        transaction = createTransaction("BawangContract:" + fcn);
        result = await transaction.submit(args[0], args[1]);
        result = { txid: result.toString() };
        break;
      case "HarvestBawang":
        transaction = createTransaction("BawangContract:" + fcn);
        result = await transaction.submit(args[0], args[1]);
        result = { txid: result.toString() };
        break;
      case "CreateUser":
        transaction = createTransaction("UserContract:" + fcn);
        result = await transaction.submit(args[0]);
        result = { txid: result.toString() };
        break;
      case "CreateTrxBawangByPenangkar":
        transaction = createTransaction("BawangContract:" + fcn);
        result = await transaction.submit(args[0], args[1]);
        result = { txid: result.toString() };
        break;
      case "UpdateBawangTrxByPetani":
        transaction = createTransaction("BawangContract:" + fcn);
        result = await transaction.submit(args[0], args[1]);
        result = { txid: result.toString() };
        break;
      case "UpdateBawangTrxByPengumpul":
        transaction = createTransaction("BawangContract:" + fcn);
        result = await transaction.submit(args[0], args[1]);
        result = { txid: result.toString() };
        break;
      case "AddBenihKuantitasByID":
        transaction = createTransaction("BawangContract:" + fcn);
        result = await transaction.submit(args[0], args[1]);
	      var data = JSON.parse(result.toString())
        result = { bawang: data };
        break;
      case "AddBawangKuantitasByID":
        transaction = createTransaction("BawangContract:" + fcn);
        result = await transaction.submit(args[0], args[1]);
	      var data = JSON.parse(result.toString())
        result = { bawang: data };
        break;
      case "ConfirmTrxByID":
        transaction = createTransaction("BawangContract:" + fcn);
        result = await transaction.submit(args[0]);
        result = { txid: result.toString() };
        break;
      case "RejectTrxByID":
        transaction = createTransaction("BawangContract:" + fcn);
        result = await transaction.submit(args[0], args[1], args[2], args[3]);
        result = { txid: result.toString() };
        break;

      default:
        break;
    }

    // let result
    // let message;
    // if (fcn === "createCar" || fcn === "createPrivateCarImplicitForOrg1"
    //     || fcn == "createPrivateCarImplicitForOrg2") {
    //     result = await contract.submitTransaction(fcn, args[0], args[1], args[2], args[3], args[4]);
    //     message = `Successfully added the car asset with key ${args[0]}`

    // } else if (fcn === "changeCarOwner") {
    //     result = await contract.submitTransaction(fcn, args[0], args[1]);
    //     message = `Successfully changed car owner with key ${args[0]}`
    // } else if (fcn == "createPrivateCar" || fcn =="updatePrivateData") {
    //     console.log(`Transient data is : ${transientData}`)
    //     let carData = JSON.parse(transientData)
    //     console.log(`car data is : ${JSON.stringify(carData)}`)
    //     let key = Object.keys(carData)[0]
    //     const transientDataBuffer = {}
    //     transientDataBuffer[key] = Buffer.from(JSON.stringify(carData.car))
    //     result = await contract.createTransaction(fcn)
    //         .setTransient(transientDataBuffer)
    //         .submit()
    //     message = `Successfully submitted transient data`
    // }
    // else {
    //     return `Invocation require either createCar or changeCarOwner as function but got ${fcn}`
    // }

    await gateway.disconnect();

    // result = JSON.parse(result.toString());

    let response = {
      message: message,
      result,
    };

    return response;
  } catch (error) {
    let errorMessage = error.message || 'Unknown error occurred';
    
    if (error.endorsements) {
      const endorsementErrors = error.endorsements.map((endorsement, index) => {
        const peerName = (peers && peers[index]) || endorsement.peer || 'unknown peer';
        return `peer=${peerName}, status=${endorsement.status || 'unknown'}, message=${endorsement.message || 'no message'}`;
      }).join('\n    ');
      errorMessage = `No valid responses from any peers. Errors:\n    ${endorsementErrors}`;
    } else if (error.responses) {
      const responseErrors = error.responses.map((response, index) => {
        const peerName = (peers && peers[index]) || response.peer || (response.connection && response.connection.name) || 'unknown peer';
        return `peer=${peerName}, status=${response.status || 'unknown'}, message=${response.message || error.message}`;
      }).join('\n    ');
      errorMessage = `No valid responses from any peers. Errors:\n    ${responseErrors}`;
    } else if (error.errors) {
      const errors = error.errors.map((err, index) => {
        const peerName = (peers && peers[index]) || err.peer || 'unknown peer';
        return `peer=${peerName}, message=${err.message || err.toString()}`;
      }).join('\n    ');
      errorMessage = `Transaction failed. Errors:\n    ${errors}`;
    }
    
    return errorMessage;
  }
};

exports.invokeTransaction = invokeTransaction;
