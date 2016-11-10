library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package my_package is
	function show_seq (signal counter, level : integer; signal enable : STD_LOGIC) return STD_LOGIC_VECTOR;
	function int_to_7seg (signal int : integer) return std_logic_vector;
end my_package;

package body my_package is
	function show_seq (signal counter, level : integer; signal enable : STD_LOGIC) return STD_LOGIC_VECTOR is
	begin
		if (enable = '0') then return "0000";
		-- separated in constants because of multiplication error
		elsif (level = 1) then
			if (counter < 1) then return "0001";
			elsif (counter < 2) then return "0010";
			elsif (counter < 3) then return "0100";
			elsif (counter < 4) then return "1000";
			elsif (counter < 5) then return "0001";
			elsif (counter < 6) then return "0010";
			elsif (counter < 7) then return "0100";
			elsif (counter < 8) then return "1000";
			elsif (counter < 9) then return "0001";
			elsif (counter < 10) then return "0010";
			elsif (counter < 11) then return "0100";
			elsif (counter < 12) then return "1000";
			elsif (counter < 13) then return "0001";
			elsif (counter < 14) then return "0010";
			elsif (counter < 15) then return "0100";
			else return "1000";
			end if;
		elsif (level = 2) then
			if (counter < 2) then return "0001";
			elsif (counter < 4) then return "0010";
			elsif (counter < 6) then return "0100";
			elsif (counter < 8) then return "1000";
			elsif (counter < 10) then return "0001";
			elsif (counter < 12) then return "0010";
			elsif (counter < 14) then return "0100";
			elsif (counter < 16) then return "1000";
			elsif (counter < 18) then return "0001";
			elsif (counter < 20) then return "0010";
			elsif (counter < 22) then return "0100";
			elsif (counter < 24) then return "1000";
			elsif (counter < 26) then return "0001";
			elsif (counter < 28) then return "0010";
			elsif (counter < 30) then return "0100";
			else return "1000";
			end if;
		else
			if (counter < 3) then return "0001";
			elsif (counter < 6) then return "0010";
			elsif (counter < 9) then return "0100";
			elsif (counter < 12) then return "1000";
			elsif (counter < 15) then return "0001";
			elsif (counter < 18) then return "0010";
			elsif (counter < 21) then return "0100";
			elsif (counter < 24) then return "1000";
			elsif (counter < 27) then return "0001";
			elsif (counter < 30) then return "0010";
			elsif (counter < 33) then return "0100";
			elsif (counter < 36) then return "1000";
			elsif (counter < 39) then return "0001";
			elsif (counter < 42) then return "0010";
			elsif (counter < 45) then return "0100";
			else return "1000";
			end if;	
		end if;
	end show_seq;
	
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