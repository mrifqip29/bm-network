const express = require("express");
const router = express.Router({mergeParams: true});
const { 
    Query,
    Invoke,
    AddUser
} = require("../controllers/sc.controller");
const { Auth } = require("../middleware/middleware");

//console.log('Test param: ' + req.params.channelName + ' ' + req.params.chaincodeName)

/**
 * @swagger
 * components:
 *  schemas:
 *      Chaincode:
 *          properties:
 *              fcn:
 *                   type: string
 *                   description: Chaincode function that you wanted to run, functions refers to https://github.com/mrifqip29/bm-network/blob/main/artifacts/src/github.com/bawangmerah/go/bawangMerahCC.go
 *              peers:
 *                  type: string
 *                  description: Peer that you wanted to run chaincode on
 *              chaincodeName:
 *                  type: string
 *                  description: The name of your selected chaincode
 *              channelName:
 *                  type: string
 *                  description: The name of your selected channel
 *              args:
 *                  type: string
 *                  description: The arguments that used to invoke the chaincode
 *          required:
 *              - fcn
 *              - peers
 *              - chaincodeName
 *              - channelName
 *              - args
 *          example:
 *              fcn: CreateBenih
 *              peers: [peer0.penangkar.example.com,
 *                  peer0.petani.example.com,
 *                  peer0.pengumpul.example.com,
 *                  peer0.pedagang.example.com]
 *              chaincodeName: bawangmerah_cc 
 *              channelName: mychannel    
 *              args:[{"umurBenih":"2 bulan", "umurPanen":"2 hari", "varietas":"Bima Brebes", "lamaPenyimpanan":"1 minggu", "kuantitasBenihKg": 4.2}"]
 */

/**
 * @swagger
 * tags:
 *  name: Blockchain Network
 *  description: The invoke/query to smart contract API
 */

/**
 * @swagger
 * /channels/{channelName}/chaincodes/{chaincodeName}:
 *  get:
 *      summary: Send query to the chaincode on blockhain network
 *      tags: [Blockchain Network]
 *      parameters:
 *          - in: path
 *            name: channelName
 *            schema:
 *              type: string
 *            required: true
 *            description: The channel name
 *          - in: path
 *            name: chaincodeName
 *            schema:
 *              type: string
 *            required: true
 *            description: The chaincode name
 *          - in: query
 *            name: fcn
 *            schema:
 *              type: string
 *            required: true
 *            description: Chaincode function that will be used
 *          - in: query
 *            name: peer
 *            schema:
 *              type: string
 *            required: true
 *            description: Peer that will be used     
 *          - in: query
 *            name: args
 *            schema:
 *              type: string
 *            required: true
 *            description: Arguments that need to be queried      
 *      responses:
 *          200:
 *              description: Query chaincode success
 *          500: 
 *              description: Error in chaincode
 *          404:
 *              description: Data not found
  *  post:
 *      summary: Invoke to the chaincode on blockhain network
 *      tags: [Blockchain Network]
 *      requestBody:
 *          required: true
 *          content:
 *              application/json:
 *                  schema:
 *                      type: object
 *                      $ref: '#/components/schemas/Chaincode'  
 *      parameters:
 *          - in: path
 *            name: channelName
 *            schema:
 *              type: string
 *            required: true
 *            description: The channel name
 *          - in: path
 *            name: chaincodeName
 *            schema:
 *              type: string
 *            required: true
 *            description: The chaincode name
 *      responses:
 *          200:
 *              description: Invoke chaincode success
 *          500: 
 *              description: Error in chaincode
 */

router.get("/channels/:channelName/chaincodes/:chaincodeName", Query);

router.post("/channels/:channelName/chaincodes/:chaincodeName", Auth, Invoke);

//router.post("/channels/:channelName/chaincodes/:chaincodeName/user", AddUser);

module.exports = router;