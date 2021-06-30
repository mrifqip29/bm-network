"use strict";

require("dotenv").config();

const log4js = require("log4js");
const logger = log4js.getLogger("BasicNetwork");
const bodyParser = require("body-parser");
const express = require("express");
const app = express();
const cors = require("cors");
const constants = require("./config/constants.json");
const mongoose = require("mongoose");
const swaggerUI = require("swagger-ui-express")
const swaggerJsDoc = require("swagger-jsdoc")
 

const RouteUser = require("./routes/user");
const RouteSC = require("./routes/sc");

const port = process.env.PORT || constants.port;

const options = {
  definition: {
    openapi: "3.0.0",
    info: {
      title: "Bawang Merah BC-Network",
      version: "1.0.0",
      description: "API Library for Bawang Merah BC-Network"
    },
    license: {
      name: "MIT",
      url: "https://spdx.org/licenses/MIT.html",
    },
    contact: {
      name: "SEIS IPB University",
      url: "https://cs.ipb.ac.id",
      // email: "cs@email.com",
    },
    servers: [
      {
        url: "https://bm-network.rfq.my.id"
      }
    ]
  },
  apis: ["./routes/*.js"]
}

const specs = swaggerJsDoc(options)

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

app.use((req, res, next) => {
  res.header("Access-Control-Allow-Origin", "*");
  next();
});

app.use("/api-docs", swaggerUI.serve, swaggerUI.setup(specs))

// set secret variable
app.set("secret", process.env.JWT_SECRET);

app.get("/", (req, res) => {
  res.send("Backend Sistem CRUD Blockchain");
});

logger.level = "debug";

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