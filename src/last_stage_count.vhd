-------------------------------------------------------------------------------
-- Title        : Structural desciption of last stage counter
-- Project      : Integrated Systems Project
--                Reconfigurable IFFT/FFT Core R2^2SDF (Radix 2^2 Single Delay Feedback)
--                1K/2K/4K points
-------------------------------------------------------------------------------
-- File         : last_stage_count.vhd
-- Authors      : Alessandro Colonna, Di Cugno Giovanni, Frache Stefano
--                <alessandro.colonna@studenti.polito.it>
-- Company      : Politecnico di Torino
-- Created      : 01/03/2009
-- Last update  : 20/05/2009
-- Platform     : Windows whith Emacs
-- Standard     : VHDL'87
-------------------------------------------------------------------------------
-- Description  : Structural desciption of last stage counter
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

entity last_stage_count is

    port (
      bf_start         : in  std_logic;
      ck               : in  std_logic;
      reset            : in  std_logic;
      mux_sel_j        : out std_logic;
      bfI_mux_sel      : out std_logic;
      bfII_mux_sel     : out std_logic);
  
end last_stage_count;

architecture beh of last_stage_count is

signal count_i : std_logic_vector(1 downto 0);
signal int_mux_sel_j : std_logic := '0';
signal int_bfI_mux_sel : std_logic := '0';
signal int_bfII_mux_sel : std_logic := '0';
signal flag1 : std_logic := '0';

begin  -- beh

counter_mux_bf: process (ck, reset)
  
begin  -- process counter_p
  if reset = '0' then                   -- asynchronous reset (active low)
    count_i<=(others=>'0');
  elsif ck'event and ck = '1' then      -- rising clock edge
    if bf_start ='1' then
      if conv_integer(count_i) = 1 then
        int_bfI_mux_sel <= '1';
        count_i <= count_i + 1;
        if flag1 = '1' then
          int_bfII_mux_sel <= '0';
          int_mux_sel_j <= '0';
        end if;
      elsif conv_integer(count_i) = 3 then -- delay of one FF
        int_bfI_mux_sel <= '0';
        count_i <= (others => '0');
        int_bfII_mux_sel <= '0';
      elsif conv_integer(count_i) = 0 then  --delay of one ff
        if flag1 = '1' then
          int_bfII_mux_sel <= '1';
          int_mux_sel_j <= '1';
        else
          flag1 <= '1';
        end if;
        count_i<=count_i+1;
      else -- 2
        count_i<=count_i+1;
        if flag1 = '1' then
          int_bfII_mux_sel <= '1';
        end if;
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

end beh;
