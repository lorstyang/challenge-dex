// SPDX-License-Identifier: MIT
pragma solidity 0.8.20; //Do not change the solidity version as it negatively impacts submission grading

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DEX {
    /////////////////
    /// Errors //////
    /////////////////

    error DexAlreadyInitialized();
    error TokenTransferFailed();

    //////////////////////
    /// State Variables //
    //////////////////////

    IERC20 public immutable token;
    uint256 public totalLiquidity;
    mapping(address => uint256) liquidity;

    ////////////////
    /// Events /////
    ////////////////

    event EthToTokenSwap(address indexed swapper, uint256 ethInput, uint256 tokenOutput);
    event TokenToEthSwap(address indexed swapper, uint256 tokensInput, uint256 ethOutput);
    event LiquidityProvided(address indexed liquidityProvider, uint256 ethInput, uint256 tokensInput, uint256 liquidityMinted);
    event LiquidityRemoved(address indexed liquidityRemover, uint256 ethOutput, uint256 tokensOutput, uint256 liquidityWithdrawn);

    ///////////////////
    /// Constructor ///
    ///////////////////

    constructor(address tokenAddr) {
        token = IERC20(tokenAddr);
        init(0);
    }

    ///////////////////
    /// Functions /////
    ///////////////////

    function init(uint256 tokens) public payable returns (uint256 initialLiquidity) {
        // Pool can only be initialized once.
        if (totalLiquidity != 0)
            revert DexAlreadyInitialized();

        // ETH arrives before function execution, so balance includes msg.value here.
        initialLiquidity = address(this).balance;
        totalLiquidity = initialLiquidity;
        liquidity[msg.sender] = initialLiquidity;

        if (!token.transferFrom(msg.sender, address(this), tokens))
            revert TokenTransferFailed();
        
        return initialLiquidity;
    }

    function price(uint256 xInput, uint256 xReserves, uint256 yReserves) public pure returns (uint256 yOutput) {
        // Your code here...
    }

    function getLiquidity(address lp) public view returns (uint256 lpLiquidity) {
        return liquidity[lp];
    }

    function ethToToken() public payable returns (uint256 tokenOutput) {
        // Your code here...
    }

    function tokenToEth(uint256 tokenInput) public returns (uint256 ethOutput) {
        // Your code here...
    }

    function deposit() public payable returns (uint256 tokensDeposited) {
        // Your code here...
    }

    function withdraw(uint256 amount) public returns (uint256 ethAmount, uint256 tokenAmount) {
        // Your code here...
    }
}
