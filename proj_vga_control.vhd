----------------------------------------------------------------------------------
-- 									CONTROLADOR VGA
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity vga_control is
port (
	clk : in std_logic;
	
	VGA_HS, VGA_VS : out std_logic;
	VGA_RED : out unsigned (2 downto 0);
	VGA_GREEN : out unsigned (2 downto 0);
	VGA_BLUE : out unsigned (1 downto 0);
	
	rst : in std_logic;
	
	opcode_in : in std_logic_vector(3 downto 0);
	score : in integer range 0 to 14;
	state : in integer range 0 to 16
	
	);
end vga_control;

architecture Behavioral of vga_control is

	component vga_controller_640_60
	Port(
			rst         : in std_logic;
			
			clk50			: in std_logic;

			HS          : out std_logic;
			VS          : out std_logic;
			hcount      : out std_logic_vector(10 downto 0);
			vcount      : out std_logic_vector(10 downto 0);
			blank       : out std_logic
		);
	end component;	
	
----------------------------------------------------------------------------------
-- 	1-	DECLARAÇÃO DAS CORES E SINAIS QUE SERÃO USADOS
----------------------------------------------------------------------------------

	constant GREEN : unsigned(7 downto 0) := "00011100";
	constant RED : unsigned(7 downto 0) := "11100000";
	constant DARKRED : unsigned(7 downto 0) := "01100000";
	constant BLUE : unsigned(7 downto 0) := "00000011";
	constant BLACK : unsigned(7 downto 0) := "00000000";
	constant WHITE : unsigned(7 downto 0) := "11111111";
	constant GRAY  : unsigned(7 downto 0) := "01001001";
	constant TEAL  : unsigned(7 downto 0) := "00011111";
	constant YELLOW  : unsigned(7 downto 0) := "11111100";
	signal BACKGROUNDCOLOR :unsigned(7 downto 0);
	
	signal HS      : std_logic;
	signal VS      : std_logic;
	signal hcount  : std_logic_vector(10 downto 0);
	signal vcount  : std_logic_vector(10 downto 0);
	signal hblock  : integer;
	signal vblock  : integer;
	
	signal blank	: std_logic;
	
	signal VGA_COLOR : unsigned (7 downto 0);

	signal ERROR_SCREEN : unsigned (7 downto 0);
	signal WIN_SCREEN: unsigned (7 downto 0);
	signal DEFAULT_SCREEN : unsigned (7 downto 0);
	signal at_UP, at_DOWN, at_LEFT, at_RIGHT, at_MID, at_1, at_2, at_3, at_4,
				at_5, at_6, at_7, at_8, at_9, at_10, at_11, at_12, at_13, at_14: std_logic;
	
			
begin

	VGA_RED 		<= "000" when blank = '1' else VGA_COLOR(7 downto 5);
	VGA_GREEN 	<= "000" when blank = '1' else VGA_COLOR(4 downto 2);	
	VGA_BLUE 	<= "00" when blank = '1' else VGA_COLOR(1 downto 0);
	VGA_HS <= HS;
	VGA_VS <= VS;	

----------------------------------------------------------------------------------
-- 	2-	CONVERSÃO DOS CONTADORES HORIZONTAL E VERTICAL EM BLOCOS DE 20x15
----------------------------------------------------------------------------------	
	hblock <= TO_INTEGER(unsigned(hcount(9 downto 5)));
	vblock <= TO_INTEGER(unsigned(vcount(9 downto 5)));

	vga_controller : vga_controller_640_60 port map (
		clk50 => clk, 
		rst => rst,

		HS => HS,
		VS => VS,
		hcount => hcount,
		vcount => vcount,		

		blank => blank

	); 
	
	
----------------------------------------------------------------------------------
-- 	3-	MONITORAMENTO DO at_button. SE CONTIVER O PIXEL SETA O FLAG
----------------------------------------------------------------------------------	

	scan_at_button : process (hblock,vblock,clk)
	begin
	
