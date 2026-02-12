**Available Languages:** [English](README.md) | [Türkçe](README_TR.md)

# 🔐 FPGA-Based Hardware Cryptographic Engine (Educational)

![Status](https://img.shields.io/badge/Status-Completed-success)
![Tech](https://img.shields.io/badge/Language-VHDL-blue)
![Board](https://img.shields.io/badge/Hardware-Basys3-orange)
![Project Type](https://img.shields.io/badge/Project_Type-Academic_Research-yellow)
![Security_Level](https://img.shields.io/badge/Security-Educational_Proof_of_Concept-red)

---

## Overview

This project focuses on the FPGA-based implementation of custom cryptographic primitives. The primary goal was to research the basic principle behind modern day data encryption and decryption.

By mapping execution from software models to the Artix-7 FPGA fabric, this project demonstrates the principles of hardware acceleration, pipeline parallelism, and real-time clock synchronization in cryptographic systems.

---

## Key Engineering Features

* **Hybrid Cryptographic Architecture**
  * Combines a Linear Feedback Shift Register (LFSR) for pseudo-random stream generation with a Feistel Block Network to demonstrate structural encryption principles.
* **Non-Linear Key Generation**
  * Implements a custom 7-bit NLFSR with Boolean Mixing Functions (AND/XOR) to increase algebraic complexity and resist simple linear analysis.
* **Reversible Logic Core**
  * Leveraged the Feistel property ($A \oplus B \oplus B = A$) to utilize the exact same hardware logic gate array for both encryption and decryption modes.

---

## System Architecture
*The UART interface is used solely as a test and validation input mechanism and is not part of the cryptographic design itself.*

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

## Technical Implementation Details

#### 1. The Feistel Network (Diffusion)
To allow for complex, non-reversible mixing functions while maintaining the ability to decrypt, I implemented a Feistel structure.
* **The Logic:**
  $$Target_{new} = Target_{old} \oplus F(Anchor, Key)$$
  $$Anchor_{new} = Anchor_{old}$$
* **Hardware Efficiency:** Since the `Anchor` is preserved, the decryption module simply re-applies the same operation. This reduced the required FPGA LUT (Look-Up Table) usage by approx. 40% compared to separate Encrypt/Decrypt circuits.

#### 2. Non-Linear Feedback Shift Register (Confusion)
Standard LFSRs are vulnerable to linear algebra attacks. I upgraded the key generator to an NLFSR.
* **The Upgrade:** Instead of simple XOR taps, I introduced AND/OR gates into the feedback loop.
* **Mathematical Consequence:** This increases the linear complexity of the keystream, making the cipher significantly harder to predict without knowing the initial seed state.

---

## Design Evolution

This project was developed through an iterative engineering process, moving from theoretical logic to physical hardware implementation.

| Phase | Architecture | Key Engineering Milestone |
| :--- | :--- | :--- |
| **I** | **Linear Stream** | Validated basic XOR encryption using a 4-bit Linear Feedback Shift Register (LFSR). |
| **II** | **Permutation** | Introduced a P-Box (Permutation Layer) to shuffle bit positions and break spatial correlation. |
| **III** | **ASCII Scale-Up** | Expanded bus width to 7-bit to support full text encryption; added keyboard buffering. |
| **IV** | **Non-Linear Core** | Replaced the linear generator with an NLFSR to resist linear cryptanalysis. |
| **V** | **Feistel Net** | Migrated to a Feistel Block Architecture, allowing for complex non-invertible mixing functions. |
| **VI** | **FPGA Port** | Synthesized the design to VHDL, integrated UART, and implemented Display Multiplexing. |

---

## Hardware Pinout (Basys 3)

| Component | Signal Name | FPGA Pin | Description |
| :--- | :--- | :--- | :--- |
| **System** | `CLK` | W5 | 100 MHz Onboard Clock |
| **UART RX** | `RsRx` | B18 | Serial Data Input (from USB) |
| **UART TX** | `RsTx` | A18 | Serial Data Output (to USB) |
| **LEDs** | `led[0-6]` | U16...U19 | Binary Ciphertext Visualization |
| **7-Seg Anode** | `an[0-3]` | U2...W4 | Digit Select (Active Low) |
| **7-Seg Cathode** | `seg[0-6]` | W7...U7 | Segment Data (A-G) |

---

**Disclaimer:** This project is a hardware implementation study of cryptographic primitives designed for educational and research purposes. While it demonstrates the logic of Non-Linear Feedback Shift Registers (NLFSR) and Feistel Networks, it has not been audited for production-level security.

---

## 🎥 Demonstration
![Comp 1](https://github.com/user-attachments/assets/81680fa6-209f-497b-b98d-d26a630c2d0d)

![Comp 2](https://github.com/user-attachments/assets/718df52b-36e7-4e34-ab30-cfd52f78b724)


---
