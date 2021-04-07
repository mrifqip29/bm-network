"use strict";

require("dotenv").config();

const log4js = require("log4js");
const logger = log4js.getLogger("BasicNetwork");
const bodyParser = require("body-parser");
const http = require("http");
const util = require("util");
const express = require("express");
const app = express();
const expressJWT = require("express-jwt");
const jwt = require("jsonwebtoken");
const bearerToken = require("express-bearer-token");
const cors = require("cors");
const constants = require("./config/constants.json");
const mongoose = require("mongoose");

const RouteUser = require("./routes/user");
const RouteSC = require("./routes/sc");

const host = process.env.HOST || constants.host;
const port = process.env.PORT || constants.port;

const helper = require("./app/helper");
const invoke = require("./app/invoke");
const qscc = require("./app/qscc");
const query = require("./app/query");

mongoose
  .connect(process.env.MONGO_URL, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
    useCreateIndex: true,
  })
  .then((res) => {
    console.log("db connected");
  })
  .catch((e) => {
    console.log("error when connecting to db", e);
  });

app.options("*", cors());
app.use(cors());
app.use(bodyParser.json());
// app.use(
//   bodyParser.urlencoded({
//     extended: false,
//   })
// );

app.use((req, res, next) => {
  res.header("Access-Control-Allow-Origin", "*");
  next();
});

// set secret variable
app.set("secret", process.env.JWT_SECRET);

app.get("/", (req, res) => {
  res.send("Backend Sistem CRUD Blockchain");
});

// app.use(
//   expressJWT({
//     secret: process.env.JWT_SECRET,
//   }).unless({
//     path: ["/user", "/login", "/register", "/query"],
//   })
// );

//app.use(bearerToken());



logger.level = "debug";

// app.use((req, res, next) => {
//   logger.debug("New req for %s", req.originalUrl);
//   if (
//     req.originalUrl.indexOf("/user") >= 0 ||
//     req.originalUrl.indexOf("/login") >= 0 ||
//     req.originalUrl.indexOf("/register") >= 0 ||
//     req.originalUrl.indexOf("/query") >= 0
//   ) {
//     return next();
//   }
// });

// var server = http.createServer(app).listen(port, function () {
//   console.log(`Server started on ${port}`);
// });

// logger.info("****************** SERVER STARTED ************************");
// logger.info("***************  http://%s:%s  ******************", host, port);
// server.timeout = 240000;

app.listen(port, (req, res) => {
  console.log(`server run at port ${process.env.PORT}`);
});


function getErrorMessage(field) {
  var response = {
    success: false,
    message: field + " field is missing or Invalid in the request",
  };
  return response;
}

app.use('/', RouteUser);
app.use('/sc', RouteSC);

// app.get("/sc/channels/:channelName/chaincodes/:chaincodeName", async function (req, res) {
//   console.log(req.params)
//   console.log(req.query.args)
//   try {
//     logger.debug(
//       "==================== QUERY BY CHAINCODE =================="
//     );

//     var channelName = req.params.channelName;
//     var chaincodeName = req.params.chaincodeName;
//     console.log(`chaincode name is :${chaincodeName}`);
//     let args = req.query.args;
//     let fcn = req.query.fcn;
//     let peer = req.query.peer;

//     logger.debug("channelName : " + channelName);
//     logger.debug("chaincodeName : " + chaincodeName);
//     logger.debug("fcn : " + fcn);
//     logger.debug("args : " + args);

//     if (!chaincodeName) {
//       res.json(getErrorMessage("'chaincodeName'"));
//       return;
//     }
//     if (!channelName) {
//       res.json(getErrorMessage("'channelName'"));
//       return;
//     }
//     if (!fcn) {
//       res.json(getErrorMessage("'fcn'"));
//       return;
//     }
//     if (!args) {
//       res.json(getErrorMessage("'args'"));
//       return;
//     }
//     console.log("args ==========", args);
//     args = args.replace(/'/g, '"');
//     logger.debug(`type of ${typeof args}`)
//     args = JSON.parse(args);
//     logger.debug(`type of ${typeof args}`)
//     logger.debug(args);

//     console.log(req)

//     let message = await query.query(
//       channelName,
//       chaincodeName,
//       args,
//       fcn,
//       req.username,
//       req.orgname
//     );

//     logger.debug(message);

//     const response_payload = {
//       result: message,
//       error: null,
//       errorData: null,
//     };

//     res.send(response_payload);
//   } catch (error) {
//     const response_payload = {
//       result: null,
//       error: error.name,
//       errorData: error.message,
//     };
//     res.send(response_payload);
//   }
// });

