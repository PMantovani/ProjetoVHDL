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
			disp_mux : out STD_LOGIC_VECTOR (3 downto 0);
			state_led: out std_logic_vector (2 downto 0);
			-- vga ports
			vga_hs, vga_vs : out std_logic;
			vga_red : out unsigned (2 downto 0);
			vga_green : out unsigned (2 downto 0);
			vga_blue : out unsigned (1 downto 0)
			);
end final;

architecture Behavioral of final is

type list_states is (standby, show, changeleds, input, lose, win);
attribute syn_encoding: string;
attribute syn_encoding of list_states: type is "sequential";
signal state : list_states := standby;
signal state_num : integer range 0 to 16;
signal level : integer range 1 to 3;
signal score : integer range 0 to 14 := 0;
signal clk_counter : integer range 0 to DIV := 0;
signal sec_counter : integer range 0 to 5 := 0;
signal input_enable : STD_LOGIC := '0';
signal button_result : integer range 0 to 2;
signal button_progress : integer range 0 to 14 := 0;
signal blank : std_logic := '0';
signal show_progress : integer range 0 to 14 := 0;
signal vga_leds : std_logic_vector (3 downto 0) := "0000";

type leds_array is array (0 to 13) of std_logic_vector (3 downto 0);
constant sequence : leds_array := ("0001","0010","0100","1000",
	"0001","0010","0100","1000","0001","0010","0100","1000","0001",
	"0010");

component update_display is
	port (display	: out STD_LOGIC_VECTOR (6 downto 0);
			disp_mux	: out STD_LOGIC_VECTOR (3 downto 0);
			clk		: in STD_LOGIC;
			state		: in integer range 0 to 30;
			score		: in integer range 0 to 14
			);
end component;

component button_read is
	generic (DEB_TIME : integer := 10_000_000);
	port (buttons : in std_logic_vector (3 downto 0);
			button_enable : in std_logic;
			progress : in integer range 0 to 14;
			clk : in std_logic;
			read_result : out integer range 0 to 2);
end component;

component vga_control is
	port (clk : in std_logic;
			VGA_HS, VGA_VS: out std_logic;
			VGA_RED: out unsigned (2 downto 0);
			VGA_GREEN: out unsigned (2 downto 0);
			VGA_BLUE: out unsigned (1 downto 0);
			rst : in std_logic;
			opcode_in: in std_logic_vector(3 downto 0);
			score: in integer range 0 to 14;
			state: in integer range 0 to 16
			);
end component;

begin

process (clk, reset)

begin
	if (reset = '1') then
		-- reset, go to standby state
		state <= standby;
		sec_counter <= 0;
		clk_counter <= 0;
		
	elsif (rising_edge(clk)) then
		-- Rising edge of clock, increment counter
		clk_counter <= clk_counter + 1;
		
		-- increment counter of seconds
		if (clk_counter = DIV) then
			sec_counter <= sec_counter + 1;
			clk_counter <= 0;
		end if;
		
		case state is
			-- standby state
			when standby =>
				state_num <= 0;
				input_enable <= '0';
				score <= 0;
				
				if (start = '1') then
					state <= show;
					clk_counter <= 0;
					sec_counter <= 0;
					state_num <= 1;
					-- Sets the difficult of the game
					if (sw_level = "00") then
						level <= 1; -- easy (~0.96 sec/led)
					elsif (sw_level = "01") then
						level <= 2;	-- medium (~0.64 sec/led)
					else
						level <= 3;	-- hard (~0.32 sec/led)
					end if;
				end if;
			
			-- show state
			when show =>
				input_enable <= '0';
				
				if (show_progress = score+2) then -- waits for the last sequence to show up
					state <= input;
					clk_counter <= 0;
					sec_counter <= 0;
					button_progress <= 0;
					show_progress <= 0;				
				elsif ((clk_counter = 10_000_000 and blank='0') or (clk_counter = (4-level)*16_000_000 and blank='1')) then
					-- show next sequence of the leds
					state <= changeleds;
					clk_counter <= 0;
					sec_counter <= 0;
				end if;

				
			-- change leds state
			when changeleds =>
				if (blank = '1') then
					leds <= "0000";
					vga_leds <= "0000";
				else
					leds <= sequence(show_progress);
					vga_leds <= sequence(show_progress);
					show_progress <= show_progress + 1;
				end if;
				state <= show;
				blank <= not blank;
		
			-- input state
			when input =>
				leds <= buttons;
				vga_leds <= buttons;
				state_led <= std_logic_vector(to_unsigned(button_progress, state_led'length));
				input_enable <= '1';
				
				-- timeout reached (5 seconds)
				if (sec_counter = T) then
					state <= lose;
					sec_counter <= 0;
					clk_counter <= 0;
				elsif (button_result = 1) then -- wrong button
					state <= lose;
					clk_counter <= 0;
					sec_counter <= 0;
				elsif (button_result = 2) then -- right button
					clk_counter <= 0;
					sec_counter <= 0;
					if (button_progress = score) then -- finished sequence
						if (score = 13) then -- won the game
							state <= win;
							clk_counter <= 0;
							sec_counter <= 0;
						else -- continue the game
							state <= show;
							clk_counter <= 0;
							sec_counter <= 0;
							score <= score + 1;
							state_num <= state_num + 1;
						end if;
					else -- continue reading the sequence
						button_progress <= button_progress + 1;
					end if;
				else
					state <= input;
				end if;

			-- player lost
			when lose =>
				state_num <= 15;
				input_enable <= '0';
				
				if (sec_counter = 5) then
					state <= standby;
				end if;
			
			-- player won!
			when win =>
				state_num <= 16;
				input_enable <= '0';
				
				if (sec_counter = 5 or start = '1') then
						state <= standby;
				end if;
			
		end case;
		
	end if;
end process;

disp_comp: update_display port map (display, disp_mux, clk, state_num, score);
input_comp: button_read port map (buttons, input_enable, button_progress, clk, button_result);
vga_comp: vga_control port map (clk, vga_hs, vga_vs, vga_red, vga_green, vga_blue, reset, vga_leds, score, state_num);

end Behavioral;

