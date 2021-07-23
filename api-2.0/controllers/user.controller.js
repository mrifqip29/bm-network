require("dotenv").config();
const express = require("express");
const app = express();
const log4js = require("log4js");
const logger = log4js.getLogger("BasicNetwork");
const constants = require("../config/constants.json");

const helper = require("../app/helper");
const User = require("../models/user.model");
const jwt = require("jsonwebtoken");

logger.level = "debug";

app.set("secret", process.env.JWT_SECRET);

function getErrorMessage(field) {
  var response = {
    success: false,
    message: field + " field is missing or Invalid in the request",
  };
  return response;
}

exports.Register = async (req, res) => {
    var nama = req.body.nama;
    var username = req.body.username;
    var password = req.body.password;
    var orgName = req.body.orgName;
  
    logger.debug("End point : /users");
    logger.debug("Request body : " + req.body);
  
    if (!username) {
      res.status(400).json(getErrorMessage("'username'"));
      return;
    }
    if (!password) {
      res.status(400).json(getErrorMessage("'password'"));
      return;
    }
    if (!nama) {
      res.status(400).json(getErrorMessage("'nama'"));
      return;
    }
    if (!orgName) {
      res.status(400).json(getErrorMessage("'orgName'"));
      return;
    }
  
    var token = jwt.sign(
      {
        exp: Math.floor(Date.now() / 1000) + parseInt(constants.jwt_expiretime),
        username: username,
        orgName: orgName,
      },
      app.get("secret")
    );
  
    // wallet input
    let response = await helper.getRegisteredUser(username, orgName, true);
  
    logger.debug(
      "-- returned from registering the username %s for organization %s",
      username,
      orgName
    );
  
    // mongo input
    let mongoRes = await helper.registerUserMongo(req, res);
  
    if (response && typeof response !== "string") {
      logger.debug(
        "Successfully registered the username %s for organization %s",
        username,
        orgName
      );
      response.token = token;
      res.status(201).json({message: response, data: mongoRes});
    } else {
      logger.debug(
        "Failed to register the username %s for organization %s with::%s",
        username,
        orgName,
        response
      );
      res.status(400).json({ message: response});
    }
}

exports.Login = async (req, res) => {
    var username = req.body.username;
    var password = req.body.password;
    var orgName = req.body.orgName;
  
    logger.debug("End point : /users");
    logger.debug("User name : " + username);
    logger.debug("Org name  : " + orgName);
    if (!username) {
      res.status(400).json(getErrorMessage("'username'"));
      return;
    }
    if (!password) {
      res.status(400).json(getErrorMessage("'password'"));
      return;
    }
    if (!orgName) {
      res.status(400).json(getErrorMessage("'orgName'"));
      return;
    }
  
    var token = jwt.sign(
      {
        exp: Math.floor(Date.now() / 1000) + parseInt(constants.jwt_expiretime),
        username: username,
        orgName: orgName,
      },
      app.get("secret")
    );
  
    console.log(token);
  
    let isUserRegistered = await helper.isUserRegistered(username, orgName);
  
    if (isUserRegistered) {
      let userDB = await helper.loginUserMongo(req, res, token);
      if (userDB) {
        res
          .status(200)
          .cookie("jwt", token)
          .set("Authorization", "Bearer " + token)
          .json({
            success: true,
            message: `${userDB.username} successfully login`,
            token: token,
            user: userDB,
          });
      } else {
        res.status(400).json({
          message: "Username and password combination does not match",
        });
      }
    } else {
      res.status(404).json({
        message: `User with username ${username} is not registered with ${orgName}, Please register first.`,
      });
    }
}

exports.Logout = async (req, res) => {
    res.cookie("jwt", "", { maxAge: 1 });
    res.set("Authorization", "Bearer ");
    
    console.log(res.header);
    
    return res.status(200).json({
      message: "berhasil logout",
      data: null,
    });
}

exports.GetSingleUser = async (req, res) => {
    console.log("username", req.username);
    const user = await User.findOne({username: req.username});
    if (user) {
         res.status(200).json({
            message: "User retrieved from Mongo",
            data: user,
          });
    } else {
         res.status(404).json({
            message: "User not found",
            data: user,
          });
    }
}