// // Invoke transaction on chaincode on target peers
// app.post(
//   "/invoke/:channelName/:chaincodeName",
//   async function (req, res) {
//     try {
//       logger.debug(
//         "==================== INVOKE ON CHAINCODE =================="
//       );
//       var peers = req.body.peers;
//       var chaincodeName = req.params.chaincodeName;
//       var channelName = req.params.channelName;
//       var fcn = req.body.fcn;
//       var args = req.body.args;
//       var transient = req.body.transient;
//       console.log(`Transient data is ;${transient}`);
//       logger.debug("channelName  : " + channelName);
//       logger.debug("chaincodeName : " + chaincodeName);
//       logger.debug("fcn  : " + fcn);
//       logger.debug("args  : " + args);
//       if (!chaincodeName) {
//         res.json(getErrorMessage("'chaincodeName'"));
//         return;
//       }
//       if (!channelName) {
//         res.json(getErrorMessage("'channelName'"));
//         return;
//       }
//       if (!fcn) {
//         res.json(getErrorMessage("'fcn'"));
//         return;
//       }
//       if (!args) {
//         res.json(getErrorMessage("'args'"));
//         return;
//       }

//       let message = await invoke.invokeTransaction(
//         channelName,
//         chaincodeName,
//         fcn,
//         args,
//         req.username,
//         req.orgname,
//         transient
//       );
//       console.log(`message result is : ${message}`);

//       console.log(`username pengirim : ${args.usernamePengirim}`)

//       const response_payload = {
//         result: message,
//         error: null,
//         errorData: null,
//       };
//       res.send(response_payload);
//     } catch (error) {
//       const response_payload = {
//         result: null,
//         error: error.name,
//         errorData: error.message,
//       };
//       res.send(response_payload);
//     }
//   }
// );

// app.get(
//   "/sc/channels/:channelName/chaincodes/:chaincodeName",
//   async function (req, res) {
//     try {
//       logger.debug(
//         "==================== QUERY BY CHAINCODE =================="
//       );

//       var channelName = req.params.channelName;
//       var chaincodeName = req.params.chaincodeName;
//       console.log(`chaincode name is :${chaincodeName}`);
//       let args = req.query.args;
//       let fcn = req.query.fcn;
//       let peer = req.query.peer;

//       logger.debug("channelName : " + channelName);
//       logger.debug("chaincodeName : " + chaincodeName);
//       logger.debug("fcn : " + fcn);
//       logger.debug("args : " + args);

//       if (!chaincodeName) {
//         res.json(getErrorMessage("'chaincodeName'"));
//         return;
//       }
//       if (!channelName) {
//         res.json(getErrorMessage("'channelName'"));
//         return;
//       }
//       if (!fcn) {
//         res.json(getErrorMessage("'fcn'"));
//         return;
//       }
//       if (!args) {
//         res.json(getErrorMessage("'args'"));
//         return;
//       }
//       console.log("args==========", args);
//       args = args.replace(/'/g, '"');
//       args = JSON.parse(args);
//       logger.debug(args);

//       let message = await query.query(
//         channelName,
//         chaincodeName,
//         args,
//         fcn,
//         req.username,
//         req.orgname
//       );

//       logger.debug(message);

//       const response_payload = {
//         result: message,
//         error: null,
//         errorData: null,
//       };

//       res.send(response_payload);
//     } catch (error) {
//       const response_payload = {
//         result: null,
//         error: error.name,
//         errorData: error.message,
//       };
//       res.send(response_payload);
//     }
//   }
// );

app.get(
  "/qscc/channels/:channelName/chaincodes/:chaincodeName",
  async function (req, res) {
    try {
      logger.debug(
        "==================== QUERY BY CHAINCODE =================="
      );

      var channelName = req.params.channelName;
      var chaincodeName = req.params.chaincodeName;
      console.log(`chaincode name is :${chaincodeName}`);
      let args = req.query.args;
      let fcn = req.query.fcn;
      // let peer = req.query.peer;

      logger.debug("channelName : " + channelName);
      logger.debug("chaincodeName : " + chaincodeName);
      logger.debug("fcn : " + fcn);
      logger.debug("args : " + args);

      if (!chaincodeName) {
        res.json(getErrorMessage("'chaincodeName'"));
        return;
      }
      if (!channelName) {
        res.json(getErrorMessage("'channelName'"));
        return;
      }
      if (!fcn) {
        res.json(getErrorMessage("'fcn'"));
        return;
      }
      if (!args) {
        res.json(getErrorMessage("'args'"));
        return;
      }
      console.log("args==========", args);
      args = args.replace(/'/g, '"');
      args = JSON.parse(args);
      logger.debug(args);

      let response_payload = await qscc.qscc(
        channelName,
        chaincodeName,
        args,
        fcn,
        req.username,
        req.orgname
      );

      // const response_payload = {
      //     result: message,
      //     error: null,
      //     errorData: null
      // }

      res.send(response_payload);
    } catch (error) {
      const response_payload = {
        result: null,
        error: error.name,
        errorData: error.message,
      };
      res.send(response_payload);
    }
  }
);
