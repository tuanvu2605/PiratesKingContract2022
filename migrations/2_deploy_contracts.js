const ClaimPKT = artifacts.require("ClaimPKT");
// const PiratesKingGame = artifacts.require("PiratesKingGame");
// const PiratesKingChest = artifacts.require("PiratesKingChest");
// const BNBHeroToken = artifacts.require("BNBHeroToken");



module.exports = async (deployer) => {
    await deployer.deploy(ClaimPKT);
    console.log('TestToken',ClaimPKT.address)

    // await deployer.deploy(PiratesKingChest);
    // console.log('PiratesKingChest',PiratesKingChest.address)

    // await deployer.deploy(BNBHeroToken);
    // console.log('BNBHeroToken',BNBHeroToken.address)
};
