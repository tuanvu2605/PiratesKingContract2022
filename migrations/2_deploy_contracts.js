const PiratesKingToken = artifacts.require("PiratesKingToken");
// const BNBHeroToken = artifacts.require("BNBHeroToken");



module.exports = async (deployer) => {
    await deployer.deploy(PiratesKingToken);
    console.log('PiratesKingToken',PiratesKingToken.address)

    // await deployer.deploy(BNBHeroToken);
    // console.log('BNBHeroToken',BNBHeroToken.address)
};
