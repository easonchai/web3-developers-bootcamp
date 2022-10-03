const { ethers } = require("ethers");

const main = async () => {
  const mainnetProvider = new ethers.providers.AlchemyProvider();
  const goerliProvider = new ethers.providers.AlchemyProvider("goerli");

  // Look up the current block number
  const blockNumber = await provider.getBlockNumber();
  console.log("Block number: ", blockNumber);

  // Get the balance of an account (by address or ENS name, if supported by network)
  const balance = await provider.getBalance("vitalik.eth");
  console.log("Balance: ", balance);

  // Often you need to format the output to something more user-friendly,
  // such as in ether (instead of wei)
  const formattedBalance = await ethers.utils.formatEther(balance);
  console.log("Formatted balance: ", formattedBalance);

  const signer = new ethers.Wallet("YOUR_PRIVATE_KEY", goerliProvider);

  // You need to resolve this on mainnet/rinkeby since ENS exists on only those networks
  const resolvedAddress = await mainnetProvider.resolveName("vitalik.eth");

  const tx = {
    to: resolvedAddress,
    value: ethers.utils.parseEther("0.000001"),
    nonce: 8,
    gasPrice: 10000000000,
  };

  const txReceipt = await signer.sendTransaction(tx);
  console.log(txReceipt);

  await txReceipt.wait();
  console.log("Mined!");
};

main();
