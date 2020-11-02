---
layout: post
title: Blockchain and cryptoeconomics
image: /assets/img/blockchain/blockchain.jpg
tags: blockchain dlt ethereum bitcoin hyperledger permissioned permissionless distributed ledger standards regulations crypto
readtime: 22 minutes
---

Blockchains have recently gained popularity in several industries, and although I am yet to use them in my day to day, it's something I would like to in the short term. This post is really just some research I have made though training, and reading about various permissioned and permissionless blockchains.

### Intro

Blockchains can solve problems and create efficiencies in tech areas such as privacy, security and data sharing. Blockchains help to move away from the centralized "one source of truth" monolith database, that most companies have. In fact in almost every job I have had, there is always a huge, single production database, that contains all the business critical data, and if it were to go down, there would be chaos.


Since as far back as I can remember, we have always been trying to move away from centralised computing, and splitting software into smaller chunks, microservices and moving into the cloud. One thing that always remains is a huge monolith database. I've seen this change slightly into smaller, domain specific databases and stores, but usually there is still a single point where everything comes together.

<amp-img class="center" src="/assets/img/blockchain/network.png"
  width="709"
  height="195"
  layout="responsive">
</amp-img>

A blockchain is a type of distributed ledge technology, which basically means it is a data structure which resides across multiple computing devices, typically spread across multiple devices and regions. DLTs existed before bitcoin, but bitcoin brought together some of the core ideas, with regards to timestamping, P2P, crytography and sharing the computing power. A good description of a DTL could be summed up in through points:

- Data structure that captures the current state of a ledger
- Transactions that change the ledger state
- Protocol to allow transactions to be accepted

<amp-img class="center" src="/assets/img/blockchain/p2p.jpg"
  width="264"
  height="195">
</amp-img>

A blockchain will track various assets transactions. The transactions are are grouped into blocks. There be any number of these transactions in a block. Nodes on the blockchain network group up the transactions and send them through the network. They are synced up by an agreement by all peers, and eventually each node will contain an up to date version of the ledger. Blockchain just basically a P2P distributed ledger, which is ruled by smart contracts. Smart contracts are just predefined actions that are performed when certain conditions are met.

Blockchain used to be referred to as the specific data structure within a DLT, but now a lot of people use the term blockchain to refer to anything, from cryptocurrencies to enterprise deployments of DLTs. Blockchain is a very wide term, and is comparable to the word internet.

Blockchain is in a basic form, a chronological chain of blocks of transactions, that are bundled together and added to the chain, at the same time.

Bitcoin is a good example to explain this in more detail:

<amp-img src="/assets/img/blockchain/bitcoin.jpg"
  width="400"
  height="200"
  layout="responsive">
</amp-img>

Miner nodes bundle unconfirmed and valid transactions into a block. The miners must then solve a cryptographic challenge, to propose the next block. People refer to this as "proof of work".

A block consists of 4 metadata.

- Reference of previous block
- Proof of work (known as nonce)
- Timestamp
- Merkle tree root of transactions

<amp-img src="/assets/img/blockchain/merkle.png"
  width="1021"
  height="391"
  layout="responsive">
</amp-img>

### Why is blockchain technology so good?

Blockchain creates a distributed consensus between mutual distrustful parties, whilse creating a shared instantanious source of truth. 

In comparison, some banks will reconsile at the end of the day, and some shops will process all sales at the end of the day and update stock levels, ready for the next day.

### What is the difference between a blockchain and a database?

A blockchain is a write only, data structure, where the next record is always written at the end of the chain. This is achieved by each block referencing the previous block, meaning there is not an easy way to have to edit or delete data from the blockchain, and an attempt to do this, would be extremely easy to detect. 

In comparison, a database can easily be manipulated and changed by a database administrator, or an application which may change the state of some data.

Blockchains we designed to be decentralised, where databases are usually designed to be centralised, or tend to have a single "master" node, which controls the data.

### Smart Contracts

Smart contracts are pieces of code, that execute pre-defined actions, when certain conditions are met. This allows the ledger state to be modified, or faciliates the transfer of some kind of asset, or can verify or negotiate a legal contract of some kind. They were made popular by the ethereum blockchain.

<amp-img src="/assets/img/blockchain/smart-contracts.png"
  width="630"
  height="543"
  layout="responsive">
</amp-img>

### An example of an etherum smart contract

In an equity raise, transfer X amount from the investor, to the company on recieving the shares from the company.

The monetary value of X has been pre-validated by the company for the transaction. The amount is held by the smart contract until the shares are recieved.

- The smart contract encodes the agreement between a company raising funds and its investors
- The smart contract sits on the ethereum public blockchain. Once an event is triggered, for example an expiration date, or a strike price that has been pre-coded, the smart contract executes its logic.
- If needed, regulators can scrutinise the market activity without comprimising the identity of the specific parties involved.

### Another example

