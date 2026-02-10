# 🔐 FPGA-Based Hardware Cryptographic Engine

![Status](https://img.shields.io/badge/Status-Completed-success)
![Tech](https://img.shields.io/badge/Language-VHDL-blue)
![Board](https://img.shields.io/badge/Hardware-Basys3-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## 📌 Overview

This project is a high-speed, hardware-accelerated cryptographic engine implemented on the **Artix-7 FPGA**. It features a hybrid architecture that combines a **Non-Linear Feedback Shift Register (NLFSR)** for high-entropy key generation with a **Feistel Network** for reversible data permutation.

Unlike software-based encryption that consumes CPU cycles, this design performs encryption and decryption in real-time at the hardware level. It integrates an asynchronous **UART interface** for data ingestion and a custom **Time-Division Multiplexing (TDM)** driver for visualizing encrypted telemetry on 7-segment displays.

---

## 🛠️ Key Engineering Features

* **🛡️ Hybrid Cryptographic Architecture**
  * Combines the speed of a Stream Cipher with the structural integrity of a Block Cipher using an Unbalanced Feistel Network.
* **🎲 Non-Linear Key Generation**
  * Utilizes a 7-bit **NLFSR** (Non-Linear Feedback Shift Register) with Boolean mixing functions to mitigate linear cryptanalysis attacks (e.g., Berlekamp-Massey).
* **⚡ Asynchronous Clock Synchronization**
  * Implements explicit clock-gating and buffering to safely synchronize 9600-baud asynchronous UART data with the 100MHz system clock domain.
* **👁️ Multiplexed Telemetry Display**
  * A custom hardware driver that uses **Time-Division Multiplexing** to display Hexadecimal ciphertext on 7-segment displays using a single shared bus.
* **🔄 Reversible Logic Core**
  * Leverages the Feistel property ($A \oplus B \oplus B = A$) to use the exact same hardware logic gate array for both encryption and decryption modes.

---

## ⚙️ System Architecture

The system operates as a continuous pipelined data path:

### 1. Input Interface (`UART_RX`)
* **Protocol:** Standard RS-232 Serial (9600 Baud, 8N1).
* **Function:** Captures serial data from a PC/Keyboard and frames it into parallel 8-bit bytes.
* **Sync:** Generates a "Data Valid" pulse to trigger the encryption core for exactly one clock cycle.

### 2. The Core Engine (`Top_Level.vhd`)
* **Key Gen:** An NLFSR advances its state based on a non-linear feedback polynomial.
* **Split:** The 7-bit ASCII input is split into "Anchor" (3 bits) and "Target" (4 bits) segments.
* **Mix:** The Anchor and Key are fed into a boolean mixing function; the result is XORed with the Target.

### 3. Output Visualization (`TDM_Driver`)
* **Technique:** Persistence of Vision.
* **Mechanism:** A refresh timer cycles through the 4 digit anodes at 250Hz, creating the illusion that all displays are active simultaneously while reducing power and pin usage.

---

## 💻 Technical Implementation Details

#### 1. The Feistel Network (Diffusion)
To allow for complex, non-reversible mixing functions while maintaining the ability to decrypt, I implemented a Feistel structure.
* **The Logic:**
  $$Target_{new} = Target_{old} \oplus F(Anchor, Key)$$
  $$Anchor_{new} = Anchor_{old}$$
* **Hardware Efficiency:** Since the `Anchor` is preserved, the decryption module simply re-applies the same operation. This reduced the required FPGA LUT (Look-Up Table) usage by approx. 40% compared to separate Encrypt/Decrypt circuits.

#### 2. Non-Linear Feedback Shift Register (Confusion)
Standard LFSRs are vulnerable to linear algebra attacks. I upgraded the key generator to an NLFSR.
* **The Upgrade:** Instead of simple XOR taps, I introduced **AND/OR gates** into the feedback loop.
* **Mathematical Consequence:** This increases the linear complexity of the keystream, making the cipher significantly harder to predict without knowing the initial seed state.

#### 3. Hardware-Level Synchronization
The project involves crossing clock domains (Async Serial $\to$ Sync FPGA).
* **Solution:** I implemented a "Data Valid" flag system. The internal state machine remains idle until the UART module asserts `o_RX_DV`. The encryption logic then executes in a single 100MHz clock cycle, ensuring no data is dropped or processed twice.

---

## 📈 Design Evolution

This project was developed through an iterative engineering process, moving from theoretical logic to physical hardware implementation.

| Phase | Architecture | Key Engineering Milestone |
| :--- | :--- | :--- |
| **I** | **Linear Stream** | Validated basic XOR encryption using a 4-bit Linear Feedback Shift Register (LFSR). |
| **II** | **Permutation** | Introduced a **P-Box** (Permutation Layer) to shuffle bit positions and break spatial correlation. |
| **III** | **ASCII Scale-Up** | Expanded bus width to **7-bit** to support full text encryption; added keyboard buffering. |
| **IV** | **Non-Linear Core** | Replaced the linear generator with an **NLFSR** to resist linear cryptanalysis. |
| **V** | **Feistel Net** | Migrated to a **Feistel Block Architecture**, allowing for complex non-invertible mixing functions. |
| **VI** | **FPGA Port** | Synthesized the design to **VHDL**, integrated **UART**, and implemented **Display Multiplexing**. |

---

## 🔌 Hardware Pinout (Basys 3)

| Component | Signal Name | FPGA Pin | Description |
| :--- | :--- | :--- | :--- |
| **System** | `CLK` | W5 | 100 MHz Onboard Clock |
| **UART RX** | `RsRx` | B18 | Serial Data Input (from USB) |
| **UART TX** | `RsTx` | A18 | Serial Data Output (to USB) |
| **LEDs** | `led[0-6]` | U16...U19 | Binary Ciphertext Visualization |
| **7-Seg Anode** | `an[0-3]` | U2...W4 | Digit Select (Active Low) |
| **7-Seg Cathode** | `seg[0-6]` | W7...U7 | Segment Data (A-G) |

---

## 🎥 Demonstration

[Insert a link to your demonstration video or GIF here]