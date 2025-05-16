# **PetTrace**

**PetTrace** is a **decentralized pet recovery platform** built on the **Base network**, enabling users to post missing pet alerts, attach bounties, and reward those who help reunite pets with their families.

---

### 🔗 [Live Demo](https://pet-trace-base-git-main-jadesola0710s-projects.vercel.app/)

### 💻 [GitHub Repository](https://github.com/jadesola0710/PetTrace-Base)

---

## **Features**

- 🐾 **Lost Pet Posting** – Users can register lost pets with images, descriptions, and last known locations.
- 🎯 **Bounty System** – Attach a bounty in USDC to encourage community help.
- ✅ **Recovery Confirmation** – Mark pets as found and release bounties securely via smart contracts.
- 🔐 **Owner Contact Info** – Easily contact pet owners with name, phone, and email details.
- 🌍 **Base Integration** – Built on Base for low-cost and fast transactions.

---

## **Project Structure**

```
PetTrace/
│── contract/          # Solidity smart contracts (Hardhat)
│── frontend/ # Next.js frontend
│── README.md         # Project documentation
```

---

## **Installation & Setup**

### 1️⃣ Clone the Repository

```sh
git clone https://github.com/jadesola0710/PetTrace-Base.git
cd pettrace
```

### 2️⃣ Install Dependencies

#### Backend

```sh
cd contract
pnpm install  # or yarn / npm
```

#### Frontend

```sh
cd frontend
pnpm install
```

---

## **Environment Variables**

Create a `.env` file in both `backend/` and `pettrace-frontend/`.

### Backend (`backend/.env`)

```env
PRIVATE_KEY=your_private_key
```

### Frontend (`pettrace/.env`)

```env
NEXT_PUBLIC_CONTRACT_ADDRESS=your_smart_contract_address
NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID=your_wallet_connect_project_id
NEXT_PUBLIC_APP_NAME=your_project_name
```

---

## **Running the Project**

### 🔧 Compile the Smart Contract

```sh
cd backend
yarn hardhat compile
```

### 🚀 Deploy the Smart Contract

```sh
npx hardhat ignition deploy ./ignition/modules/PetTrace.js --network base_sepolia
```

### 🖥️ Start the Frontend

```sh
cd frontend
pnpm run dev
```

---

## **Smart Contract Deployment**

Deployed to **Base** :

| Contract | Address                                      |
| -------- | -------------------------------------------- |
| PetTrace | `0xE57FdF69F2010faeD5F41209a65F1eD32Ec95E07` |

Transaction:
(https://base-sepolia.blockscout.com/tx/0xe185c5318cc8d9fc51b98f8dc1cf8efbd992e6b77330b73bbed63e5428cdee1e)[https://base-sepolia.blockscout.com/tx/0xe185c5318cc8d9fc51b98f8dc1cf8efbd992e6b77330b73bbed63e5428cdee1e]

---

---

## **How It Works**

1. Connect your wallet.
2. Post a missing pet with details (image, name, breed, last seen, etc).
3. Attach a bounty in USDC to incentivize help.
4. Once found, mark the pet as recovered.
5. The finder claims the bounty securely via smart contract.

---

## **Tech Stack**

- **Frontend:** Next.js + React + TypeScript
- **Smart Contracts:** Solidity (Hardhat + Ignition)
- **Blockchain:** Celo Alfajores Testnet
- **Wallets:** MetaMask, Celo Extension Wallet, RainbowKit
- **Storage:** Temporary URL-based images (no IPFS yet)

---

## **Future Enhancements**

- Support for IPFS or decentralized media storage
- Geolocation tagging for pets
- Pet recovery history dashboard
- Mobile-responsive design
- Reputation scoring for pet finders

---

## **Contributing**

Pull requests are welcome!

1. Fork the repository
2. Create a branch (`feature/your-feature`)
3. Commit and push your changes
4. Open a pull request

---

## **License**

This project is open-sourced under the **MIT License**.