----------------------------------------------------------------------------------
-- 	4-	FORAM COLOCADOS CLOCKS NAS FLAGS PARA EVITAR COM QUE NA TRANSIÇÃO DO 
--			CONTADOR VERTICAL PARA O HORIZONTAL (E VICE-VERSA) O at_button PENSASSE
--			QUE ESTAVA SETADO.
----------------------------------------------------------------------------------
		
		if rising_edge(clk) then
			
			if (hblock = 4 or hblock = 5 or hblock = 6) and (vblock = 3 or vblock = 4 or vblock = 5) then at_UP <= '1';
			else at_UP <= '0';
			end if;
			
			if (hblock = 4 or hblock = 5 or hblock = 6) and (vblock = 9 or vblock = 10 or vblock = 11) then at_DOWN <= '1';
			else at_DOWN <= '0';
			end if;
			
			if (hblock = 1 or hblock = 2 or hblock = 3) and (vblock = 6 or vblock = 7 or vblock = 8) then at_LEFT <= '1';
			else at_LEFT <= '0';
			end if;
			
			if (hblock = 7 or hblock = 8 or hblock = 9) and (vblock = 6 or vblock = 7 or vblock = 8) then at_RIGHT <= '1';
			else at_RIGHT <= '0';
			end if;
			
			if (hblock = 4 or hblock = 5 or hblock = 6) and (vblock = 6 or vblock = 7 or vblock = 8) then at_MID <= '1';
			else at_MID <= '0';
			end if;	
			
			if (hblock = 11 and vblock = 2) then at_1 <= '1';
			else at_1 <= '0';
			end if;
			
			if (hblock = 13 and vblock = 2) then at_2 <= '1';
			else at_2 <= '0';
			end if;
			
			if (hblock = 15 and vblock = 2) then at_3 <= '1';
			else at_3 <= '0';
			end if;
			
			if (hblock = 17 and vblock = 2) then at_4 <= '1';
			else at_4 <= '0';
			end if;
			
			if (hblock = 19 and vblock = 2) then at_5 <= '1';
			else at_5 <= '0';
			end if;
			
			if (hblock = 11 and vblock = 4) then at_6 <= '1';
			else at_6 <= '0';
			end if;
			
			if (hblock = 13 and vblock = 4) then at_7 <= '1';
			else at_7 <= '0';
			end if;
			
			if (hblock = 15 and vblock = 4) then at_8 <= '1';
			else at_8 <= '0';
			end if;
			
			if (hblock = 17 and vblock = 4) then at_9 <= '1';
			else at_9 <= '0';
			end if;
			
			if (hblock = 19 and vblock = 4) then at_10 <= '1';
			else at_10 <= '0';
			end if;
			
			if (hblock = 11 and vblock = 6) then at_11 <= '1';
			else at_11 <= '0';
			end if;
			
			if (hblock = 13 and vblock = 6) then at_12 <= '1';
			else at_12 <= '0';
			end if;
			
			if (hblock = 15 and vblock = 6) then at_13 <= '1';
			else at_13 <= '0';
			end if;
			
			if (hblock = 17 and vblock = 6) then at_14 <= '1';
			else at_14 <= '0';
			end if;
	
		end if;
	end process scan_at_button;
	
	
