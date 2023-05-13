import MetaMaskSDK from "@metamask/sdk";
import { ethers } from "ethers";
import { useState } from "react";
import "./App.css";

// MetaMask SDK initialization
const MMSDK = new MetaMaskSDK();
const ethereum = MMSDK.getProvider();

// This app will only work on Optimism
const OPTIMISM_CHAIN_ID = "10";

// Return Finance contract initialization
const provider = new ethers.providers.Web3Provider(ethereum, "any");
const RETURN_CONTRACT_ADDRESS = "0xad17a225074191d5c8a37b50fda1ae278a2ee6a2";

const abi = [
  {
      "inputs": [],
      "name": "withdraw",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
  },
];
const returnContract = new ethers.Contract(
RETURN_CONTRACT_ADDRESS,
abi,
provider.getSigner()
);

function App() {
  const [walletBalance, setWalletBalance] = useState(0);
  const [faucetBalance, setFaucetBalance] = useState(0);
  return (
    <div className="container">
      <img className="header-image" alt="" src="https://4033360328-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2FCn5NyIfWAJDviT4SySgQ%2Fuploads%2FioJYt2OT0YM59pv5WasM%2FScreenshot%202023-01-10%20at%2022.26.10.png?alt=media&amp;token=142c82ac-855c-4fbf-8a07-e7de37d9eade"></img>
      <h1 className="title">
        Return Finance Demo App
        <br></br>
        <span className="subtitle">
          This app allows you to simluate deposit and withdraw of 10 USDC from Circle Wallet to Return Finance smart contract.
        </span>
      </h1>
      <div className="balance-container">
        <h2 className="balance-item">Circle Balance: {faucetBalance} USDC</h2>
        <h2 className="balance-item">My Wallet Balance: {walletBalance} USDC</h2>
      </div>
      <div className="button-container">
        <button className="button">Withdraw 10 USDC</button>
        <button className="button">Deposit 10 USDC</button>
      </div>
    </div>
  );
}

export default App;