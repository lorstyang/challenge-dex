# Challenge DEX

基于 `Scaffold-ETH 2` 的 DEX 挑战项目，实现了一个最小可用的 AMM（`x * y = k`），支持 `ETH ↔ BAL` 兑换与流动性管理。

## 原项目来源与致谢

本项目基于以下开源项目与挑战模板进行开发与扩展：

- Scaffold-ETH 2: https://github.com/scaffold-eth/scaffold-eth-2
- SpeedRunEthereum - Challenge DEX: https://github.com/scaffold-eth/se-2-challenges/tree/challenge-dex

感谢 Scaffold-ETH / SpeedRunEthereum 社区提供的教程、脚手架与挑战设计。

## 项目信息

- 项目名称: `challenge-dex`
- 网络: `Sepolia` (`chainId: 11155111`)
- 前端目标网络配置: `packages/nextjs/scaffold.config.ts`
- 合约目录: `packages/hardhat/contracts`
- 前端目录: `packages/nextjs`

### 技术栈

- Smart Contract: Solidity + Hardhat + hardhat-deploy
- Frontend: Next.js + React + TypeScript
- Web3: Wagmi + Viem + RainbowKit

## 功能结果

当前版本已完成以下核心能力：

- `init(uint256 tokens)`: 初始化池子（只允许一次）
- `price(...)`: 按 `x * y = k` + 0.3% fee 计算报价
- `ethToToken()`: ETH 换 BAL
- `tokenToEth(uint256)`: BAL 换 ETH
- `deposit()`: 按当前储备比例添加流动性
- `withdraw(uint256)`: 按份额提取流动性
- 完整事件与错误定义（便于前端展示和调试）

合约实现文件：`packages/hardhat/contracts/DEX.sol`

## 部署结果（Sepolia）

以下信息来自仓库内部署产物：

- `packages/hardhat/deployments/sepolia/Balloons.json`
- `packages/hardhat/deployments/sepolia/DEX.json`
- `packages/nextjs/contracts/deployedContracts.ts`

### 合约地址

- Balloons (BAL): `0xc53787b80b27f05e7AbF3C812cDB659D3DdECfbb`
- DEX: `0x09397e406D118e1ABa85cd590dB44634a5C5A421`

### 部署交易

- Balloons Tx:
  `0xbc97348fea06248d177b690a62978117ed31023339c4b666c6f87ad00afc2845`
- DEX Tx:
  `0x4476aa6d2d29452475e10e33c798e70a92c404bc8eae815c0c25d4ccdd1851af`

### 区块信息

- Balloons deployedOnBlock: `10312977`
- DEX deployedOnBlock: `10312978`

### Etherscan

- Balloons:
  https://sepolia.etherscan.io/address/0xc53787b80b27f05e7AbF3C812cDB659D3DdECfbb
- DEX:
  https://sepolia.etherscan.io/address/0x09397e406D118e1ABa85cd590dB44634a5C5A421

## 前端地址

- 本地开发: http://localhost:3000
- 线上地址 (Vercel): https://challenge-dex-theta.vercel.app/

## 目录结构

```text
packages/
  hardhat/
    contracts/
      Balloons.sol
      DEX.sol
    deploy/
      00_deploy_dex.ts
    deployments/
      sepolia/
  nextjs/
    app/
    contracts/
    scaffold.config.ts
```
