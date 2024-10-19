-------------------------------------------------------------------------------
-- Title        : General constants
-- Project      : Integrated Systems Project
--                Reconfigurable IFFT/FFT Core R2^2SDF (Radix 2^2 Single Delay Feedback)
--                1K/2K/4K points
-------------------------------------------------------------------------------
-- File         : array_def.vhd
-- Authors      : Alessandro Colonna, Di Cugno Giovanni, Frache Stefano
--                <alessandro.colonna@studenti.polito.it>
-- Company      : Politecnico di Torino
-- Created      : 01/03/2009
-- Last update  : 20/05/2009
-- Platform     : Windows whith Emacs
-- Standard     : VHDL'87
-------------------------------------------------------------------------------
-- Description  : General constant
-- Copy Right   : Copyright (c) 2009 Alessandro Colonna
--
-- Revisions    :
-- Date          Version      Authors                     Description
--
-- 02/04/2009    2.0          Alessandro Colonna
--                            Di Cugno Giovanni
--                            Frache Stefano
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package array_def is

  constant  M        : integer := 2;
  constant  logM     : integer := 1;
  constant  NSTAGE   : integer := 6;
  constant  NBITINT  : integer := 32;
  constant  NBITIN   : integer := 8;
  constant  NBITTAP  : integer := 16;
  constant  NPOINTS  : integer := 4096;
  constant  N        : integer := NBITINT*2;

  type arr is array (M-1 downto 0) of std_logic_vector(N-1 downto 0);
  type arr_tap is array (NSTAGE-2 downto 0) of std_logic_vector(NBITTAP-1 downto 0);
  type bf_out is array (NSTAGE-1 downto 0) of std_logic_vector(NBITINT-1 downto 0);
  type cm_out is array (NSTAGE-2 downto 0) of std_logic_vector(NBITINT-1 downto 0);
  type bf_fifo is array (NSTAGE-1 downto 0) of std_logic_vector(NBITINT*2-1 downto 0);
  type data_fifo is array (NSTAGE*2-1 downto 0) of std_logic_vector(NBITINT*2-1 downto 0);

end array_def;

package body array_def is

end array_def;
