# FPGA-Smart-Safe
Project Overview
This project implements a Secure Digital Safe System on an Altera Cyclone III FPGA. The system manages a virtual vault with a locking mechanism controlled via a state machine (FSM).

To make the system interactive and modern, it uses the UART (Universal Asynchronous Receiver-Transmitter) protocol to communicate with an external terminal (such as a Smartphone or PC). This allows the user to input passwords and receive status updates (e.g., "Access Granted", "Locked") directly on their device screen.
קבימןבשך 
Technical Specifications
FPGA: Altera Cyclone III (EP3C16F484C6).
Language: VHDL.
Baude Rate: 9600 bps.
Clock Frequency: 50 MHz.

Architecture:
The system is divided into three main modules:
1. UART_RX: Samples the serial input line and converts serial bits into 8-bit data bytes.
2. Safe_Logic: The core controller that compares user input to the stored password and manages security states.
3. UART_TX: Sends status messages back to the user terminal.
