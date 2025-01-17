----------------------------------------------------------------------------------
-- Company:         Univ. Bremerhaven
-- Engineer:        Arsal Abbas
-- Create Date:     20.06.2022
-- Description:     SPI Master/Slave test bench
----------------------------------------------------------------------------------

LIBRARY ieee; USE 
ieee.std_logic_1164.ALL;


entity spimssl_tb IS 
END spimssl_tb; 


ARCHITECTURE behave OF spimssl_tb IS 

CONSTANT spi_nbits : integer := 10; 

COMPONENT spims IS 
	GENERIC ( uspi_size : integer := 16); 
	PORT( resetn : in std_logic; 
	      bclk : in std_logic; 
	      start : in std_logic; 
	      done : out std_logic; 
	      sclk : out std_logic; 
	      scsq : out std_logic; 
	      sdo : out std_logic; 
	      sdi : in std_logic; 
	      senddata : in std_logic_vector(uspi_size -1 DOWNTO 0); 
	      recvdata : out std_logic_vector(uspi_size -1 DOWNTO 0)); 
END COMPONENT spims; 


COMPONENT spisl IS 
	GENERIC( uspi_size: integer := 16 ); 
	PORT( resetn : in std_logic ; 
		  bclk : in std_logic; 
		  done : out std_logic; 
		  slcsq : in std_logic; 
		  slsclk : in std_logic; 
		  slsdo:out std_logic; 
		  slsdi : in std_logic; 
		  slsnddata : in std_logic_vector(uspi_size -1 DOWNTO 0); 
		  slrecvdata : out std_logic_vector(uspi_size -1 DOWNTO 0)); 
END COMPONENT spisl; 


SIGNAL resetn : std_logic := '1'; 
SIGNAL bclk : std_logic :='0'; 
SIGNAL start : std_logic := '0'; 
SIGNAL scsq : std_logic :='0'; 
SIGNAL sclk : std_logic :='0'; 
SIGNAL mosi : std_logic := '0'; 
SIGNAL mISo : std_logic := '0'; 

SIGNAL snddata_master: std_logic_vector(spi_nbits-1 DOWNTO 0) :="0011100101"; 
SIGNAL rcvdata_master: std_logic_vector(spi_nbits-1 DOWNTO 0) :="0000000000"; 
SIGNAL snddata_slave : std_logic_vector(spi_nbits-1 DOWNTO 0) :="0011001100"; 
SIGNAL recvdata_slave: std_logic_vector(spi_nbits-1 DOWNTO 0) :="0000000000";

SIGNAL done_master : std_logic :='0'; 
SIGNAL done_slave : std_logic :='0'; 
CONSTANT clk_period : time := 10 ns; 


BEGIN 
		uut_m : spims ----for master 
			GENERIC MAP(uspi_size => spi_nbits) 
			PORT MAP( resetn => resetn, 
				      bclk => bclk, 
				      done => done_master, 
				      start => start, 
				      sclk => sclk, 
				      scsq => scsq, 
				      sdi =>mISo, 
				      sdo => mosi, 
				      senddata => snddata_master, 
				      recvdata => rcvdata_master); 
				
				
		uut_s : spISl ----for slave 
			GENERIC MAP( uspi_size => spi_nbits) 
			PORT MAP( resetn => resetn, 
			          bclk => bclk, 
			          done => done_slave, 
			          slcsq => scsq, 
			          slsclk => sclk, 
			          slsdo => mISo, 
			          slsdi => mosi, 
			          slsnddata => snddata_slave, 
			          slrecvdata => recvdata_slave); 
			
			
		clk_p : PROCESS 
			BEGIN 
				bclk <= '0'; 
				WAIT FOR clk_period / 2; 
				bclk <= '1'; 
				WAIT FOR clk_period / 2; 
			END PROCESS clk_p; 
			
			
		stim_p : PROCESS 
			BEGIN 
				WAIT FOR clk_period; 
				resetn <= '0'; 
				WAIT FOR clk_period; 
				resetn <= '1';
				WAIT FOR clk_period * 4; 
				start <= '1' ; 
				WAIT FOR clk_period * 4; 
				start <='0'; 
				WAIT FOR clk_period; 
				WAIT; 
			END PROCESS stim_p; 
END behave;