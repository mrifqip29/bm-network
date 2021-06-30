const express = require("express");
const router = express.Router();
const { 
    Register,
    Login,
    Logout,
    GetSingleUser
} = require("../controllers/user.controller");
const { Auth } = require("../middleware/middleware");

/**
 * @swagger
 * components:
 *  schemas:
 *      User:
 *          properties:
 *              id:
 *                   type: string
 *              nama:
 *                  type: string
 *              username:
 *                  type: string
 *              password:
 *                  type: string
 *              noHP:
 *                  type: string
 *              ttl:
 *                  type: string
 *              noKK:
 *                  type: integer
 *              noNPWP:
 *                  type: integer
 *              nik:
 *                  type: integer
 *              orgName:
 *                  type: string
 *              luasLahan:
 *                  type: number
 *              alamatToko:
 *                  type: string
 *              alamatLahan:
 *                  type: string
 *              kelompokTani:
 *                  type: string
 *          required:
 *              - nama
 *              - username
 *              - password
 *              - orgName
 *          example:
 *              nama: Endang
 *              username: endang64
 *              password: R4Has1@   
 *              orgName: Petani    
 */

/**
 * @swagger
 * tags:
 *  name: Users
 *  description: The users managing API 
 */

/**
 * @swagger
 * /register:
 *  post:
 *      summary: Register user
 *      tags: [Users]
 *      requestBody:
 *          required: true
 *          content:
 *              application/json:
 *                  schema:
 *                      type: object
 *                      $ref: '#/components/schemas/User'                 
 *      responses:
 *          200:
 *              description: User succesfully registered
 *              content:
 *                  schema:
 *                      items:
 *                          $ref: '#/components/schemas/User'
 */

router.post("/register", Register);


router.post("/login", Login);

/**
 * @swagger
 * /logout:
 *  get:
 *      summary: Logout user and deleting token
 *      tags: [Users]
 *      responses:
 *          200:
 *              description: User succesfully logged out
 */

router.get("/logout", Logout);

/**
 * @swagger
 * /user:
 *  get:
 *      summary: Get current user
 *      tags: [Users]
 *      responses:
 *          200:
 *              description: Current user information succesfully retrieved
 *              content:
 *                  schema:
 *                      items:
 *                          $ref: '#/components/schemas/User'
 */

router.get("/user", Auth, GetSingleUser);

module.exports = router;