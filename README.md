# SPI-Master-Slave-Communication-Protocol-using-VHDL

## Objective:
VHDL program to perform a Serial data transmission and reception using SPI master and slave. Data sent from the master should be received by the slave and vice-versa. The program logic has to be verified by simulation.

## Introduction:
SPI is a very common communication protocol used for two-way communication between two devices. A standard SPI Master Communication Protocol bus consists of 4 signals, Master Out Slave In (MOSI), Master In Slave Out (MISO), the Clock (SCLK), and Chip Select (CSq) or Slave Select (SS).

| <img src="./Images/SPI Bus.JPG"> |
|:--:| 
| *SPI Bus* |

To begin communication, the master configures the clock, the master then selects the slave device with a logic level 0 on the select line. During each SPI clock cycle, a full-duplex data transmission occurs. The master sends a bit on the MOSI line and the slave reads it, while the slave sends a bit on the MISO line and the master reads it. This sequence is maintained even when only one-directional data transfer is intended. Data is usually shifted out with the most significant bit first. On the clock edge, both master and slave shift out a bit and output it on the transmission line to the counterpart. On the next clock edge, at each receiver the bit is sampled from the transmission line and set as a new least-significant bit of the shift register. After the register bits have been shifted out and in, the master and slave have exchanged register values.

| <img src="./Images/SPI Communication.JPG"> |
|:--:| 
| *SPI Communication* |

## Algorithm Description:
First, we define all the necessary signals for master and slave. We are reducing the clock frequency by using a counter, which will generate new reference frequency which will go high of 3 clock period. We perform our operation based on this new reference frequency. Then the data sent from master will be received by slave after certain clock period.

### State Diagram
The state diagram for Master and Slave is as shown below.
* The SPI protocol has been implemented by the finite state machine with total 7 number of states.
* The state machine is synchronized with ‘sclk’ and triggered with input signals ‘resetn’ and start.

| <img src="./Images/Master State Machine.JPG"> |
|:--:| 
| *SPI Master State Machine* |

| <img src="./Images/Slave State Machine.JPG"> |
|:--:| 
| *SPI Master State Machine* |

## VHDL Code Explanation:

### Library
* Using the “use” statement, all components of the package “STD_LOGIC_1164” part of the library IEEE is visible for later use in the VHDL code. The “Library” statement is included above “use” statement so that the compiler would know that “IEEE” is a library.
* VHDL datatype “STD_LOGIC” is declared in ieee.std_logic_1164, and so a “use” at the top of the file makes the datatype visible for later reuse.

| <img src="./Simulation/Output Waveform.JPG"> |
|:--:| 
| *Output Waveform* |


| <img src="./Simulation/Beginning of Transmission.JPG"> |
|:--:| 
| *Beginning of Transmission.JPG* |


| <img src="./Simulation/End of Transmission.JPG"> |
|:--:| 
| *End of Transmission.JPG* |

