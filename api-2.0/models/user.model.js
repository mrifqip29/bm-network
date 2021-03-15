const mongoose = require("mongoose");

const userSchema = new mongoose.Schema({
  nama: {
    type: String,
    required: [true, "nama tidak boleh kosong"],
  },
  nomorHP: {
    type: String,
  },
  username: {
    type: String,
    required: [true, "username tidak boleh kosong"],
  },
  password: {
    type: String,
    required: [true, "password tidak boleh kosong"],
  },
  ttl: {
    type: String,
  },
  noKK: {
    type: Number,
  },
  noNPWP: {
    type: Number,
  },
  nik: {
    type: Number,
  },
  memberType: {
    type: String,
  },
  luasLahan: {
    type: Number,
  },
  alamatToko: {
    type: String,
  },
  alamatLahan: {
    type: String,
  },
  kelompokTani: {
    type: String,
  },
});

module.exports = mongoose.model("User", userSchema);
