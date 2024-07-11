----------------------------------------------------------------------------------
-- Company:         Univ. Bremerhaven
-- Engineer:        Arsal Abbas
-- Create Date:     20.06.2022
-- Description:     SPI slave
----------------------------------------------------------------------------------

LIBRARY ieee; 
USE ieee.std_logic_1164.all;

 
ENTITY spisl IS 
	GENERIC( uspi_size: integer := 16 ); 
	PORT( resetn : in std_logic; 
		  bclk : in std_logic; 
		  done : out std_logic; 
		  slcsq : in std_logic; 
		  slsclk : in std_logic; 
		  slsdo: out std_logic; 
		  slsdi : in std_logic; 
		  slsnddata : in std_logic_vector(uspi_size -1 DOWNTO 0); 
		  slrecvdata : out std_logic_vector(uspi_size -1 DOWNTO 0)); 
	END spisl; 


ARCHITECTURE behave OF spisl IS 
TYPE state_type IS(idle, csstart, starthi_s, starthi, startlo_s, startlo, clkhi_s, clkhi, clklo_s,clklo, leadout); 
SIGNAL s_state, s_next_state : state_type; 
SIGNAL count : integer RANGE 0 to uspi_size -1; 
SIGNAL sdo_buffer, sdi_buffer : std_logic_vector(uspi_size -1 DOWNTO 0); 


BEGIN 

	slrecvdata <= sdi_buffer; 
	
	slseq : PROCESS(bclk) 
	BEGIN 
		IF rising_edge(bclk) THEN 
			IF resetn='0' THEN 
				s_state <= idle; 
				count <= uspi_size-1; 
				slsdo <= '0'; 
			ELSE 
				IF s_next_state = csstart THEN 
					sdo_buffer <= slsnddata; 
					count <= uspi_size-1; 
				ELSIF s_next_state = starthi_s THEN 
					slsdo <= sdo_buffer(uspi_size -1); 
				ELSIF s_next_state = startlo_s THEN 
					sdi_buffer <= sdi_buffer(uspi_size -2 DOWNTO 0) & slsdi; 
					sdo_buffer <= sdo_buffer(uspi_size -2 DOWNTO 0) & '-'; 
				ELSIF s_next_state = clkhi_s THEN 
					slsdo <= sdo_buffer(uspi_size -1); 
					count <= count - 1; 
				ELSIF s_next_state = clklo_s THEN 
					sdi_buffer <= sdi_buffer(uspi_size -2 DOWNTO 0) & slsdi; 
					sdo_buffer <= sdo_buffer(uspi_size -2 DOWNTO 0) & '-'; 
				ELSIF s_next_state = idle THEN 
				slsdo <= '0'; 
				END IF; 
				s_state <= s_next_state; 
			END IF; 
		END IF; 
	END PROCESS slseq; 
	
	
	slcmb : PROCESS(s_state, slcsq, slsclk, count) 
	BEGIN 
		s_next_state <= s_state; 
		done <='0'; 
		CASE s_state IS 
			WHEN idle=> 
				done <= '1'; 
				IF slcsq = '0' THEN 
					s_next_state <= csstart; 
				END IF; 
			WHEN csstart => 
				IF slsclk = '1' THEN 
					s_next_state <= starthi_s; 
				END IF; 
			WHEN starthi_s => 
				s_next_state <= starthi; 
			WHEN starthi => 
				IF slsclk = '0' THEN 
					s_next_state <= startlo_s;
				END IF; 
			WHEN startlo_s => 
				s_next_state <= startlo; 
			WHEN startlo => 
				IF slsclk = '1' THEN 
					s_next_state <= clkhi_s; 
				END IF; 
			WHEN clkhi_s => 
				s_next_state <= clkhi; 
			WHEN clkhi => 
				IF slsclk = '0' THEN 
					s_next_state <= clklo_s; 
				END IF; 
			WHEN clklo_s => 
				s_next_state <= clklo; 
			WHEN clklo => 
				IF count = 0 THEN 
					s_next_state <= leadout; 
				ELSE 
					IF slsclk = '1' THEN 
						s_next_state <= clkhi_s; 
					END IF; 
				END IF; 
			WHEN leadout => 
				IF slcsq = '1' THEN 
					s_next_state <= idle; 
				END IF; 
		END CASE; 
	END PROCESS slcmb; 
END behave;