Check out the website [https://stamp.io](https://stamp.io)

You can take a document and upload it to the ethereum blockchain.

Stamp.io will then return a certificate, and you can view your transaction then on the public ethereum blockchain

<amp-img src="/assets/img/blockchain/stampio.png"
  width="1038"
  height="461"
  layout="responsive">
</amp-img>

### Why were ethereum and bitcoin created, and what problem do they solve?

Bitcoin was released in 2009, in response to the global financial crash at the time. The idea was to transfer value, over the internet without an intermediary. Bitcoin is esentially programmable money.

Ethereum was created in response to bitcoin, and it has a more extensive set of APIs, and allows for smart contracts. At the core of the ethereum blockchain are EVMs (ethereum virtual machines), which run on the ethereum network. Unlike bitcoin, it does not just track transactions.

### Cryptoeconomics

Cryptoeconomics is about building systems, that have certain desired properties, which use cryptography to prove properties about messages, that happened in the past, while using economic incentives, defined inside the system.

Rather than imposing barriers to entry, permissionless blockchains, such as bitcoin are public and open. Although, this can also mean they are open to malicious attackers.

This is prevented by having good behaviour incentivised so that:
- malicious attackers cannot take over the system with an escalated attack
- malicious attackers cannot undertake an organised majority attack
- the payoffs of securing are higher than the payoffs for attacking

### Consensus Algorithms

<amp-img src="/assets/img/blockchain/consensus.JPG"
  width="511"
  height="355"
  layout="responsive">
</amp-img>

Concensus is the process of achieving agreement among network participants as to the correct state of the data in a system.

It does two things:
- Ensures data is the same for every node on the network
- Prevents malicious actors from changing the information.

Bitcoin mining is one example of a consensus algorithm, although there are others.

#### Proof of work

<amp-img src="/assets/img/blockchain/proof-of-work.png"
  width="407"
  height="423">
</amp-img>

PoW is used within bitcoin, and is usually referred to as mining. In order to add a new block onto the block chain, a computational challenge must be solved.

The incentive for "mining" is an economic payoff.

Proof of work is hard to create, but easy to verify, you could compare this to a combination lock. Its really difficult to guess the correct sequence of numbers of a combination lock, but once you know the combination, its easy to verify, because it opens the lock.

Proof of work requires a huge amount of energy to be expelled, and each block usually takes about 10 minutes to mine.

Mining is concentrated in countries where energy is cheap.

#### Proof of stake

<amp-img src="/assets/img/blockchain/proof-of-stake.png"
  width="240"
  height="174">
</amp-img>

In PoS, nodes are known as validators, rather than miners. When a node validates, it earns a small transaction fee.

Nodes are randomly selected to validate blocks, and the probability of selection is based on the stake already held. This saves the massive amount of computational resource involved to create the next block.

Example of how selection works:
If node X already has validated and earned 2 coins, and node Y has 1 coin, node X is twice as likely to be called upon to validate a block of transactions.

#### Proof of elapsed time

<amp-img src="/assets/img/blockchain/proof-of-elapsed-time.png"
  width="421"
  height="392"
  layout="responsive">
</amp-img>

PoET emulates the mining style of bitcoins proof of work, but instead of competing to solve a cryptographic challenge, there is a random lottery, and works on a first come first serve basis. Each validator is given a random wait time.

The winner creates the next block on the chain.


#### Proof of Authority

<amp-img src="/assets/img/blockchain/proof-of-authority.png"
  width="293"
  height="191">
</amp-img>

PoA uses a set of authorities, which are designated nodes, who are allowed to create blocks on the chain.
Ledgers using PoA require sign off by the majority of the authority nodes in order for the block to be created.

#### Comparison

|Type|Speed|Scalability|Finality|
|------|-|-|-|
|Lottery|Good|Good|Moderate|
|Voting|Good|Moderate|Good|
|PoW|Poor|Good|Poor|

### Challenges in Adoption, and deployment of Distributed Ledger Technologies.

At the moment, there are a lot of challenges.

- Lack of Standards
- Regulatory challenges
- Lack of knowledge

#### Standards

Standards need to be in place to ensure interoperability and prevent a fragmented ecosystem. Standards do not just need to be created for the blockchain, but also services used on it, like privacy, identity and data governance.

In 2016 the International Organisation of Standardisation for Blockchain and Distributed Ledger Technologies was created.

#### Regulations 

Lack of regulation creates uncertainty for everyone involved. Highly regulated sectors, such as finance are treading very carefully with distributed ledger technologies, as there are no regulatory guidelines at this time for smart contracts.

This is most likely one of the major reasons that is preventing the rapid adoption of DLTs.

#### Lack of know how

Blockchain is general is gaining more traction, and people are becoming more interested in it, but there is still a lack of technical talent of people in blockchain

<amp-img src="/assets/img/blockchain/crypto.png"
  width="664"
  height="434"
  layout="responsive">
</amp-img>

