library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity button_read is
	generic (DEB_TIME : integer := 20_000_000);
	port (buttons : in std_logic_vector (3 downto 0);
			button_enable : in std_logic;
			progress : in integer range 0 to 14;
			clk : in std_logic;
			read_result : out integer range 0 to 2
			);
			
end button_read;

architecture Behavioral of button_read is
	signal debouncing : std_logic := '0';
	signal back_debouncing : std_logic := '0';
	signal counter : integer range 0 to 50_000_000 := 0;
	signal temp_correct : std_logic := '0';
	
	type button_array is array (0 to 13) of std_logic_vector (3 downto 0);
	constant sequence : button_array := ("0001","0010","0100","1000",
	"0001","0010","0100","1000","0001","0010","0100","1000","0001",
	"0010");
begin

process (clk, buttons)
begin

	if (rising_edge(clk)) then
		if (counter /= DEB_TIME) then
			counter <= counter + 1;
		elsif (back_debouncing = '1') then -- implements debouncing after button is released
			back_debouncing <= '0';
		end if;
		
	
		if (button_enable = '1' and back_debouncing = '0') then
			if (buttons /= "0000" and debouncing = '0') then
				counter <= 0;
				debouncing <= '1';
				
				-- stores temporary result, will only return after debounce
				if (buttons = sequence(progress)) then
					temp_correct <= '1';
				else
					temp_correct <= '0';
				end if;
			
			else
				read_result <= 0; -- no readings
			end if;
		else
			read_result <= 0; -- no readings
		end if;
		
		if (counter = DEB_TIME and buttons = "0000" and debouncing = '1') then
			-- debouncing condition is reached
			counter <= 0;
			debouncing <= '0';
			back_debouncing <= '1';
			if (temp_correct = '1') then -- effectively returns the result
				read_result <= 2; -- right button
			else
				read_result <= 1; -- wrong button
			end if;
		end if;
		
	end if;
end process;

end Behavioral;

