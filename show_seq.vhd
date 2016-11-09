library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package my_package is
	function show_seq (signal counter, blinkInterval : integer; signal enable : STD_LOGIC) return STD_LOGIC_VECTOR;
end my_package;

package body my_package is
	function show_seq (signal counter, blinkInterval : integer; signal enable : STD_LOGIC) return STD_LOGIC_VECTOR is
	begin
		if (enable = '0') then return "0000";
		elsif (counter < blinkInterval) then return "0001";
		elsif (counter < 2*blinkInterval) then return "1000";
		elsif (counter < 3*blinkInterval) then return "0100";
		elsif (counter < 4*blinkInterval) then return "1000";
		elsif (counter < 5*blinkInterval) then return "1000";
		elsif (counter < 6*blinkInterval) then return "0010";
		elsif (counter < 7*blinkInterval) then return "0001";
		elsif (counter < 8*blinkInterval) then return "0010";
		elsif (counter < 9*blinkInterval) then return "0100";
		elsif (counter < 10*blinkInterval) then return "0010";
		elsif (counter < 11*blinkInterval) then return "1000";
		elsif (counter < 12*blinkInterval) then return "0001";
		elsif (counter < 13*blinkInterval) then return "0001";
		elsif (counter < 14*blinkInterval) then return "0010";
		elsif (counter < 15*blinkInterval) then return "0100";
		else return "1000";
		end if;
	end show_seq;
end my_package;

--entity show_seq is
--   port( counter : in integer;
--			blinkInterval : in integer;
--         leds : out  STD_LOGIC_VECTOR (3 downto 0)
--			);
--end show_seq;
--
--architecture Behavioral of show_seq is
--
--type seq_array is array (0 to 16) of std_logic_vector(3 downto 0);
--signal sequence : seq_array := ("0001","1000","0100","1000","1000","0010",
--	"0001","0010","0100","0010","1000","0001","0001","0010","0100","1000");
--
--begin
--
--	leds <=	"0001" when counter < blinkInterval else
--				"1000" when counter < 2*blinkInterval else
--				"0100" when counter < 3*blinkInterval else
--				"1000" when counter < 4*blinkInterval else
--				"1000" when counter < 5*blinkInterval else
--				"0010" when counter < 6*blinkInterval else
--				"0001" when counter < 7*blinkInterval else
--				"0010" when counter < 8*blinkInterval else
--				"0100" when counter < 9*blinkInterval else
--				"0010" when counter < 10*blinkInterval else
--				"1000" when counter < 11*blinkInterval else
--				"0001" when counter < 12*blinkInterval else
--				"0001" when counter < 13*blinkInterval else
--				"0010" when counter < 14*blinkInterval else
--				"0100" when counter < 15*blinkInterval else
--				"1000";
--
--end Behavioral;