library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- biblioteca de simulação
library UNISIM;
use UNISIM.VComponents.all;

entity vga_controller_640_60 is
port(
   rst         : in std_logic;
	
	clk50			: in std_logic;

   HS          : out std_logic;
   VS          : out std_logic;
   hcount      : out std_logic_vector(10 downto 0);
   vcount      : out std_logic_vector(10 downto 0);
   blank       : out std_logic
);
end vga_controller_640_60;

architecture Behavioral of vga_controller_640_60 is

----------------------------------------------------------------------------------
-- 	8-	DECLARAÇÃO DE CONSTANTES
----------------------------------------------------------------------------------

-- Valor máximo de contagem para o contador de pixels horizontal
constant HMAX  : std_logic_vector(10 downto 0) := "01100100000"; -- 800
-- Valor máximo de contagem para o contador de pixels vertical
constant VMAX  : std_logic_vector(10 downto 0) := "01000001101"; -- 525
-- Número total de colunas visiveis
constant HLINES: std_logic_vector(10 downto 0) := "01010000000"; -- 640
-- Valor do contador horizontal para quando chega ao limite da tela
constant HFP   : std_logic_vector(10 downto 0) := "01010001000"; -- 648
-- Valor do contador horizontal para quando acaba o pulso de sincronismo
constant HSP   : std_logic_vector(10 downto 0) := "01011101000"; -- 744
-- Número total de colunas visiveis
constant VLINES: std_logic_vector(10 downto 0) := "00111100000"; -- 480
-- Valor do contador vertical para quando chega ao limite da tela
constant VFP   : std_logic_vector(10 downto 0) := "00111100010"; -- 482
-- Valor do contador vertical para quando acaba o pulso de sincronismo
constant VSP   : std_logic_vector(10 downto 0) := "00111100100"; -- 484
-- Polaridade do pulso de sincronismo vertical e horizontal
constant SPP   : std_logic := '0';

----------------------------------------------------------------------------------
-- 	9-	DECLARAÇÃO DE SINAIS
----------------------------------------------------------------------------------

signal hcounter : std_logic_vector(10 downto 0) := (others => '0');
signal vcounter : std_logic_vector(10 downto 0) := (others => '0');

signal video_enable: std_logic;

signal en_25MHz : std_logic := '0'; 

----------------------------------------------------------------------------------
-- 	10- CONFIGURAÇÕES DE EXIBIÇÃO DE TELA
----------------------------------------------------------------------------------

begin

	en_25MHz <= not en_25MHz when rising_edge(clk50);

   hcount <= hcounter;
   vcount <= vcounter;

   -- blank quando estiver fora da área visível
	blank <= not video_enable;

   -- incrementa o contador horizontal à taxa do pixel_clk
   -- até que chege ao valor de HMAX, então reseta e continua contando
   h_count: process(clk50)
   begin
      if(rising_edge(clk50) and en_25Mhz = '1') then
         if(rst = '1') then
            hcounter <= (others => '0');
         elsif(hcounter = HMAX) then
            hcounter <= (others => '0');
         else
            hcounter <= hcounter + 1;
         end if;
      end if;
   end process h_count;

   -- incrementa o contador vertical à taxa do pixel_clk
   -- até que chege ao valor de VMAX, então reseta e continua contando
   v_count: process(clk50)
   begin
      if(rising_edge(clk50) and en_25Mhz = '1') then
         if(rst = '1') then
            vcounter <= (others => '0');
         elsif(hcounter = HMAX) then
            if(vcounter = VMAX) then
               vcounter <= (others => '0');
            else
               vcounter <= vcounter + 1;
            end if;
         end if;
      end if;
   end process v_count;

   -- gera o pulso horizontal de sincronismo
   -- quando ele estiver entre o limite da tela e o fim do pulso de sincronismo
	-- o HS é ativado (com polaridade SPP) para um total de 96 pixels.
   do_hs: process(clk50)
   begin
      if(rising_edge(clk50) and en_25Mhz = '1') then
         if(hcounter >= HFP and hcounter < HSP) then
            HS <= SPP;
         else
            HS <= not SPP;
         end if;
      end if;
   end process do_hs;

   -- gera o pulso vertical de sincronismo
   -- quando ele estiver entre o limite da tela e o fim do pulso de sincronismo   
   -- O VS é ativado (com polaridade SPP) para um toal de 2 linhas de video
   do_vs: process(clk50)
   begin
      if(rising_edge(clk50) and en_25Mhz = '1') then
         if(vcounter >= VFP and vcounter < VSP) then
            VS <= SPP;
         else
            VS <= not SPP;
         end if;
      end if;
   end process do_vs;
   
   -- exibe a saída de video quando o pixel estiver dentro da área visível da tela
   video_enable <= '1' when (hcounter < HLINES and vcounter < VLINES) else '0';

end Behavioral;