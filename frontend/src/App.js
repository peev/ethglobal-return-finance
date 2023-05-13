import MetaMaskSDK from "@metamask/sdk";
import { ethers } from "ethers";
import { useEffect, useState } from "react";
import "./App.css";

// MetaMask SDK initialization
const MMSDK = new MetaMaskSDK();
const ethereum = MMSDK.getProvider();

// This app will only work on Optimism
const OPTIMISM_CHAIN_ID = "0xa";

// Providing the USDC contract address on Optimism
const USDC_ADDRESS = "0x7F5c764cBc14f9669B88837ca1490cCa17c31607";

// Return Finance contract initialization
const provider = new ethers.providers.Web3Provider(ethereum, "any");
const RETURN_CONTRACT_ADDRESS = "0xad17a225074191d5c8a37b50fda1ae278a2ee6a2";

const abi = require('./ERC20.json');

const returnContract = new ethers.Contract(
RETURN_CONTRACT_ADDRESS,
abi,
provider.getSigner()
);

function App() {
  const [usdcBalance, setUSDCBalance] = useState(0);
  const [ethBalance, setETHBalance] = useState(0);
  const [buttonText, setButtonText] = useState("Connect");
  const [buttonDisabled, setButtonDisabled] = useState(false);
  const [onRightNetwork, setOnRightNetwork] = useState(false);
  
  // array populated by MetaMask onConnect
  const [accounts, setAccounts] = useState([]);
  const [isConnected, setIsConnected] = useState(
    accounts && accounts.length > 0
  );

  // MetaMask event listeners
  ethereum.on("chainChanged", handleNewNetwork);
  ethereum.on("accountsChanged", (newAccounts) => {
    handleNewAccounts(newAccounts);
    updateBalances();
  });

    // any time accounts changes, toggle state in the Connect button
    useEffect(() => {
      setIsConnected(accounts && accounts.length > 0);
    }, [accounts]);
  
    useEffect(() => {
    
      if (isConnected) {
        setButtonText("Connected");
        setButtonDisabled(true);
        updateBalances();
      } else {
        setButtonText("Connect");
        setButtonDisabled(false);
      }
    }, [isConnected]);

  // protect users from using the wrong network
  // disables the withdraw/deposit buttons if not on Optimism
  async function handleNewNetwork() {
    const chainId = await ethereum.request({
      method: "eth_chainId",
    });
    if (chainId != 10) {
      setOnRightNetwork(false);
    } else {
      setOnRightNetwork(true);

    }
  }

  // uses MM SDK to query latest user USDC wallet balance
  async function updateBalances() {
    if (accounts.length > 0) {

      const USDC = new ethers.Contract(USDC_ADDRESS, abi, provider);

      const ethBalance = await ethereum.request({
        method: "eth_getBalance",
        params: [accounts[0], "latest"],
      });

      var usdcBalance = await USDC.balanceOf(accounts[0]);
      try{
      usdcBalance = ethers.utils.formatUnits(usdcBalance, "6");
      setUSDCBalance(Math.round(usdcBalance * 100) / 100);
      setETHBalance(Number(ethBalance) / 10 ** 18);
      } catch (e){
        console.log(e);
      }
      
    }
  }

    // handles user connecting to MetaMask
  // will add Optimims network if not already a network in MM
  // will switch to Optimism (bug, can't currently do this)
  async function onClickConnect() {
    try {
      const newAccounts = await ethereum.request({
        method: "eth_requestAccounts",
      });
      handleNewAccounts(newAccounts);
      try {
        await window.ethereum.request({
          method: "wallet_switchEthereumChain",
          params: [{ chainId: OPTIMISM_CHAIN_ID }], // Check networks.js for hexadecimal network ids
        });
      } catch (e) {
        if (e.code === 4902) {
          try {
            await window.ethereum.request({
              method: "wallet_addEthereumChain",
              params: [
                {
                  chainId: OPTIMISM_CHAIN_ID,
                  chainName: "Optimism",
                  rpcUrls: [
                    "https://rpc.ankr.com/optimism",
                  ],
                  nativeCurrency: {
                    name: "Optimism Ether",
                    symbol: "ETH",
                    decimals: 18,
                  },
                  blockExplorerUrls: ["https://optimistic.etherscan.io/"],
                },
              ],
            });
          } catch (e) {
            console.log(e);
          }
        }
      }
      setIsConnected(true);
      handleNewNetwork();
    } catch (error) {
      console.error(error);
    }
  }

  // hook to change state
  function handleNewAccounts(newAccounts) {
    setAccounts(newAccounts);
  }

  // withdraws 12 USDC to the Return smart contract
  async function withdrawUSDC() {
    console.log(ethereum);
    // const provider = await alchemy.

    const tx = await returnContract.withdraw({
      from: accounts[0],
    });
    await tx.wait();
    updateBalances();
  }

  // deposits 12 USDC to the Return smart contract
  async function depositUSDC() {
    const signer = provider.getSigner();
    const tx_params = {
      from: accounts[0],
      to: RETURN_CONTRACT_ADDRESS,
      value: "10000000000000000"
    };


  }

  return (
    <div className="container">
      <h1 className="title">
        Return Finance Demo App
      </h1>
      <img className="header-image" alt="" src="https://4033360328-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2FCn5NyIfWAJDviT4SySgQ%2Fuploads%2FioJYt2OT0YM59pv5WasM%2FScreenshot%202023-01-10%20at%2022.26.10.png?alt=media&amp;token=142c82ac-855c-4fbf-8a07-e7de37d9eade"></img>    
        <span className="subtitle">
        <p>Simluate deposit and withdraw of 12 USDC from Circle Wallet to Return Finance smart contract deployed on the Optimism network.</p>
        <p>The current strategy distributes equal amounts of USD across yEarn USDC and AAVE USDC pools on Optimism.</p>
        </span>
      
      <div className="wallet-container">
        <div className="wallet wallet-background">
          <div className="balance-container">
            <h1 className="address-item">Connect your wallet and stake USDC</h1>
            <p className="balance-item">
              <b>My Wallet Address:</b> {accounts[0]}
            </p>
            <p className="balance-item">
              <b>My EHT Balance:</b> {ethBalance} Ξ
            </p>
            <button
              className="button"
              onClick={onClickConnect}
              disabled={buttonDisabled}
            >
              {buttonText}
            </button>
          </div>
        </div>
      </div>
      <div className="balance-container">
        <h2 className="balance-item">My USDC Balance: {usdcBalance} USDC</h2>
        {isConnected
          ? "Connected to MetaMask ✅"
          : "Not connected to MetaMask ❌"}
      </div>
      <div className="button-container">
    
          <button
            onClick={depositUSDC}
            className="button"
            disabled={!isConnected || !onRightNetwork}
          >
            Deposit 12 USDC
          </button>

      </div>
      <div className="button-container">
          <button
            onClick={withdrawUSDC}
            className="button"
            disabled={!isConnected || !onRightNetwork}
          >
            Withdraw 12 USDC + Yield
          </button>
      </div>  
    </div>
  );
}

export default App;