----------------------------------------------------------------------------------
-- 	5-	CONTROLE DE CORES 
----------------------------------------------------------------------------------	
	
	color_control : process (opcode_in, clk,at_UP, at_DOWN, at_LEFT, at_RIGHT, at_MID,at_1,
									at_2,at_3,at_4,at_5,at_6,at_7,at_8,at_9,at_10,at_11,at_12,at_13,at_14,
									state, score,ERROR_SCREEN,DEFAULT_SCREEN,WIN_SCREEN)
	variable TMPCOLOR : unsigned (7 downto 0);
	variable TMP_at : unsigned (17 downto 0);
	
	begin
	
		CASE state is
			when 15 =>
				VGA_COLOR <= ERROR_SCREEN;
			when 16 =>
				VGA_COLOR <= WIN_SCREEN;
			when others =>
				VGA_COLOR <= TMPCOLOR;
		END CASE;
						
					
		TMP_at := at_UP & at_DOWN & at_LEFT & at_RIGHT & at_1 & at_2 & at_3 & at_4 & at_5 & at_6 &
						at_7 & at_8 & at_9 & at_10 & at_11 & at_12 & at_13 & at_14;
		
		CASE TMP_at is
			when "100000000000000000" => --at_UP
				if opcode_in = "0010" then TMPCOLOR := GREEN;
				else TMPCOLOR := DEFAULT_SCREEN;
				end if;
				
			when "010000000000000000" => --at_DOWN
				if opcode_in = "0100" then TMPCOLOR := RED;
				else TMPCOLOR := DEFAULT_SCREEN;
				end if;
				
			when "001000000000000000" => --at_LEFT
				if opcode_in = "1000" then TMPCOLOR := BLUE;
				else TMPCOLOR := DEFAULT_SCREEN;
				end if;
				
			when "000100000000000000" => --at_RIGHT
				if opcode_in = "0001" then TMPCOLOR := YELLOW;
				else TMPCOLOR := DEFAULT_SCREEN;
				end if;
				
			when "000010000000000000" => --at_1
				if score >= 1 then TMPCOLOR := GREEN;
				else TMPCOLOR := DEFAULT_SCREEN;
				end if;
				
			when "000001000000000000" => --at_2
				if score >= 2 then TMPCOLOR := GREEN;
				else TMPCOLOR := DEFAULT_SCREEN;
				end if;
				
			when "000000100000000000" => --at_3
				if score >= 3 then TMPCOLOR := GREEN;
				else TMPCOLOR := DEFAULT_SCREEN;
				end if;
				
			when "000000010000000000" => --at_4
				if score >= 4 then TMPCOLOR := GREEN;
				else TMPCOLOR := DEFAULT_SCREEN;
				end if;
				
			when "000000001000000000" => --at_5
				if score >= 5 then TMPCOLOR := GREEN;
				else TMPCOLOR := DEFAULT_SCREEN;
				end if;
				
			when "000000000100000000" => --at_6
				if score >= 6 then TMPCOLOR := GREEN;
				else TMPCOLOR := DEFAULT_SCREEN;
				end if;
				
			when "000000000010000000" => --at_7
				if score >= 7 then TMPCOLOR := GREEN;
				else TMPCOLOR := DEFAULT_SCREEN;
				end if;
				
			when "000000000001000000" => --at_8
				if score >= 8 then TMPCOLOR := GREEN;
				else TMPCOLOR := DEFAULT_SCREEN;
				end if;
				
			when "000000000000100000" => --at_9
				if score >= 9 then TMPCOLOR := GREEN;
				else TMPCOLOR := DEFAULT_SCREEN;
				end if;
				
			when "000000000000010000" => --at_10
				if score >= 10 then TMPCOLOR := GREEN;
				else TMPCOLOR := DEFAULT_SCREEN;
				end if;
				
			when "000000000000001000" => --at_11
				if score >= 11 then TMPCOLOR := GREEN;
				else TMPCOLOR := DEFAULT_SCREEN;
				end if;
				
			when "000000000000000100" => --at_12
				if score >= 12 then TMPCOLOR := GREEN;
				else TMPCOLOR := DEFAULT_SCREEN;
				end if;
				
			when "000000000000000010" => --at_13
				if score >= 13 then TMPCOLOR := GREEN;
				else TMPCOLOR := DEFAULT_SCREEN;
				end if;
				
			when "000000000000000001" => --at_14
				if score >= 14 then TMPCOLOR := GREEN;
				else TMPCOLOR := DEFAULT_SCREEN;
				end if;
				
			when others => --white background
				TMPCOLOR := DEFAULT_SCREEN;
				
			
		
		END CASE;		
		
	end process color_control;
	
----------------------------------------------------------------------------------
-- 	6-	CONTROLADOR DO LAYOUT DA TELA DEFAULT
----------------------------------------------------------------------------------

	default_display : process (at_UP, at_DOWN, at_LEFT, at_RIGHT, at_MID, BACKGROUNDCOLOR)
	variable TMP_at : unsigned (4 downto 0);
	begin

		TMP_at := at_UP & at_DOWN & at_LEFT & at_RIGHT & at_MID;
		
		CASE TMP_at is
			when "10000" => --at_UP
				DEFAULT_SCREEN <= BLACK;
				
			when "01000" => --at_DOWN
				DEFAULT_SCREEN <= BLACK;
								
			when "00100" => --at_LEFT
				DEFAULT_SCREEN <= BLACK;
				
			when "00010" => --at_RIGHT
				DEFAULT_SCREEN <= BLACK;
				
			when "00001" => --at_MID
				DEFAULT_SCREEN <= GRAY;
			
			when others => --white background
				DEFAULT_SCREEN <= BACKGROUNDCOLOR;	
				
		END CASE;
	
	end process default_display;
	
	
----------------------------------------------------------------------------------
-- 	7-	CONTROLADOR DA TELA DE VITÓRIA E DA TELA DE DERROTA
----------------------------------------------------------------------------------	
	
	error_start_win : PROCESS (clk,opcode_in,DEFAULT_SCREEN)
	variable count : unsigned(26 downto 0);
	begin
	
		if rising_edge(clk) then		
			count := count + 1;						
		end if;
		
		if count(24) = '0' then
			ERROR_SCREEN <= RED; 
		else
			ERROR_SCREEN <= DEFAULT_SCREEN;
		end if;
		
		if count(24) = '0' then
			WIN_SCREEN <= GREEN; 
		else
			WIN_SCREEN <= DEFAULT_SCREEN;
		end if;
		
		BACKGROUNDCOLOR <= WHITE;
		
	end process error_start_win;

end Behavioral;

