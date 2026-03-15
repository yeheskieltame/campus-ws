# From Zero to DApp: Workshop Coinvestasi x Dev Web3 Jogja

> Workshop hands-on membangun DApp (Decentralized Application) dari nol — deploy Smart Contract di **BNB Testnet** dan hubungkan ke Frontend **Next.js**.

**Target:** Mahasiswa mampu submit project ke Web3 Hackathon setelah mengikuti workshop ini.

---

## Struktur Repository

```
campus-ws/
├── smartcontract/    # Foundry project (Solidity) — Token & Vault
├── frontend/         # Next.js app — UI untuk interaksi dengan Smart Contract
└── README.md
```

---

## Persiapan Sebelum Workshop (WAJIB)

Pastikan semua tools sudah terinstall **sebelum hari H**. Jika belum siap, waktu 2 jam workshop akan habis untuk troubleshooting.

### 1. Install WSL (Khusus Windows)

Buka **PowerShell as Administrator**, lalu jalankan:

```powershell
wsl --install
```

> Referensi: [Docs Microsoft WSL](https://learn.microsoft.com/en-us/windows/wsl/install)
>
> **Mac/Linux:** Langkah ini tidak diperlukan.

### 2. Install Foundry (Solidity Framework)

Buka terminal (atau WSL/Git Bash untuk Windows):

```bash
curl -L https://foundry.paradigm.xyz | bash
```

Setelah proses selesai, jalankan:

```bash
foundryup
```

Verifikasi instalasi:

```bash
forge --version
```

> Referensi: [Foundry Book](https://book.getfoundry.sh/)
>
> **Windows:** Pastikan command di atas dijalankan di terminal WSL atau Git Bash, **bukan** CMD/PowerShell biasa.

### 3. Install Node.js (Minimal v18+)

Download dan install dari: [https://nodejs.org](https://nodejs.org) — pilih versi **LTS**.

Verifikasi instalasi:

```bash
node --version   # harus >= 18
npm --version
```

### 4. Install Git

Pastikan Git sudah terinstall:

```bash
git --version
```

Jika belum: [Download Git](https://git-scm.com/downloads)

### 5. Siapkan Wallet & Faucet BNB Testnet

1. Install ekstensi browser **[MetaMask](https://metamask.io/)** atau **[Rabby](https://rabby.io/)**
2. Buat wallet baru (atau gunakan wallet testing — **JANGAN pakai wallet utama**)
3. Tambahkan network **BNB Smart Chain Testnet** di wallet:
   | Field | Value |
   |---|---|
   | Network Name | BNB Smart Chain Testnet |
   | RPC URL | `https://data-seed-prebsc-1-s1.bnbchain.org:8545` |
   | Chain ID | `97` |
   | Currency Symbol | `tBNB` |
   | Block Explorer | `https://testnet.bscscan.com` |
4. Ambil token testnet gratis di: [BNB Testnet Faucet](https://www.bnbchain.org/en/testnet-faucet)

> **Penting:** Simpan Private Key wallet testing kamu. Akan dibutuhkan saat deploy Smart Contract. Sekali lagi, **JANGAN gunakan wallet yang berisi aset asli**.

### Checklist Kesiapan

Sebelum hari H, pastikan semua command berikut berhasil:

```bash
forge --version      # ✅ Foundry terinstall
node --version       # ✅ Node.js >= 18
npm --version        # ✅ npm tersedia
git --version        # ✅ Git terinstall
```

Dan pastikan wallet kamu sudah memiliki tBNB dari faucet.

---

## Rundown Workshop (120 Menit)

### Bagian 1 — Fundamental & Ideasi Hackathon (Menit 0-30)

| Waktu         | Topik                                                                                                                           |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| 00:00 - 00:10 | **Apa itu Blockchain & Smart Contract?** — Blockchain sebagai database terdesentralisasi. Smart Contract sebagai "Code as Law". |
| 00:10 - 00:20 | **Ekosistem Web3, DApps & Gas Fee** — DeFi, DEX, RWA, NFT, ERC20 vs ERC721, dan konsep Gas Fee.                                 |
| 00:20 - 00:30 | **Cara Mencari Ide Hackathon & Intro Solidity** — Framework ideasi: Problem-Driven, Trend, Gap Analysis.                        |

### Bagian 2 — Live Code Smart Contract (Menit 30-90)

#### Step 1: Setup Project Foundry (Sampai Build Berhasil)

```bash
forge init vault-dapp
cd vault-dapp
```

**Install OpenZeppelin Contracts:**

```bash
forge install OpenZeppelin/openzeppelin-contracts
```

**Generate remappings otomatis:**

```bash
forge remappings > remappings.txt
```

> Ini akan otomatis mendeteksi library di `lib/` dan membuat mapping yang benar. Tidak perlu tulis manual.

**Edit `foundry.toml`** — tambahkan solc version, RPC, dan Etherscan config:

```toml
[profile.default]
src = "src"
out = "out"
libs = ["lib"]
solc_version = "0.8.20"

[rpc_endpoints]
bsc_testnet = "${BSC_TESTNET_RPC_URL}"

[etherscan]
bsc_testnet = { key = "${BSCSCAN_API_KEY}", url = "https://api-testnet.bscscan.com/api" }
```

**Setup Environment Variables:**

Copy file `.env.example` menjadi `.env`:

```bash
cp .env.example .env
```

Isi `.env` dengan credential kamu:

```env
# Private key wallet testing (JANGAN pakai wallet utama!)
PRIVATE_KEY=your_private_key_here

# RPC URL BNB Testnet
BSC_TESTNET_RPC_URL=https://data-seed-prebsc-1-s1.bnbchain.org:8545

# BscScan API Key (untuk verifikasi contract di explorer)
# Daftar gratis di: https://bscscan.com/myapikey
BSCSCAN_API_KEY=your_bscscan_api_key_here
```

> **Penting:** File `.env` sudah ada di `.gitignore` secara default. Jangan pernah commit file ini.

**Verifikasi build berhasil:**

```bash
forge build
```

Output yang diharapkan:

```
Compiler run successful!
```

> **Stuck?** Kalau ada error di step manapun, checkout branch checkpoint lalu lanjutkan setup:
>
> ```bash
> git clone https://github.com/yeheskieltame/campus-ws.git
> cd campus-ws
> git checkout 1-setup
> forge install OpenZeppelin/openzeppelin-contracts
> forge remappings > remappings.txt
> cp .env.example .env
> # Edit .env dengan credential kamu
> forge build
> ```

#### Step 2: Buat Token Contract

Buat file `src/CampusToken.sol`:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CampusToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("CampusToken", "CTK") {
        _mint(msg.sender, initialSupply * 10 ** decimals());
    }
}
```

#### Step 3: Buat Vault Contract

Buat file `src/Vault.sol` — konsep "Koperasi Mahasiswa" dimana user bisa setor dan tarik token:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Vault {
    using SafeERC20 for IERC20;

    IERC20 public token;
    mapping(address => uint256) public balances;

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    constructor(address _token) {
        token = IERC20(_token);
    }

    function deposit(uint256 amount) external {
        require(amount > 0, "Amount must be > 0");
        token.safeTransferFrom(msg.sender, address(this), amount);
        balances[msg.sender] += amount;
        emit Deposited(msg.sender, amount);
    }

    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        token.safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }
}
```

#### Step 4: Build & Test

```bash
forge build
```

Buat file test `test/Vault.t.sol`:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/CampusToken.sol";
import "../src/Vault.sol";

contract VaultTest is Test {
    CampusToken token;
    Vault vault;
    address user = address(1);

    function setUp() public {
        token = new CampusToken(1_000_000);
        vault = new Vault(address(token));
        token.transfer(user, 1000 * 10 ** 18);
    }

    function testDeposit() public {
        vm.startPrank(user);
        token.approve(address(vault), 500 * 10 ** 18);
        vault.deposit(500 * 10 ** 18);
        assertEq(vault.balances(user), 500 * 10 ** 18);
        vm.stopPrank();
    }

    function testWithdraw() public {
        vm.startPrank(user);
        token.approve(address(vault), 500 * 10 ** 18);
        vault.deposit(500 * 10 ** 18);
        vault.withdraw(200 * 10 ** 18);
        assertEq(vault.balances(user), 300 * 10 ** 18);
        vm.stopPrank();
    }
}
```

Jalankan test:

```bash
forge test -vvv
```

#### Step 5: Deploy ke BNB Testnet

Buat file `script/Deploy.s.sol`:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/CampusToken.sol";
import "../src/Vault.sol";

contract DeployScript is Script {
    function run() external {
        vm.startBroadcast();

        CampusToken token = new CampusToken(1_000_000);
        Vault vault = new Vault(address(token));

        vm.stopBroadcast();
    }
}
```

Deploy (pastikan `.env` sudah terisi dari Step 1):

```bash
source .env
forge script script/Deploy.s.sol --rpc-url $BSC_TESTNET_RPC_URL --broadcast --private-key $PRIVATE_KEY
```

> **PERINGATAN:** Jangan pernah commit private key ke Git. File `.env` sudah ada di `.gitignore` secara default.
>
> **Stuck?** Checkout branch checkpoint:
>
> ```bash
> git checkout 4-deploy
> ```

Setelah deploy berhasil, catat **Contract Address** dari output. Kamu akan butuh ini untuk frontend.

Cek contract kamu di: `https://testnet.bscscan.com/address/<CONTRACT_ADDRESS>`

### Bagian 3 — Live Code Frontend (Menit 90-120)

#### Step 6: Setup Frontend Next.js

```bash
npx create-next-app@latest frontend
cd frontend
npm install ethers
```

> **Shortcut:** Untuk menghemat waktu, clone starter template:
>
> ```bash
> git clone <repo-starter-frontend> frontend
> cd frontend
> npm install
> ```

#### Step 7: Konfigurasi ABI & Contract Address

Setelah `forge build`, ABI ada di `vault-dapp/out/Vault.sol/Vault.json`.

Copy ABI ke frontend project, lalu buat config file `frontend/src/config/contracts.ts`:

```typescript
export const VAULT_ADDRESS = "<ADDRESS_VAULT_DARI_DEPLOY>";
export const TOKEN_ADDRESS = "<ADDRESS_TOKEN_DARI_DEPLOY>";

export const VAULT_ABI = [
  // Paste ABI dari out/Vault.sol/Vault.json
] as const;

export const TOKEN_ABI = [
  // Paste ABI dari out/CampusToken.sol/CampusToken.json
] as const;
```

#### Step 8: Integrasi Tombol Deposit & Withdraw

Buat komponen utama yang menghubungkan UI ke Smart Contract menggunakan `ethers.js`:

```typescript
import { ethers } from "ethers";
import {
  VAULT_ADDRESS,
  VAULT_ABI,
  TOKEN_ADDRESS,
  TOKEN_ABI,
} from "@/config/contracts";

async function connectWallet() {
  if (!window.ethereum) {
    alert("Install MetaMask!");
    return;
  }
  const provider = new ethers.BrowserProvider(window.ethereum);
  const signer = await provider.getSigner();
  return signer;
}

async function deposit(amount: string) {
  const signer = await connectWallet();
  if (!signer) return;

  // Approve token dulu
  const tokenContract = new ethers.Contract(TOKEN_ADDRESS, TOKEN_ABI, signer);
  const parsedAmount = ethers.parseEther(amount);
  await (await tokenContract.approve(VAULT_ADDRESS, parsedAmount)).wait();

  // Lalu deposit
  const vaultContract = new ethers.Contract(VAULT_ADDRESS, VAULT_ABI, signer);
  await (await vaultContract.deposit(parsedAmount)).wait();
}

async function withdraw(amount: string) {
  const signer = await connectWallet();
  if (!signer) return;

  const vaultContract = new ethers.Contract(VAULT_ADDRESS, VAULT_ABI, signer);
  const parsedAmount = ethers.parseEther(amount);
  await (await vaultContract.withdraw(parsedAmount)).wait();
}
```

> Detail lengkap implementasi UI ada di folder `frontend/`.

---

## Sistem Checkpoint (Kalau Tertinggal)

Jangan panik kalau tertinggal! Gunakan branch checkpoint untuk langsung menyusul:

| Branch               | Deskripsi                                     |
| -------------------- | --------------------------------------------- |
| `1-setup`            | Project Foundry sudah ter-init + config       |
| `2-addContractToken` | Smart Contract Token (ERC20) sudah lengkap    |
| `3-addContractVault` | Smart Contract Vault sudah lengkap            |
| `4-deploy`           | Deploy script siap + contract ter-deploy      |
| `5-frontend`         | Frontend starter sudah terhubung              |

```bash
git checkout <nama-branch>
```

---

## Setelah Workshop

### Langkah Selanjutnya Menuju Hackathon

1. **Kembangkan ide** — Pikirkan masalah nyata di kampus/kehidupan yang bisa diselesaikan dengan Smart Contract
2. **Iterasi Smart Contract** — Tambahkan fitur (staking rewards, governance voting, dll)
3. **Polish Frontend** — Buat UI yang user-friendly
4. **Siapkan Pitch Deck** — Jelaskan problem, solution, dan tech stack
5. **Submit ke Hackathon!**

### Butuh Bantuan?

- Tanya di grup Discord kampus kamu (DevRel akan merespon maks 4 jam di jam kerja)
- Join mentoring session H+3 setelah workshop
- Ikut sesi "Pitch & Review" H-7 sebelum deadline hackathon

---

## Tech Stack

| Layer          | Teknologi                 |
| -------------- | ------------------------- |
| Smart Contract | Solidity + Foundry        |
| Blockchain     | BNB Smart Chain (Testnet) |
| Frontend       | Next.js + ethers.js       |
| Wallet         | MetaMask / Rabby          |

---

## Resources

- [Foundry Book](https://book.getfoundry.sh/)
- [Solidity Docs](https://docs.soliditylang.org/)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/)
- [BNB Chain Docs](https://docs.bnbchain.org/)
- [Ethers.js Docs](https://docs.ethers.org/v6/)

---

**Happy Building! 🚀**

_Workshop oleh Coinvestasi x Dev Web3 Jogja_
