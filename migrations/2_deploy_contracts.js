const PiratesKingChest = artifacts.require("PiratesKingChest");

module.exports = async (deployer) => {
    await deployer.deploy(PiratesKingChest);
    console.log(PiratesKingChest.address)
};
