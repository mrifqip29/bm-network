const express = require("express");
const router = express.Router({mergeParams: true});
const { 
    Query,
    Invoke,
    AddUser
} = require("../controllers/sc.controller");
const { Auth } = require("../middleware/middleware");

//console.log('Test param: ' + req.params.channelName + ' ' + req.params.chaincodeName)

router.get("/channels/:channelName/chaincodes/:chaincodeName", Query);

router.post("/channels/:channelName/chaincodes/:chaincodeName", Auth, Invoke);

//router.post("/channels/:channelName/chaincodes/:chaincodeName/user", AddUser);

module.exports = router;