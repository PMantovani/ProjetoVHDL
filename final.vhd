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
			start		: in STD_LOGIC;
			display	: out STD_LOGIC_VECTOR (6 downto 0);
			disp_mux : out STD_LOGIC_VECTOR (3 downto 0)
			--test		: out STD_LOGIC
			);
end final;

architecture Behavioral of final is

type list_states is (idle, show, input, lose);
--attribute enum_encoding: string;
--attribute enum_encoding of list_states: type is "sequential";
signal state : list_states := idle;
signal state_num : integer range 0 to 30;
signal level : integer range 1 to 3;
signal score : integer range 0 to 14 := 0;
signal clk_counter : integer range 0 to DIV := 0;
signal sec_counter : integer range 0 to 100 := 0;
signal timeout : STD_LOGIC := '0';
signal leds_enable : STD_LOGIC := '0';
signal input_enable : STD_LOGIC := '0';
signal button_result : integer range 0 to 2;

component update_display is
	port (display	: out STD_LOGIC_VECTOR (6 downto 0);
			disp_mux	: out STD_LOGIC_VECTOR (3 downto 0);
			clk		: in STD_LOGIC;
			state		: in integer range 0 to 30;
			score		: in integer range 0 to 14
			);
end component;

component button_read is
	generic (DEB_TIME : integer := 100_000);
	port (buttons : in std_logic_vector (3 downto 0);
			button_enable : in std_logic;
			cur_score : in integer;
			clk : in std_logic;
			read_result : out integer);
end component;

begin

process (clk, reset, timeout)

begin
	if (reset = '1') then
		-- Timeout or reset, go to idle state
		state <= idle;
		sec_counter <= 0;
		clk_counter <= 0;
		timeout <= '0';
		
	elsif (rising_edge(clk)) then
		-- Rising edge of clock, increment counter
		clk_counter <= clk_counter + 1;
		
		-- increment counter of seconds
		if (clk_counter = DIV) then
			sec_counter <= sec_counter + 1;
			clk_counter <= 0;
		end if;
		
		-- check if we reached our timeout
		if (sec_counter = T and input_enable = '1') then
			timeout <= '1';
		end if;
		
		-- update leds status
		leds <= show_seq(sec_counter, level, leds_enable);
		
		case state is
			-- idle state
			when idle =>
				state_num <= 0;
				input_enable <= '0';
				leds_enable <= '0';
				score <= 0;
				
				if (start = '1') then
					state <= show;
					clk_counter <= 0;
					sec_counter <= 0;
					state_num <= state_num + 1;
					-- Sets the difficult of the game
					if (sw_level = "00") then
						level <= 3; -- easy (3 sec/led)
					elsif (sw_level = "01") then
						level <= 2;	-- medium (2 sec/led)
					else
						level <= 1;	-- hard (1 sec/led)
					end if;
				end if;
			
			-- show state
			when show =>
				leds_enable <= '1';
				input_enable <= '0';
				
				if (sec_counter = (score+1)*level) then
					state <= input;
					clk_counter <= 0;
					sec_counter <= 0;
					state_num <= state_num + 1;
				end if;
		
			-- input state
			when input =>
				leds_enable <= '0';
				input_enable <= '1';
				
				if (button_result = 1) then
					state <= lose;
				elsif (button_result = 2) then
					state <= show;
					clk_counter <= 0;
					sec_counter <= 0;
					score <= score + 1;
					state_num <= state_num + 1;
				else
					state <= input;
				end if;

			-- user lost
			when lose =>
				state_num <= 15;
				leds_enable <= '0';
				input_enable <= '0';
				
				if (sec_counter = 5 or start = '1') then
					state <= idle;
				end if;
			
			when others =>
				leds_enable <= '0';
				input_enable <= '0';
		end case;
		
	end if;
end process;

disp_comp: update_display port map (display, disp_mux, clk, state_num, score);
input_comp: button_read port map (buttons, input_enable, score, clk, button_result);

end Behavioral;

