// SPDX-License-Identifier: MIT
pragma solidity 0.8.20; //Do not change the solidity version as it negatively impacts submission grading

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DEX {
    /////////////////
    /// Errors //////
    /////////////////

    error DexAlreadyInitialized();
    error TokenTransferFailed();
    error InvalidEthAmount();
    error InvalidTokenAmount();
    error InsufficientTokenBalance(uint256 available, uint256 required);
    error InsufficientTokenAllowance(uint256 available, uint256 required);
    error EthTransferFailed(address to, uint256 amount);
    error InsufficientLiquidity(uint256 available, uint256 required);

    //////////////////////
    /// State Variables //
    //////////////////////

    IERC20 public immutable token;
    uint256 public totalLiquidity;
    mapping(address => uint256) liquidity;

    ////////////////
    /// Events /////
    ////////////////

    event EthToTokenSwap(address indexed swapper, uint256 tokenOutput, uint256 ethInput);
    event TokenToEthSwap(address indexed swapper, uint256 tokensInput, uint256 ethOutput);
    event LiquidityProvided(address indexed liquidityProvider, uint256 liquidityMinted, uint256 ethInput, uint256 tokensInput);
    event LiquidityRemoved(address indexed liquidityRemover, uint256 liquidityWithdrawn, uint256 tokensOutput, uint256 ethOutput);
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
        /*
        初始流动性和 ETH 数量一样，但并不代表 liquidity 等于 ETH 数量
        如果把 LP token 总量直接定义为 address(this).balance。
        会出现如下问题：
        当有人 swap 时，ETH 会变化
        但 swap 不应改变 LP 份额结构
        若用 ETH 余额做份额总量，swap 会稀释或膨胀 LP
        */
        initialLiquidity = address(this).balance;
        totalLiquidity = initialLiquidity;
        liquidity[msg.sender] = initialLiquidity;

        if (!token.transferFrom(msg.sender, address(this), tokens))
            revert TokenTransferFailed();
        
        return initialLiquidity;
    }

    function price(uint256 xInput, uint256 xReserves, uint256 yReserves) public pure returns (uint256 yOutput) {
        uint256 xInputWithFee = xInput * 997; // 0.3% fee
        uint256 numerator = xInputWithFee * yReserves;
        uint256 denominator = (xReserves * 1000) + xInputWithFee;
        return numerator / denominator;
    }

    function getLiquidity(address lp) public view returns (uint256 lpLiquidity) {
        return liquidity[lp];
    }

    function ethToToken() public payable returns (uint256 tokenOutput) {
        uint256 xInput = msg.value;
        if (0 == xInput) revert InvalidEthAmount();

        uint256 ethReserve = address(this).balance - msg.value;
        uint256 tokenReserve = token.balanceOf(address(this));
        tokenOutput = price(xInput, ethReserve, tokenReserve);

        if (!token.transfer(msg.sender, tokenOutput)) revert TokenTransferFailed();
        
        emit EthToTokenSwap(msg.sender, tokenOutput, xInput);
        return tokenOutput;
    }

    function tokenToEth(uint256 tokenInput) public returns (uint256 ethOutput) {
        if (0 == tokenInput) revert InvalidTokenAmount();

        uint256 senderBal = token.balanceOf(msg.sender);
        if (senderBal < tokenInput) revert InsufficientTokenBalance(senderBal, tokenInput);

        uint256 allow = token.allowance(msg.sender, address(this));
        if (allow < tokenInput) revert InsufficientTokenAllowance(allow, tokenInput);
        
        uint256 tokenReserve = token.balanceOf(address(this));
        ethOutput = price(tokenInput, tokenReserve, address(this).balance);
        
        if (!token.transferFrom(msg.sender, address(this), tokenInput)) revert TokenTransferFailed();

        (bool sent, ) = msg.sender.call{ value: ethOutput }("");
        if (!sent) revert EthTransferFailed(msg.sender, ethOutput);
        emit TokenToEthSwap(msg.sender, tokenInput, ethOutput);
        return ethOutput;
    }

    function deposit() public payable returns (uint256 tokensDeposited) {
        uint256 ethInput = msg.value;
        if (0 == ethInput) revert InvalidEthAmount();

        uint256 tokenReserve = token.balanceOf(address(this));
        uint256 ethReserve = address(this).balance - ethInput;
        uint256 tokenDeposit = (ethInput * tokenReserve / ethReserve) + 1;

        uint256 senderBal = token.balanceOf(msg.sender);
        if (senderBal < tokenDeposit) revert InsufficientTokenBalance(senderBal, tokenDeposit);

        uint256 allow = token.allowance(msg.sender, address(this));
        if (allow < tokenDeposit) revert InsufficientTokenAllowance(allow, tokenDeposit);

        uint256 liquidityMinted = ethInput * totalLiquidity / ethReserve;
        liquidity[msg.sender] += liquidityMinted;
        totalLiquidity += liquidityMinted;

        if (!token.transferFrom(msg.sender, address(this), tokenDeposit)) revert TokenTransferFailed();

        emit LiquidityProvided(msg.sender, liquidityMinted, ethInput, tokenDeposit);
        return tokenDeposit;
    }

    function withdraw(uint256 amount) public returns (uint256 ethAmount, uint256 tokenAmount) {
        uint256 availableLp = liquidity[msg.sender];
        if (availableLp < amount) revert InsufficientLiquidity(availableLp, amount);

        uint256 tokenReserve = token.balanceOf(address(this));
        uint256 ethReserve = address(this).balance;
        uint256 ethWithdrawn = amount * ethReserve / totalLiquidity;
        uint256 tokensWithdrawn = amount * tokenReserve / totalLiquidity;
        liquidity[msg.sender] -= amount;
        totalLiquidity -= amount;

        (bool sent, ) = payable(msg.sender).call{ value: ethWithdrawn }("");
        if (!sent) revert EthTransferFailed(msg.sender, ethWithdrawn);

        if (!token.transfer(msg.sender, tokensWithdrawn)) revert TokenTransferFailed();
        emit LiquidityRemoved(msg.sender, amount, tokensWithdrawn, ethWithdrawn);
        return (ethWithdrawn, tokensWithdrawn);
    }
}
