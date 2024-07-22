from brownie import network, Contract, accounts
from brownie.network.transaction import TransactionReceipt
import time

# Uniswap V2 Router address
UNISWAP_ROUTER = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D"
# WETH address
WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"
# DAI address
DAI = "0x6B175474E89094C44Da98b954EedeAC495271d0F"

def main():
    # Connect to forked mainnet
    network.connect('mainnet-fork')

    # Get the Uniswap Router contract
    router = Contract.from_explorer(UNISWAP_ROUTER)

    # Get a funded account (this will be one of the top Ethereum accounts)
    account = accounts[0]

    # Amount of ETH to swap
    amount = 1 * 10**18  # 1 ETH

    # Perform the swap
    tx = router.swapExactETHForTokens(
        0,  # min amount of tokens to receive
        [WETH, DAI],  # path
        account.address,  # recipient
        int(time.time()) + 120,  # deadline
        {'from': account, 'value': amount}
    )

    # Print transaction details
    print(f"Transaction hash: {tx.txid}")
    print(f"Gas used: {tx.gas_used}")
    print(f"Effective gas price: {tx.effective_gas_price}")

    # Analyze the trace
    analyze_trace(tx)

def analyze_trace(tx: TransactionReceipt):
    print("\nTransaction Trace Analysis:")
    
    for trace in tx.trace:
        print(f"\nDepth: {trace['depth']}")
        print(f"Type: {trace['type']}")
        print(f"From: {trace['from']}")
        print(f"To: {trace['to']}")
        print(f"Value: {trace['value']}")
        
        if 'op' in trace:
            print(f"Opcode: {trace['op']}")
        
        if 'error' in trace:
            print(f"Error: {trace['error']}")
        
        if 'gas' in trace:
            print(f"Gas: {trace['gas']}")
        
        if 'gasCost' in trace:
            print(f"Gas Cost: {trace['gasCost']}")

if __name__ == "__main__":
    main()
