require('@nomiclabs/hardhat-waffle');
// require('@nomiclabs/hardhat-etherscan');
// require('hardhat-abi-exporter');
task('accounts', 'Prints the list of accounts', async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});
module.exports = {
  solidity: '0.8.4',
  networks: {
    emeraldTestnet: {
      url: 'https://testnet.emerald.oasis.dev',
      accounts: [`0xa0f7c01bdaa5d326165ab0f90e11509ac69324d76a75df73c534719916840419`],
    },
    local: {
      url: 'http://127.0.0.1:8545/',
      accounts: [`0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80`],
    },
  },
};
