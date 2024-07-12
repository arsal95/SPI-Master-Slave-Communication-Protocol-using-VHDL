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

### Entity Block:
This contains the port definition with the signals. It allows you to create a hierarchy in the design. The entity syntax is the keyword “entity”, followed by the entity name and the keywords “is” and “port”. Inside the parenthesis, ports are declared.

This interface consists of the following input and output ports for Master:’spims’
* resetn: reset input
* bclk: clock input for SPI Master.
* spi_clkp: clock pulse input to the SPI Master. (used to slow down operations)
* start: used as an input triggering signal to start SPI communication.
* done: used to check the transmission is completed from SPI master.
* scsq: used to transmit out the chip select status to SPI Slave.
* sclk: used to transmit out the SPI clock signal to SPI Slave.
* sdo: used to transmit out the serial data to SPI Slave.
* sdi: used to receive in the serial data from SPI Slave.
* senddata: To send data to Slave
* recvdata: receive data from Slave

The slave interface consists of the following input and output ports: ‘spisl’
* uspi_size: Generic type integer of 16 - bits
*  resetn: reset input
*  bclk: clock input for SPI Master.
*  one: used to check the transmission is completed from SPI Slave.
*  slcsq: used to transmit out the chip select status to SPI Master.
*  slsclk: used to transmit out the SPI clock signal to SPI Slave.
*  slsdo: used to transmit out the serial data to SPI Slave
*  slsdi: used to receive in the serial data from SPI Slave
*  slsnddata: To send data to Master
*  slrecvdata: receive data from Master

## Architecture Block:
Architecture block is used to describe the organization of the design entity. Architecture body is used to describe the behavior, data flow, or structure of a design entity.

* A new datatype State_type defines the various states for the state machine i.e. ‘sidle, sstartx, sstart_lo, sclk_hi, sclk_lo, sstop_hi, sstop_lo’ for SPI master.
* A new datatype State_type defines the various states for the state machine i.e ‘idle, csstart, starthi_s, starthi, startlo_s, startlo,clkhi_s, clkhi, clklo_s,clklo, leadout’ for SPI slave.

The signals ‘wr_buf, rd_buf’ in master and ‘sdi_buffer, sdo_buffer’ in slave are used as buffer element for operation of data in state machine

### Here architecture block consists of 3 processes:

#### 1. Process to slow down the operation: ‘clk_p’
* Since the simulation is very fast, we will not be able to see all the transition states, Hence, we have to reduce the clock frequency to a lower value which will generate 1 new clock pulse for 3 original clock pulses.
* To achieve this, we will define a constant ‘clk_div’ and a counter clkd_cnt, we will reduce the counter for each clock pulse, when every time the counter reaches ‘0’, this will generate one new clock pulse.

#### 2. Process to update sequential logic: ‘seq_p’(for master) and ‘slseq’(for slave)
* On the rising edge of the clock, state and scsq, sclk, sdo, sdi are updated.
* If resetn goes to '0' then the state will be changed to “sidle" state.
* When spi_clkp becomes '1', storing of the next state also takes place along with sequential logic is updated.
* The process contains ‘bclk’ in the sensitivity list.
* For every rising edge of the clock, the transmission of bits takes place from MSB to LSB.
* Similarly, in slave, if ‘resetn’ is equal to ‘0’ then all the sequential operations will take place.

#### 3. Process to define state transition:’cmb_p’(for master) and ‘slcmb’(For slave)
* State transition conditions are built in the combinational block of the state machine.Fig.1 and Fig.2.
* Default values for outputs and m_next_state or s_next_state are initialized so that unwanted latches are not synthesized in the hardware.
* State transitions are implemented as CASE statements, where we define what should happen in that particular state as in a state machine.
* Transition to sidle will take place when resetn = '0'. And, when start = ‘1’ the state machine will move to sstartx and it will continue the all states. This logic will make endless state transitions unless resetn = ‘0’ or done =’1’.
* Similarly, for slave transition to idle will take place when resetn = '0'. When done = ‘1’ and slcsq = ‘0’ the state machine will move to csstart and it will continue the all states for change in ‘slcsq’.
* Since the process is reading the values of state, start, count, and wr_buf are essential to define it in the sensitivity list of process.




| <img src="./Simulation/Output Waveform.JPG"> |
|:--:| 
| *Output Waveform* |


| <img src="./Simulation/Beginning of Transmission.JPG"> |
|:--:| 
| *Beginning of Transmission.JPG* |


| <img src="./Simulation/End of Transmission.JPG"> |
|:--:| 
| *End of Transmission.JPG* |

