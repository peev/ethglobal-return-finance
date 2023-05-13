import { useState } from "react";
import "./App.css";

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