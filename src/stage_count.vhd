-------------------------------------------------------------------------------
-- Title        : Behavioral desciption of stage counter for memory phase 
--                addressing and control signal generation
-- Project      : Integrated Systems Project
--                Reconfigurable IFFT/FFT Core R2^2SDF 
--                (Radix 2^2 Single Delay Feedback) 1K/2K/4K points
-------------------------------------------------------------------------------
-- File         : stage_count.vhd
-- Authors      : Alessandro Colonna, Di Cugno Giovanni, Frache Stefano
--                <alessandro.colonna@studenti.polito.it>
-- Company      : Politecnico di Torino
-- Created      : 01/03/2009
-- Last update  : 20/05/2009
-- Platform     : Windows whith Emacs
-- Standard     : VHDL'87
-------------------------------------------------------------------------------
-- Description  : Behavioral desciption of stage counter for memory phase 
--                addressing and control signal generation
-- Copy Right   : Copyright (c) 2009 Alessandro Colonna
--
-- Revisions    :
-- Date           Version      Authors                     Description
--
-- 02/04/2009     2.0          Alessandro Colonna
--                             Di Cugno Giovanni
--                             Frache Stefano
-------------------------------------------------------------------------------
library ieee;
use work.array_def.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity stage_count is

    generic (
      NBITTC           : integer;
      NBITINCREMENT    : integer;
      logNWORDS        : integer);
    port (
      counters_start   : in  std_logic;
      bf_start         : in  std_logic;
      ck               : in  std_logic;
      reset            : in  std_logic;
      mux_sel_j        : out std_logic;
      bfI_mux_sel      : out std_logic;
      bfII_mux_sel     : out std_logic;
      terminal_count   : in  std_logic_vector(NBITTC-1 downto 0);
      bin_count        : out std_logic_vector(logNWORDS-1 downto 0));
  
end stage_count;

architecture beh of stage_count is

signal count_iii : std_logic_vector(NBITTC-1 downto 0);
signal count_ii : std_logic_vector(NBITTC-2 downto 0);
signal count_i : std_logic_vector(logNWORDS-1 downto 0) := (others => '0');
signal increment : std_logic_vector (1 downto 0) := (others => '0');
signal increment_shift : std_logic_vector(NBITINCREMENT-1 downto 0);
signal int_mux_sel_j : std_logic := '0';
signal int_bfI_mux_sel : std_logic := '0';
signal int_bfII_mux_sel : std_logic := '0';
signal flag1 : std_logic := '0';
signal flag2 : std_logic := '0';

begin  -- beh


counter_phase: process (ck, reset)


begin  -- process counter_p
  if reset = '0' then                   -- asynchronous reset (active low)
    count_i<=(others=>'0');
    count_ii<=(others=>'0');
  elsif ck'event and ck = '1' then      -- rising clock edge
    if counters_start ='1' then
      if conv_integer(count_ii) = (conv_integer(terminal_count)-1)/2 and increment = "11" then
        count_i  <= (others=>'0');
        count_ii <= (others=>'0');
        increment <= "00";
      elsif conv_integer(count_ii) = (conv_integer(terminal_count)-1)/2  and increment = "00" then  
        count_i  <= (others=>'0');
        count_ii <= (others=>'0');
        increment <= "10";
      elsif conv_integer(count_ii) = (conv_integer(terminal_count)-1)/2  and increment = "10" then  
        count_i  <= (others=>'0');
        count_ii <= (others=>'0');
        increment <= "01";
      elsif conv_integer(count_ii) = (conv_integer(terminal_count)-1)/2  and increment = "01" then  
        count_i  <= (others=>'0');
        count_ii <= (others=>'0');
        increment <= "11";
      else
        count_i<=count_i+increment_shift;
        count_ii<=count_ii+1;
      end if;
    end if;
  end if;
end process counter_phase;

counter_mux_bf: process (ck, reset)

begin  -- process counter_p
  if reset = '0' then                   -- asynchronous reset (active low)
    count_iii<=(others=>'0');
  elsif ck'event and ck = '1' then      -- rising clock edge
    if bf_start ='1' then
      if conv_integer(count_iii) = conv_integer(terminal_count) then
        int_bfI_mux_sel <= not(int_bfI_mux_sel);
        count_iii <= (others => '0');
        if flag2 = '0' then
          flag2 <= '1';
        else
          int_bfII_mux_sel <= '0';
          int_mux_sel_j <= '0';
        end if;
      elsif conv_integer(count_iii) = ((conv_integer(terminal_count)-1)/2) then 
        count_iii<=count_iii+1;
        if flag2 = '1' then
          int_bfII_mux_sel <= '1';
        end if;
        if int_bfI_mux_sel = '0' then
          if flag1 = '1' then
            int_mux_sel_j <= '1';
          else
            flag1 <= '1';
          end if;
        end if;
      else
        count_iii<=count_iii+1;
      end if;
    end if;
  end if;
end process counter_mux_bf;


ff_stage: process (ck, reset) -- one FF delay 

begin  -- process ff_stage
  if reset = '0' then	 -- asynchronous reset (active low)
    mux_sel_j <='0';
    bfII_mux_sel <= '0';
  elsif ck'event and ck = '1' then  -- rising clock edge
    mux_sel_j <= int_mux_sel_j;
    bfII_mux_sel <= int_bfII_mux_sel;
  end if;
end process ff_stage;

bfI_mux_sel <= int_bfI_mux_sel;

shift_gen_1 : if NBITINCREMENT = 2 generate 
  increment_shift <= increment;
end generate shift_gen_1;

shift_gen_2 : if NBITINCREMENT /= 2 generate 
  increment_shift(NBITINCREMENT-1 downto NBITINCREMENT-2)<= increment;
  increment_shift(NBITINCREMENT-3 downto 0) <= (others => '0');
end generate shift_gen_2;

bin_count<=count_i;

end beh;
