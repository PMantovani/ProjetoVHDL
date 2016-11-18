library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity button_read is
	generic (DEB_TIME : integer := 10_000_000);
	port (buttons : in std_logic_vector (3 downto 0);
			button_enable : in std_logic;
			progress : in integer range 0 to 14;
			clk : in std_logic;
			read_result : out integer range 0 to 2);
			
end button_read;

architecture Behavioral of button_read is
	signal debouncing : std_logic := '0';
	signal counter : integer range 0 to 25_000_000 := 0;
	
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
		elsif (buttons = "0000") then
			counter <= 0;
			debouncing <= '0';
		end if;
	
		if (button_enable = '1') then
			if (buttons /= "0000" and debouncing = '0') then
				counter <= 0;
				debouncing <= '1';
				
				if (buttons = sequence(progress)) then
					read_result <= 2; -- right button
				else
					read_result <= 1; -- wrong button
				end if;
			
			else
				read_result <= 0; -- no readings
			end if;
		else
			read_result <= 0; -- no readings
		end if;
	end if;
end process;

end Behavioral;

