library ieee;
use ieee.std_logic_1164.all;

entity display is 
generic(
  clockFrequency      : integer := 26999999;
  switchRefreshPeriod : integer := 1
);
port(
  segment    : out std_logic_vector(7 downto 0); 
  display    : inout std_logic_vector(3 downto 0);
  clk        : in std_logic
);
end entity;

architecture rtl of display is 
  procedure incrementWrap(variable stateDisplay : inout std_logic_vector(7 downto 0);
                          constant wrap         : in    std_logic;
                          variable wrapped      : out   std_logic) is begin
    if wrap = '1' then
      wrapped := '0';
      case stateDisplay is
        when "00000011" =>
          stateDisplay := "10011111";
        when "10011111" =>
          stateDisplay := "00100101";
        when "00100101" =>
          stateDisplay := "00001101";
        when "00001101" =>
          stateDisplay := "10011001";
        when "10011001" =>
          stateDisplay := "01001001";
        when "01001001" =>
          stateDisplay := "11000001";
        when "11000001" =>
          stateDisplay := "00011111";
        when "00011111" =>
          stateDisplay := "00000001";
        when "00000001" =>
          stateDisplay := "00011001";
        when "00011001" =>
          stateDisplay := "00000011";
          wrapped := '1';
        when others =>
          stateDisplay := "11111111";
      end case;
    else
      wrapped := '0';
      stateDisplay := stateDisplay;
    end if;
  end procedure;
begin

  process(clk) is
    variable numDisp1    : std_logic_vector(7 downto 0) := "00000011";
    variable numDisp2    : std_logic_vector(7 downto 0) := "00000011";
    variable numDisp3    : std_logic_vector(7 downto 0) := "00000011";
    variable numDisp4    : std_logic_vector(7 downto 0) := "00000011";
    variable number      : std_logic_vector(7 downto 0) := "00000011";
    variable ticks       : integer := 0;
    variable seconds     : integer := 0;
    variable currDisplay : std_logic_vector(3 downto 0) := "1000";
    variable temp        : std_logic_vector(3 downto 0) := "1000";
    variable wrapped     : std_logic;
  begin
    if rising_edge(clk) then
      if seconds = clockFrequency then
        seconds := 0;
        incrementWrap(numDisp1, '1',     wrapped);
        incrementWrap(numDisp2, wrapped, wrapped);
        incrementWrap(numDisp3, wrapped, wrapped);
        incrementWrap(numDisp4, wrapped, wrapped);
        else
        seconds := seconds + 1;
      end if;
      if ticks = (switchRefreshPeriod * clockFrequency) / 1000 then
        ticks := 0;
        temp(3) := currDisplay(0);
        temp(2) := currDisplay(3);
        temp(1) := currDisplay(2);
        temp(0) := currDisplay(1);
        currDisplay := temp;
      else
        ticks := ticks + 1;
      end if;
      display <= currDisplay;
      case display is
        when "1000" =>
          number := numDisp1;
        when "0100" =>
          number := numDisp2;
        when "0010" =>
          number := numDisp3;
        when "0001" =>
          number := numDisp4;
        when others => number := "11111111";
      end case;
      segment <= number;  
    end if;
  end process;

end architecture;