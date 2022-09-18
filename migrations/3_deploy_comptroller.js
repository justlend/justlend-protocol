var Comptroller = artifacts.require("./Comptroller.sol");
var Unitroller = artifacts.require("./Unitroller.sol");

module.exports = async function(deployer) {
    await deployer.deploy(Comptroller);
    await deployer.deploy(Unitroller);

    const comptroller = await Comptroller.deployed();
    const unitroller = await Unitroller.deployed();
    await unitroller._setPendingImplementation(Comptroller.address);
    await comptroller._become(Unitroller.address, []);
}