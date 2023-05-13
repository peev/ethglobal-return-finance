const hre = require("hardhat");

async function main() {
  console.log("Starting deploy Return Finance USDC Vault...");
  const ReturnFinanceUSDCVault = await hre.ethers.getContractFactory(
    "ReturnFinanceUSDCVault"
  );
  const returnFinanceUSDCVault = await ReturnFinanceUSDCVault.deploy();

  await returnFinanceUSDCVault.deployed();

  console.log(
    `Return Finance USDC Vault deployed to: https://optimistic.etherscan.io/address/${returnFinanceUSDCVault.address}`
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
