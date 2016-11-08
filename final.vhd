library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity final is
	port (buttons 	: in STD_LOGIC_VECTOR (3 downto 0);
			leds		: out STD_LOGIC_VECTOR (3 downto 0);
			level		: in STD_LOGIC_VECTOR (2 downto 0);
			reset		: in STD_LOGIC;
			clk		: in STD_LOGIC;
			init		: in STD_LOGIC;
			);
end final;

architecture Behavioral of final is

begin


end Behavioral;

