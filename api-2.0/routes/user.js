const express = require("express");
const router = express.Router();
const { 
    Register,
    Login,
    Logout,
    GetSingleUser
} = require("../controllers/user.controller");
const { Auth } = require("../middleware/middleware");

router.post("/register", Register);
router.post("/login", Login);
router.get("/logout", Logout);
router.get("/user", Auth, GetSingleUser);

module.exports = router;