require("dotenv").config();
const jwt = require("jsonwebtoken");
const User = require("../models/user.model");

//TODO confirm the token == user token
// check jwt token
exports.Auth = async (req, res, next) => {
    //const token = req.cookies.jwt;
    const auth = req.headers.authorization;
    console.log("auth", auth);
    const token = auth.split(" ")[1];
    console.log("token", token);
  
    if (!token) {
      //ini bisa ditambahin res.status(404).redirect("/").json({})
      return res.status(404).json({
        message: "tidak ada token",
      });
    }
  
    const decode = jwt.verify(token, process.env.JWT_SECRET);
    console.log("decoded", decode);
    req.username = decode.username;
    next();
  };