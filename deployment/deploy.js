const etherlime = require('etherlime-lib');
const ethers = require('ethers');
const PercyPenguinWithGeneChanger = require('../build/PercyPenguinWithGeneChanger.json');


const deploy = async (network, secret, etherscanApiKey) => {

    const deployer = new etherlime.InfuraPrivateKeyDeployer(secret, network, process.env.API_KEY);
    const gasPrice = 
    const gasLimit = 

    const tokenName = "Percy Penguin";
    const tokenSymbol = "PMSZ";
    const metadataURI = "";
    const DAOAddress = ""; 
    const premint = 0
    const geneChangePrice = ether.utils.parseEther("10");   //MATIC
    const percyPenguinPrice = ether.utils.parseEther("50"); //MATIC
    const percyPenguinMaxSupply = 5000
    const randomizePrice = ether.utils.parseEther("5");     //MATIC
    const bulkBuyLimit = 20
    const arweaveContainer = "" //IPFS?? or ARWEAVE?

    deployer.defaultOverrides = { gasLimit, gasPrice };
    const result = await deployer.deploy(
        PercyPenguinWithGeneChanger,
        {},
        tokenName,
        tokenSymbol,
        metadataURI,
        DAOAddress,
        premint,
        geneChangePrice,
        percyPenguinPrice,
        percyPenguinMaxSupply,
        randomizePrice,
        bulkBuyLimit,
        arweaveContainer);

};

module.exports = {
    deploy
};