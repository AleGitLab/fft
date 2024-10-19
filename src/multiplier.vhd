-------------------------------------------------------------------------------
-- Title        : Beh pipelined multiplier
-- Project      : Integrated Systems Project
--                Reconfigurable IFFT/FFT Core R2^2SDF (Radix 2^2 Single Delay Feedback)
--                1K/2K/4K points
-------------------------------------------------------------------------------
-- File         : multiplier.vhd
-- Authors      : Alessandro Colonna, Di Cugno Giovanni, Frache Stefano
--                <alessandro.colonna@studenti.polito.it>
-- Company      : Politecnico di Torino
-- Created      : 01/03/2009
-- Last update  : 20/04/2009
-- Platform     : Windows whith Emacs
-- Standard     : VHDL'87
-------------------------------------------------------------------------------
-- Description  : Beh pipelined multiplier
-- Copy Right   : Copyright (c) 2009 Alessandro Colonna
--
-- Revisions    :
-- Date         Version      Authors                     Description
--
-- 02/04/2009   1.0          Alessandro Colonna
--                           Di Cugno Giovanni
--                           Frache Stefano
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

entity multiplier is
  
  generic (
    NBITTAP : integer;                  -- tap size (normalized form)
    NBITINT : integer);                 -- internal data size (normalized form)

  port (
    clk    : in  std_logic;
    tap    : in  std_logic_vector(NBITTAP-1 downto 0);
    data   : in  std_logic_vector(NBITINT-1 downto 0);
    output : out std_logic_vector(NBITINT-1 downto 0));

end multiplier;


architecture beh of multiplier is
  
  constant NPIPES : integer := (NBITTAP/18 + NBITINT/18 + 1);
  type array_pipe is array (0 to NPIPES-1) of std_logic_vector(NBITINT-1 downto 0);
  signal int_pipes : array_pipe;
  signal product : std_logic_vector(NBITINT+NBITTAP-1 downto 0);
  
begin  -- beh

  
  product <= tap * data;
	
  mult_pipe: process (clk)
  begin  -- process first
    if clk'event and clk = '1' then  -- rising clock edge
      int_pipes(0) <= product(NBITINT+NBITTAP-2 downto NBITTAP-1); -- Because we have two bits of sign (or NBITTAP-1 of fractional part)
      for i in 1 to NPIPES-1 loop
        int_pipes(i) <= int_pipes(i-1);
      end loop;  -- i
    end if;
  end process mult_pipe;


output <= int_pipes(NPIPES-1);


end beh;
