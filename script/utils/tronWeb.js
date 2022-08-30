const TronWeb = require('tronweb')

require('dotenv').config();

const tronWeb = {
    nile: new TronWeb(
        "https://api.nileex.io/",
        "https://api.nileex.io/",
        "https://api.nileex.io/",
        process.env.PRIVATE_KEY_NILE
    )
}

module.exports = tronWeb;