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

#### Step 1: Setup Project Foundry

```bash
forge init vault-dapp
cd vault-dapp
```

> **Stuck?** Kalau `forge init` gagal, clone repo ini dan checkout branch yang sesuai:
>
> ```bash
> git clone <repo-url>
> git checkout 1-setup
> ```

Edit `foundry.toml`, tambahkan RPC BNB Testnet:

```toml
[rpc_endpoints]
bsc_testnet = "https://data-seed-prebsc-1-s1.bnbchain.org:8545"
```

#### Step 2: Install OpenZeppelin Contracts

```bash
forge install OpenZeppelin/openzeppelin-contracts --no-commit
```

Buat file `remappings.txt`:

```
@openzeppelin/=lib/openzeppelin-contracts/
```

#### Step 3: Buat Token Contract

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

#### Step 4: Buat Vault Contract

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

#### Step 5: Build & Test

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

#### Step 6: Deploy ke BNB Testnet

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

Deploy:

```bash
forge script script/Deploy.s.sol --rpc-url bsc_testnet --broadcast --private-key <PRIVATE_KEY_KAMU>
```

> **PERINGATAN:** Jangan pernah commit private key ke Git. Gunakan `.env` + `--private-key` dari environment variable untuk keamanan.
>
> **Stuck?** Checkout branch checkpoint:
>
> ```bash
> git checkout 3-deploy
> ```

Setelah deploy berhasil, catat **Contract Address** dari output. Kamu akan butuh ini untuk frontend.

Cek contract kamu di: `https://testnet.bscscan.com/address/<CONTRACT_ADDRESS>`

### Bagian 3 — Live Code Frontend (Menit 90-120)

#### Step 7: Setup Frontend Next.js

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

#### Step 8: Konfigurasi ABI & Contract Address

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

#### Step 9: Integrasi Tombol Deposit & Withdraw

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

| Branch        | Deskripsi                                  |
| ------------- | ------------------------------------------ |
| `1-setup`     | Project Foundry sudah ter-init + config    |
| `2-contracts` | Smart Contract Token & Vault sudah lengkap |
| `3-deploy`    | Contract sudah siap deploy + script        |
| `4-frontend`  | Frontend starter sudah terhubung           |

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
