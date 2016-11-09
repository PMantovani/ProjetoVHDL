LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY final_tb IS
END final_tb;
 
ARCHITECTURE behavior OF final_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT final
    PORT(
         buttons : IN  std_logic_vector(3 downto 0);
         leds : OUT  std_logic_vector(3 downto 0);
         sw_level : IN  std_logic_vector(1 downto 0);
         reset : IN  std_logic;
         clk : IN  std_logic;
         init : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal buttons : std_logic_vector(3 downto 0) := (others => '0');
   signal sw_level : std_logic_vector(1 downto 0) := (others => '0');
   signal reset : std_logic := '0';
   signal clk : std_logic := '0';
   signal init : std_logic := '0';

 	--Outputs
   signal leds : std_logic_vector(3 downto 0);

   -- Clock period definitions
   constant clk_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: final PORT MAP (
          buttons => buttons,
          leds => leds,
          sw_level => sw_level,
          reset => reset,
          clk => clk,
          init => init
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10; 

      -- insert stimulus here 
		sw_level <= "10";
		wait for 1 us;
		init <= '1';
      wait;
   end process;

END;
