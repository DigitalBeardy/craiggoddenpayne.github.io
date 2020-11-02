---
layout: post
title: AWS security and IAM Policies
image: /assets/img/aws-security-basics/cover.PNG
readtime: 15 minutes
---

When trying something out, its better to create a private testnet, than it is to use the live public network. 

As the only member in a private network, you are responsible for finding all blocks, validating all transactions and executing all smart contracts.

If you are using Geth, you need to do the following:

Create your genesis block, something like:
```
{
  "config": {
        "chainId": 0,
        "homesteadBlock": 0,
        "eip155Block": 0,
        "eip158Block": 0
    },
  "alloc"      : {},
  "coinbase"   : "0x0000000000000000000000000000000000000000",
  "difficulty" : "0x20000",
  "extraData"  : "",
  "gasLimit"   : "0x2fefd8",
  "nonce"      : "0x0000000000000042",
  "mixhash"    : "0x0000000000000000000000000000000000000000000000000000000000000000",
  "parentHash" : "0x0000000000000000000000000000000000000000000000000000000000000000",
  "timestamp"  : "0x00"
}
```
Initialise your new network with the genesis block and data directory
```
geth --datadir ~/.craig_ethereum_private init ~/Code/genesis.json
```
Start the console, and attach to the network via inter process communication
```
geth --fast --cache 512 --ipcpath ~/Library/Ethereum/geth.ipc --networkid 99999 --datadir ~/.craig_ethereum_private console 
```


<amp-img src="/assets/img/aws-security-basics/example.png"
  width="400"
  height="140"
  layout="responsive">
</amp-img>
