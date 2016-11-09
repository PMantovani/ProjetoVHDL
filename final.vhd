library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.my_package.all;

entity final is
	generic (T : integer := 5;
				DIV : integer := 50_000_000);
	port (buttons 	: in STD_LOGIC_VECTOR (3 downto 0);
			leds		: out STD_LOGIC_VECTOR (3 downto 0);
			sw_level	: in STD_LOGIC_VECTOR (1 downto 0);
			reset		: in STD_LOGIC;
			clk		: in STD_LOGIC;
			start		: in STD_LOGIC
			--test		: out STD_LOGIC
			);
end final;

architecture Behavioral of final is

type list_states is (idle, show1, input1);
--attribute enum_encoding: string;
--attribute enum_encoding of list_states: type is "sequential";
signal state : list_states := idle;
signal level : integer range 1 to 3;
signal clk_counter : integer range 0 to DIV := 0;
signal sec_counter : integer range 0 to 30 := 0;
signal timeout : STD_LOGIC := '0';
signal leds_enable : STD_LOGIC := '0';
signal input_enable : STD_LOGIC := '0';

begin

process (clk, reset, timeout)

begin
	if (reset = '1' or timeout = '1') then
		-- Timeout or reset, go to idle state
		state <= idle;
		sec_counter <= 0;
		clk_counter <= 0;
		timeout <= '0';
		
	elsif (rising_edge(clk)) then
		-- Rising edge of clock, increment counter
		clk_counter <= clk_counter + 1;
		
		-- update leds status
		leds <= show_seq(sec_counter, level, leds_enable);
		
		-- increment counter of seconds
		if (clk_counter = DIV) then
			sec_counter <= sec_counter + 1;
			clk_counter <= 0;
		end if;
		
		-- check if we reached our timeout
		if (sec_counter = T and input_enable = '1') then
			timeout <= '1';
		end if;
		
		case state is
			-- idle state
			when idle =>
				input_enable <= '0';
				leds_enable <= '0';
				
				if (start = '1') then
					state <= show1;
					clk_counter <= 0;
					sec_counter <= 0;
					-- Sets the difficult of the game
					if (sw_level = "00") then
						level <= 3;
					elsif (sw_level = "01") then
						level <= 2;
					else
						level <= 1;
					end if;
				end if;
			
			-- show1 state
			when show1 =>
				leds_enable <= '1';
				input_enable <= '0';
				
			if (sec_counter = level) then
				state <= input1;
			end if;
		
			-- input1 state
			when input1 =>
				leds_enable <= '0';
				input_enable <= '1';
				if (buttons /= "0000") then
					-- TODO: Implement button checking
				end if;
			
			when others =>
				leds_enable <= '0';
				input_enable <= '0';
		end case;
		
	end if;
end process;

end Behavioral;

