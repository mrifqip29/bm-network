require("dotenv").config();
const jwt = require("jsonwebtoken");
const util = require("util");
const log4js = require("log4js");
const logger = log4js.getLogger("BasicNetwork");

//TODO confirm the token == user token
// check jwt token
exports.Auth = async (req, res, next) => {
    //const token = req.cookies.jwt;
    const auth = req.headers.authorization;

    if (!auth) {
      return res.status(401).json({
        message: "Authorization error",
      });
    }

    console.log("auth", auth);
    const token = auth.split(" ")[1];
    console.log("token", token);
  
    if (!token) {
      //ini bisa ditambahin res.status(404).redirect("/").json({})
      return res.status(401).json({
        message: "Token not found",
      });
    }
  
    // const decode = jwt.verify(token, process.env.JWT_SECRET);
    // console.log("decoded", decode);
    // req.username = decode.username;
    // req.orgName = decode.orgName;

   jwt.verify(token, process.env.JWT_SECRET, (err, decoded) => {
      if (err) {
        console.log(`Error ================:${err}`);
        res.status(401).send({
          success: false,
          message:
            "Failed to authenticate token."
        });
        return;
      } else {
        req.username = decoded.username;
        req.orgName = decoded.orgName;
        logger.debug(
          util.format(
            "Decoded from JWT token: username - %s, orgname - %s",
            decoded.username,
            decoded.orgName
          )
        );
        return next();
      }
    });
  };

  // exports.IsLoggedIn = async (req, res, next) => {
  //   var token = req.token;
  //   jwt.verify(token, app.get("secret"), (err, decoded) => {
  //     if (err) {
  //       console.log(`Error ================:${err}`);
  //       res.send({
  //         success: false,
  //         message:
  //           "Failed to authenticate token. Make sure to include the " +
  //           "token returned from /users call in the authorization header " +
  //           " as a Bearer token",
  //       });
  //       return;
  //     } else {
  //       req.username = decoded.username;
  //       req.orgname = decoded.orgName;
  //       logger.debug(
  //         util.format(
  //           "Decoded from JWT token: username - %s, orgname - %s",
  //           decoded.username,
  //           decoded.orgName
  //         )
  //       );
  //       return next();
  //     }
  //   });
  // }