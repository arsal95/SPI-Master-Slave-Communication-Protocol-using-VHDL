# SPI-Master-Slave-Communication-Protocol-using-VHDL

## Objective:
VHDL program to perform a Serial data transmission and reception using SPI master and slave. Data sent from the master should be received by the slave and vice-versa. The program logic has to be verified by simulation.

## Introduction:
SPI (Serial peripheral interface) is a synchronous serial communication interface specification used for short-distance communication. Here single master and slave is used. SPI protocol is full duplex, which means the Mater can send data to the slave at the same time slave can also send data to the master. A standard SPI Master Communication Protocol bus consists of 4 signals, Master Out Slave In (MOSI), Master In Slave Out (MISO), the Clock (SCLK), and Chip Select (CSq) or Slave Select (SS).

| <img src="./Images/SPI Bus.JPG"> |
|:--:| 
| *Fig 1: SPI Bus* |

To begin communication, the master configures the clock, the master then selects the slave device with a logic level 0 on the select line. During each SPI clock cycle, a full-duplex data transmission occurs. The master sends a bit on the MOSI line and the slave reads it, while the slave sends a bit on the MISO line and the master reads it. This sequence is maintained even when only one-directional data transfer is intended. Data is usually shifted out with the most significant bit first. On the clock edge, both master and slave shift out a bit and output it on the transmission line to the counterpart. On the next clock edge, at each receiver the bit is sampled from the transmission line and set as a new least-significant bit of the shift register. After the register bits have been shifted out and in, the master and slave have exchanged register values.

| <img src="./Images/SPI Communication.JPG"> |
|:--:| 
| *Fig 2: SPI Communication* |

## Algorithm Description:
First, we define all the necessary signals for master and slave. We are reducing the clock frequency by using a counter, which will generate new reference frequency which will go high of 3 clock period. We perform our operation based on this new reference frequency. Then the data sent from master will be received by slave after certain clock period.

### State Diagram
The state diagrams for Master and Slave are given below.
* The SPI protocol has been implemented by the finite state machine with total 7 number of states for master and 11 states for slave.
* The state machine is synchronized with ‘sclk’ and triggered with input signals ‘resetn’ and 'start'.

| <img src="./Images/Master State Machine.JPG"> |
|:--:| 
| *Fig 3: SPI Master State Machine* |

| <img src="./Images/Slave State Machine.JPG"> |
|:--:| 
| *Fig 4: SPI Master State Machine* |

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

The signals ‘wr_buf, rd_buf’ in master and ‘sdi_buffer, sdo_buffer’ in slave are used as buffer elements for the operation of data in the state machine.

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
* State transition conditions are built in the combinational block of the state machine Fig 3 and Fig 4.
* Default values for outputs and m_next_state or s_next_state are initialized so that unwanted latches are not synthesized in the hardware.
* State transitions are implemented as CASE statements, where we define what should happen in that particular state as in a state machine.
* Transition to sidle will take place when resetn = '0'. And, when start = ‘1’ the state machine will move to sstartx and it will continue the all states. This logic will make endless state transitions unless resetn = ‘0’ or done =’1’.
* Similarly, for slave transition to idle will take place when resetn = '0'. When done = ‘1’ and slcsq = ‘0’ the state machine will move to csstart and it will continue the all states for change in ‘slcsq’.
* Since the process is reading the values of state, start, count, and wr_buf are essential to define it in the sensitivity list of process.

## Simulation and Output Waveform
The output waveform of the SPI Master/Slave protocol is shown in Fig 5.

| <img src="./Simulation/Output Waveform.JPG"> |
|:--:| 
| *Fig 5: Output Waveform* |

At the beginning, the reset is 1 and as ‘start’ signal will become ‘1’ indicating starting of new transmission and ‘done_master’ will go to ‘0’. Fig.5. At the same time the state of the master changes from ‘sidle’ to ‘sstart’.

To perform transmission to slave ‘scsq’ chip select should be ‘0’. As soon as this happens on the next falling edge of ‘spi_clkp’, the synchronous clock will start ‘sclk’ and the data to be transferred will be sent to ‘mosi’ and for each bit transferred the counter will decrement and state of the state machines changes.

Similarly in slave once the ‘slscq’ goes to ‘0’on the next rising edge of ‘bclk’, done_slave goes to ‘0’ and the transition of state starts ‘csstart’. And the data to be sent to the master will in ‘slsdo’.

All the bits received by the Master and slave are left-shifted because MSB will be sent out first as shown in Fig 7.

Once all the bits are received the ‘master_done’ and ‘slave_done’ signals go to ‘1’ and ‘scsq’ and ‘slcsq’ also go to ‘1’ indicating the end of the transmission and reception as shown in Fig 7. The state of the Master and Slave changes to ‘sidle’ and ‘idle’ respectively.


| <img src="./Simulation/Beginning of Transmission.JPG"> |
|:--:| 
| *Fig 6: Beginning of Transmission.JPG* |


| <img src="./Simulation/End of Transmission.JPG"> |
|:--:| 
| *Fig 7: End of Transmission.JPG* |

## Conclusion:
We have implemented a logic in VHDL to send data using the SPI protocol. Both Master and Slave can send and receive data from one another.
* On the start signal both Master and slave start sending out the data in serial form with MSB sent out first.
* After bit-by-bit transmission of the data in synchronous with the clock, both master and slave will exchange data.
* At the end of transmission, the data sent from the Master is received by the slave and vice-versa, which is verified in the output waveform Fig 5. The state of the master and slave change to idle and the done signal will go to high as shown in Fig 7, indicating transmission is completed.

Thank you for visiting my account. :slightly_smiling_face: 
