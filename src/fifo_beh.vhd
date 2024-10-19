-------------------------------------------------------------------------------
-- Title        : Beh description of FIFO
-- Project      : Integrated Systems Project
--                Reconfigurable IFFT/FFT Core R2^2SDF (Radix 2^2 Single Delay Feedback)
--                1K/2K/4K points
-------------------------------------------------------------------------------
-- File         : fifo_beh.vhd
-- Authors      : Alessandro Colonna, Di Cugno Giovanni, Frache Stefano
--                <alessandro.colonna@studenti.polito.it>
-- Company      : Politecnico di Torino
-- Created      : 01/03/2009
-- Last update  : 20/05/2009
-- Platform     : Windows whith Emacs
-- Standard     : VHDL'87
-------------------------------------------------------------------------------
-- Description  : Beh description of FIFO
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
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;


entity fifo_beh is
  
  generic (
    NBITINT    : integer;
    NWORDS     : integer);

  port (
    clk          : in  std_logic;
    rst          : in  std_logic;
    rd_en        : in  std_logic;
    wr_en        : in  std_logic;
    din          : in  std_logic_vector(NBITINT-1 downto 0);
    dout         : out std_logic_vector(NBITINT-1 downto 0));

end fifo_beh;

architecture beh of fifo_beh is

  type array_signal is array (0 to NWORDS-1) of std_logic_vector(NBITINT-1 downto 0);
  signal int_signal : array_signal := (others=>(others=>'0'));
  
begin  -- beh

-- purpose: FIFO process
-- type   : sequential
-- inputs : clk, rst, din, start
-- outputs: dout
fifo_inst: process (clk, rst)

begin  -- process fifo_inst

  if rst = '0' then                   -- asynchronous reset (active low)
    for i in 0 to NWORDS-1 loop 
      int_signal(i) <= (others => '0');
    end loop;    -- i
  elsif (clk'event and clk = '1') then      -- rising clock edge
    if rd_en = '1' and wr_en = '1' then
      int_signal(0) <= din;
      for i in 1 to NWORDS-1 loop
        int_signal(i) <= int_signal(i-1);
      end loop;  -- i
--
--elsif rd_en = '1' and wr_en = '0' then
--    int_signal(NWORDS-1) <= int_signal(NWORDS-2); 
    elsif rd_en = '0' and wr_en = '1' then
      int_signal(0) <= din;
    end if;
  end if;
end process fifo_inst;

dout <= int_signal(NWORDS-1); 

end beh;

