const hre = require("hardhat");

async function main() {
  const Voting = await hre.ethers.getContractFactory("Pool");
  const voting = await Voting.deploy();

  await voting.waitForDeployment();

  console.log("Contract deployed to :", await voting.getAddress());
  let value = await voting.check("SPIDO");
  console.log(`value : ${value}`);
  let check = await voting.checkBalance();
  console.log(`Balance : ${check}`)
  let pay = await voting.pay({value:ethers.parseEther("0.02")});
  await pay.wait();
  console.log(`Payed ? : ${pay}`);
  check = await voting.checkBalance();
  console.log(`Balance : ${ethers.formatEther(check)} ETH`)
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});