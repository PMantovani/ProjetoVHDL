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
			);
end final;

architecture Behavioral of final is

type state is (idle, show1, input1);
attribute enum_encoding: string;
attribute enum_encoding of state: type is "sequential";
signal current_s, next_s : state;
signal blinkInterval : integer range 1 to 3;
signal clk_counter : integer range 0 to DIV := 0;
signal sec_counter : integer range 0 to 10 := 0;
signal timeout : STD_LOGIC := '0';
signal enableLeds : STD_LOGIC := '0';

begin

process (clk, reset)
begin
	if (reset = '1' or timeout = '1') then
		-- Timeout or reset, go to idle state
	elsif (rising_edge(clk)) then
		-- Rising edge of clock, change to next state
		if (current_s /= next_s) then
			clk_counter <= 0;
			sec_counter <= 0;
		else
			clk_counter <= clk_counter + 1;
		end if;
		-- move to next state
		current_s <= next_s;
		
		-- update leds status
		leds <= show_seq(sec_counter, blinkInterval, enableLeds);
		
		-- increment counter of seconds
		if (clk_counter = DIV) then
			sec_counter <= sec_counter + 1;
			clk_counter <= 0;
		end if;
		
		-- check if we reached our timeout
		if (sec_counter = T) then
			timeout <= '1';
		end if;
	end if;
end process;

process (current_s, buttons, start, timeout, sec_counter)
begin 
	case current_s is
		-- idle state
		when idle =>
			if (start = '1') then
				next_s <= show1;
				-- Sets the difficult of the game
				if (sw_level = "00") then
					blinkInterval <= 3;
				elsif (sw_level = "01") then
					blinkInterval <= 2;
				else
					blinkInterval <= 1;
				end if;
			end if;
		
		-- show1 state
		when show1 =>
			enableLeds <= '1';
			if (sec_counter = blinkInterval) then
				next_s <= input1;
			end if;
		
		-- wait1 state
		when input1 =>
			enableLeds <= '0';
			
	end case;
end process;

end Behavioral;

