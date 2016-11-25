library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.my_package.all;


entity update_display is
	port (display	: out STD_LOGIC_VECTOR (6 downto 0);
			disp_mux	: out STD_LOGIC_VECTOR (3 downto 0);
			clk		: in STD_LOGIC;
			state		: in integer range 0 to 16;
			score		: in integer range 0 to 14
			);

end update_display;

	architecture Behavioral of update_display is

signal counter : integer range 0 to 50_000_000 := 0;
signal counter_mux : integer range 0 to 100_000 := 0;
signal progress : integer := 0;
signal mux_state : integer range 0 to 3 := 0;
signal disp1, disp2, disp3, disp4 : std_logic_vector (6 downto 0) := "1111111"; --disp1 leftmost, disp4 rightmost

type init_array is array (0 to 24) of std_logic_vector(6 downto 0);
constant init_word : init_array := ("0011000", "1111010", "0000001", "1000111",
"0110000", "1110000", "0000001", "1111111", "0001000", "0011000", "1110001",
"1001111", "0110001", "0001000", "1110000", "1001111", "1000001", "0000001",
"1111110", "0011000", "0011000","1111111","1111111","1111111","1111111");

begin

process (clk)
begin

	if (rising_edge(clk)) then
	
		counter <= counter + 1;
		counter_mux <= counter_mux + 1;
	
		-- multiplex the display
		if (counter_mux = 100_000) then
			counter_mux <= 0;
		
			if (mux_state = 0) then --rightmost display
				display <= disp1;
			elsif (mux_state = 1) then
				display <= disp2;
			elsif (mux_state = 2) then
				display <= disp3;
			else
				display <= disp4;
			end if;
		
			if (mux_state = 0) then
				disp_mux <= "1110";
				mux_state <= 1;
			elsif (mux_state = 1) then
				disp_mux <= "1101";
				mux_state <= 2;
			elsif (mux_state = 2) then
				disp_mux <= "1011";
				mux_state <= 3;
			else
				disp_mux <= "0111";
				mux_state <= 0;
			end if;
		end if;
		
		-- every 1/2 of a second, progress
		if (counter = 25_000_000) then
			counter <= 0;
			-- implements rolling of display if message to be shown
			if (state = 0) then
				if (progress = 0) then
					disp1 <= "1111111";
					disp2 <= "1111111";
					disp3 <= "1111111";
					disp4 <= init_word(0);
				else
					disp1 <= disp2;
					disp2 <= disp3;
					disp3 <= disp4;
					disp4 <= init_word(progress);
				end if;
				progress <= progress + 1;
								
				if (progress = 24) then
					progress <= 0;
				end if;
			end if;
		end if;
		
		if (state = 15) then
			progress <= 0;
			disp1 <= "1110001"; -- L
			disp2 <= "0000001"; -- O
			disp3 <= "0100100"; -- S
			disp4 <= "0110000"; -- E
				
		elsif (state = 16) then
			progress <= 0;
			disp1 <= "1111111"; --  
			disp2 <= "1111111"; --  
			disp3 <= "0100000"; -- G
			disp4 <= "0100000"; -- G
				
		elsif (state /= 0) then -- shows score
			progress <= 0;
			if (score >= 10) then
				disp1 <= "1111111";
				disp2 <= "1111111";
				disp3 <= "1001111"; -- 1
				disp4 <= int_to_7seg(score);
			else
				disp1 <= "1111111";
				disp2 <= "1111111";
				disp3 <= "0000001"; -- 0
				disp4 <= int_to_7seg(score);
			end if;
		end if;
	
	end if;

end process;

end Behavioral;

-- projeto alicativo - pp
-- P : 0011000
-- r : 1111010
-- O : 0000001
-- J : 1000111
-- E : 0110000
-- t : 1110000
-- O : 0000001
--   : 1111111
-- A : 0001000
-- P : 0011000
-- L : 1110001
-- I : 1001111
-- C : 0110001
-- A : 0001000
-- t : 1110000
-- I : 1001111
-- V : 1000001
-- O : 0000001
-- - : 1111110
-- P : 0011000
-- P : 0011000

-- lose
-- L : 1110001
-- O : 0000001
-- S : 0100100
-- E : 0110000

-- gg
--   : 1111111
--   : 1111111
-- G : 0100000
-- G : 0100000
