// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

import "./../IPercyPenguinWithGeneChanger.sol";

contract TestContractInteractor {

  IPercyPenguinWithGeneChanger public PercyPenguinContract;

  constructor(address _percyPenguinAddress) public {
    PercyPenguinContract = IPercyPenguinWithGeneChanger(_percyPenguinAddress);
  }

  function triggerGeneChange(uint256 tokenId, uint256 genePosition) payable public {
    PercyPenguinContract.morphGene{value: msg.value}(tokenId, genePosition);
  }

  function triggerRandomize(uint256 tokenId) payable public {
    PercyPenguinContract.randomizeGenome{value: msg.value}(tokenId);
  }
}
