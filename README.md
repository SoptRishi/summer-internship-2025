# QKD and Quantum Sensing 
### Research Internship | IIT Bombay (May 2025 – July 2025)

This repository contains simulations, experimental data analysis, and documentation for two distinct research projects conducted  at IIT Bombay. The projects focus on Quantum Key Distribution (QKD) implementations and Bayesian Signal Enhancement for quantum sensing.

---

## Table of Contents
1. [Project I: Experimental Quantum Cryptography (BB84 Protocol)](#project-i-experimental-quantum-cryptography-bb84-protocol)
2. [Project II: Bayesian Photon Number Resolving for EMCCD Cameras](#project-ii-bayesian-photon-number-resolving-for-emccd-cameras)
3. [Skills & Tools](#skills--tools)

---

## Project I: Experimental Quantum Cryptography (BB84 Protocol)

### Overview
This project involved the setup, simulation, and analysis of quantum cryptography protocols using a Thorlabs Quantum Cryptography Demonstration Kit. The primary objective was to demonstrate secure key distribution using light polarization and experimentally validate the security of the BB84 protocol in the presence of an eavesdropper. My responsibility was to set up the experiment and simulation of BB84, rest of two protocol B92 and E91 was implemented by my partner.


### Key Implementations

#### 1. BB84 Protocol (Experimental & Simulation)
**Experimental Setup:** Built a demonstration kit using Polarizing Beam Splitters and Half-Wave Plates to encode and decode classical bits into polarization states.
* **Protocol Execution:**
    * Implemented the standard four-state protocol using rectilinear ($0^\circ, 90^\circ$) and diagonal ($45^\circ, -45^\circ$) polarization bases.
    * Executed the public channel comparison where Alice and Bob discard bits measured in mismatched bases.
    * Implemented `BB84 Simulation.ipynb` to model the protocol numerically and verify theoretical outcomes.
* **Security Analysis:**
  **Eavesdropping Detection:** Demonstrated that an intercept-resend attack by Eve introduces a detectable error rate of ~25% in the quantum bit error rate (QBER), forcing the protocol to abort.

#### 2. Theoretical Analysis (B92 & E91)
* **B92 Protocol:** Conducted a theoretical trade-off analysis comparing BB84 to B92. While B92 requires fewer states (two non-orthogonal), it was found to generate fewer usable keys due to higher discard rates inherent to its angular dependencies.
* **E91 (Ekert) Protocol:** Analyzed entanglement-based security, studying how Bell’s inequality violations can certify the absence of an eavesdropper, shifting the trust model from the source to the channel statistics.

### Experimental Data
The repository includes data derived from the optical setup:

* **No Eavesdropper Scenario:**
    * *Raw Key Length:* 31 bits (from 50 transmitted).
    * *Result:* Perfect decryption of the word "BLUE".
* **With Eavesdropper Scenario:**
    * *Error Rate:* Observed **22.72%** error rate (close to the theoretical 25%), successfully flagging the intrusion.
    * Result: Decryption failed completely (outputting "I?RH" instead of "BLUE").

---

## Project II: Bayesian Photon Number Resolving for EMCCD Cameras

### Overview
This module contains a MATLAB implementation of a Bayesian photon-number-resolving algorithm for Electron Multiplying Charge Coupled Device (EMCCD) cameras.
The project reproduces the methodology described in *Chatterjee et al. (2024).*, demonstrating how statistical inference can recover multi-photon events from noisy analog signals. By resolving discrete photon numbers ($n=0, 1, 2, 3...$) rather than using a standard binary threshold, this method significantly enhances the Signal to Noise Ratio (SNR) for applications involving Nitrogen Vacancy (NV) centers.

### Key Features
* **Virtual EMCCD Simulator:** Generates synthetic raw data simulating Poissonian photon statistics, stochastic gain (Gamma distribution), Clock Induced Charge (CIC), and Gaussian readout noise.
* **Bayesian Thresholding:** Calculates pixel-wise probability thresholds to distinguish between $k$ and $k+1$ photons based on local beam intensity.
* **SNR Enhancement:** Demonstrates a significant improvement in contrast for spatially correlated photon beams compared to standard binary counting.
* **Robustness Analysis:** Characterizes algorithm performance across different EMCCD gain settings.
* **Quantum Sensing Application:** Simulates high-flux Optically Detected Magnetic Resonance (ODMR) experiments to showcase sensitivity gains in NV centers.

### Module Structure
The MATLAB scripts are organized into five logical modules:

1.  **`1_Data_Generation.m`**
    * Simulates the physical EMCCD camera and generates a stack of raw analog frames from a Gaussian beam profile.
    * *Output:* `emccd_stack` (Raw 3D data matrix).

2.  **`2_Threshold_Calibration.m`**
    * Performs Bayesian inversion to generate a Threshold Map for the entire image. It calculates the optimal count boundaries for detecting 0, 1, 2, or 3 photons at every pixel.
    * *Output:* `threshold_map_stack` (Map of T1, T2, T3 thresholds).

3.  **`3_Photon_Tagging_SNR.m`**
    * Applies the threshold map to the raw data to tag discrete photons.
    * Compares the SNR of the new Resolved Method vs. the standard Binary Method.
    * *Output:* SNR metrics and improvement factor.

4.  **`4_Robustness_Study.m`** *(Standalone)*
    * Performs a parameter sweep (SNR vs EMCCD Gain) to determine the minimum experimental gain required for effective photon resolution.
    * *Output:* Plot of Improvement Factor vs. Gain.

5.  **`5_NV_Center_ODMR.m`** *(Standalone)*
    * Simulates an ODMR frequency sweep for an NV center in the high-flux (saturation) regime.
    * Demonstrates how resolving multi-photon events prevents signal saturation and recovers the true depth of the magnetic resonance dip.
    * *Output:* ODMR spectrum plot and Sensitivity Gain metric.

### Physics & References
This work relies on the statistical model where the output count $x$ for $k$ input electrons follows a Gamma distribution convolved with Gaussian readout noise:

$$P(x|k) = \frac{x^{k-1} e^{-x/G}}{G^k (k-1)!} * \mathcal{N}(0, \sigma_N^2)$$

* **Reference:** Chatterjee, R., Bhat, V. S., Bajar, K., & Mujumdar, S. (2024). *Multifold enhancement of quantum SNR by using an EMCCD as a photon number resolving device*. arXiv:2312.04184.

---

## Skills & Tools
* **Programming:** MATLAB (Numerical Simulations), Python (Data Analysis).
* **Hardware:** Thorlabs Quantum Cryptography Kit, Polarizing Beam Splitters, Half-Wave Plates.
* **Concepts:** Quantum Key Distribution (BB84/B92/E91), Bayesian Inference, NV Centers, Signal to Noise Ratio (SNR) Optimization.

---


*Email: saptarshi.das090@gmail.com
