----------------------------------------------------------------------------------
-- Company:         Univ. Bremerhaven
-- Engineer:        Arsal Abbas
-- Create Date:     20.06.2022
-- Description:     SPI Master
----------------------------------------------------------------------------------

--spi master(send/receive) 
LIBRARY ieee; 
USE ieee.std_logic_1164.all; 

ENTITY spims IS
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
END spims;


ARCHITECTURE behave OF spims IS 
TYPE state_type IS (sidle, sstartx, sstart_lo,sclk_lo,sclk_hi, sstop_hi,sstop_lo); 
SIGNAL m_state, m_next_state : state_type; 
SIGNAL sclk_i, scsq_i, sdo_i : std_logic; 
SIGNAL wr_buf : std_logic_vector(uspi_size-1 DOWNTO 0); 
SIGNAL rd_buf : std_logic_vector(uspi_size-1 DOWNTO 0); 
SIGNAL count : integer RANGE 0 TO uspi_size-1; 

CONSTANT clk_div : integer := 3; 
SUBTYPE clkdiv_type IS integer RANGE 0 to clk_div - 1; 
SIGNAL spi_clkp : std_logic; 


BEGIN 
	recvdata <= rd_buf; 
	
	clk_d : PROCESS(bclk) --- To slow down 
	VARIABLE clkd_cnt : clkdiv_type; 
	BEGIN 
		IF rising_edge(bclk) THEN 
			spi_clkp <= '0'; 
			IF resetn='0' THEN 
				clkd_cnt := clk_div-1; 
				ELSif clkd_cnt=0 THEN 
					spi_clkp<= '1'; 
					clkd_cnt := clk_div-1; 
				ELSE 
					clkd_cnt := clkd_cnt -1; 
			END IF; 
		END IF; 
	END PROCESS clk_d; 
	

--spi logic 
	seq_p : PROCESS(bclk) 
	BEGIN 
		IF rising_edge(bclk) THEN 
			IF resetn ='0' THEN 
				m_state <= sidle; 
			ELSIF spi_clkp = '1' THEN 
				IF m_next_state = sstartx THEN 
					wr_buf <= senddata; 
					count <= uspi_size-1; 
				ELSIF m_next_state = sclk_hi THEN 
					count <= count -1; 
				ELSIF m_next_state = sclk_lo THEN 
					wr_buf <= wr_buf(uspi_size-2 DOWNTO 0) &'-';
					rd_buf <= rd_buf(uspi_size-2 DOWNTO 0) & sdi; 
				ELSIF m_next_state = sstop_lo THEN 
					rd_buf <= rd_buf(uspi_size-2 DOWNTO 0) & sdi ; 
				END IF; 
				m_state <= m_next_state; 
				scsq <= scsq_i; 
				sclk <= sclk_i; --output of ff scsq provided by combinational 
				sdo <= sdo_i; 
			END IF; 
		END IF; 
	END PROCESS seq_p; 


	--combinational logic: 
	cmb_p : PROCESS(m_state, start, count, wr_buf) 
	BEGIN 
		--defaults
		m_next_state <= m_state; 
		done <= '0'; 
		scsq_i <= '0'; 
		sclk_i <= '0'; 
		sdo_i <='0'; 
		
		CASE m_state IS 
			WHEN sidle => 
				done <= '1'; 
				scsq_i <= '1'; --overide the default for idle 
				IF start = '1' THEN 
				m_next_state <= sstartx; 
				END IF; 
			WHEN sstartx => 
				m_next_state <= sstart_lo; 
			WHEN sstart_lo => 
				sclk_i <= '1'; 
				sdo_i<= wr_buf(uspi_size-1); 
				m_next_state <= sclk_hi; 
			WHEN sclk_hi => 
				sdo_i <= wr_buf(uspi_size -1); 
				m_next_state <= sclk_lo; 
			WHEN sclk_lo => 
				sclk_i <= '1'; 
				sdo_i <= wr_buf(uspi_size - 1); 
				IF count = 0 THEN 
					m_next_state <= sstop_hi; 
				ELSE 
					m_next_state <= sclk_hi; 
				END IF; 
			WHEN sstop_hi => 
				sdo_i <= wr_buf(uspi_size-1); 
				m_next_state <= sstop_lo;
			WHEN sstop_lo => 
				scsq_i <='1'; 
				m_next_state <= sidle; 
		END CASE; 
	END PROCESS cmb_p; 
END behave;