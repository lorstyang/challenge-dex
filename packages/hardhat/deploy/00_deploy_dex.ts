import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { DEX } from "../typechain-types/contracts/DEX";
import { Balloons } from "../typechain-types/contracts/Balloons";

/**
 * Deploys a contract named "YourContract" using the deployer account and
 * constructor arguments set to the deployer address
 *
 * @param hre HardhatRuntimeEnvironment object.
 */
const deployYourContract: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  /*
    On localhost, the deployer account is the one that comes with Hardhat, which is already funded.

    When deploying to live networks (e.g `yarn deploy --network sepolia`), the deployer account
    should have sufficient balance to pay for the gas fees for contract creation.

    You can generate a random account with `yarn generate` which will fill DEPLOYER_PRIVATE_KEY
    with a random private key in the .env file (then used on hardhat.config.ts)
    You can run the `yarn account` command to check your balance in every network.
  */
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;
  const isLocalNetwork = hre.network.name === "hardhat" || hre.network.name === "localhost";
  const initialLiquidityEth = process.env.DEX_INIT_ETH ?? (isLocalNetwork ? "5" : "0.01");
  const initialLiquidity = hre.ethers.parseEther(initialLiquidityEth);

  await deploy("Balloons", {
    from: deployer,
    // Contract constructor arguments
    //args: [deployer],
    log: true,
    // autoMine: can be passed to the deploy function to make the deployment process faster on local networks by
    // automatically mining the contract deployment transaction. There is no effect on live networks.
    autoMine: true,
  });
  // Get the deployed contract
  // const yourContract = await hre.ethers.getContract("YourContract", deployer);
  const balloons: Balloons = await hre.ethers.getContract("Balloons", deployer);
  const balloonsAddress = await balloons.getAddress();

  await deploy("DEX", {
    from: deployer,
    // Contract constructor arguments
    args: [balloonsAddress],
    log: true,
    // autoMine: can be passed to the deploy function to make the deployment process faster on local networks by
    // automatically mining the contract deployment transaction. There is no effect on live networks.
    autoMine: true,
  });

  const dex = (await hre.ethers.getContract("DEX", deployer)) as DEX;

  // CHECKPOINT 2: Paste in your front-end address here to get 10 balloons on deploy:
  await balloons.transfer("0x43E3fCe14a1f218968f222d9f011469bE6C9735B", hre.ethers.parseEther("10"));
  // CHECKPOINT 3: Uncomment to init DEX on deploy:
  const dexAddress = await dex.getAddress();
  console.log("Approving DEX (" + dexAddress + ") to take Balloons from main account...");
  // If you are going to the testnet make sure your deployer account has enough ETH
  await balloons.approve(dexAddress, initialLiquidity);
  const deployerBalance = await hre.ethers.provider.getBalance(deployer);
  if (deployerBalance < initialLiquidity) {
    throw new Error(
      `Insufficient ETH for DEX init: balance=${hre.ethers.formatEther(deployerBalance)} ETH, required at least ${initialLiquidityEth} ETH + gas. Fund deployer or set DEX_INIT_ETH.`,
    );
  }
  console.log("INIT exchange...");
  await dex.init(initialLiquidity, {
    value: initialLiquidity,
    gasLimit: 200000,
  });
};

export default deployYourContract;

// Tags are useful if you have multiple deploy files and only want to run one of them.
// e.g. yarn deploy --tags YourContract
deployYourContract.tags = ["Balloons", "DEX"];
