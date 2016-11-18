library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package my_package is
	function int_to_7seg (signal int : integer) return std_logic_vector;
end my_package;

package body my_package is
	function int_to_7seg (signal int : integer) return std_logic_vector is
	variable temp : integer;
	begin
		if (int > 10) then temp := int - 10;
		else temp := int;
		end if;
		
		if (temp = 0) then return "0000001";
		elsif (temp = 1) then return "1001111";
		elsif (temp = 2) then return "0010010";
		elsif (temp = 3) then return "0000110";
		elsif (temp = 4) then return "1001100";
		elsif (temp = 5) then return "0100100";
		elsif (temp = 6) then return "0100000";
		elsif (temp = 7) then return "0001111";
		elsif (temp = 8) then return "0000000";
		else return "0000100";
		end if;
	end int_to_7seg;
	
end my_package;