var CErc20Delegate = artifacts.require("./CErc20Delegate.sol");

module.exports = async function(deployer) {
  await deployer.deploy(CErc20Delegate);
  await CErc20Delegate.deployed();
  const CT1 = CErc20Delegate.address;
  console.log(CT1);

  await deployer.deploy(CErc20Delegate);
  await CErc20Delegate.deployed();
  const CT2 = CErc20Delegate.address;
  console.log(CT2);

  await deployer.deploy(CErc20Delegate);
  await CErc20Delegate.deployed();
  const CT3 = CErc20Delegate.address;
  console.log(CT3);

  await deployer.deploy(CErc20Delegate);
  await CErc20Delegate.deployed();
  const CT4 = CErc20Delegate.address;
  console.log(CT4);

  await deployer.deploy(CErc20Delegate);
  await CErc20Delegate.deployed();
  const CT5 = CErc20Delegate.address;
  console.log(CT5);
};
