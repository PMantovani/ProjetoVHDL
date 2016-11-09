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