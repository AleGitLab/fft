-------------------------------------------------------------------------------
-- Title        : Beh normalized adder/subtractor
-- Project      : Integrated Systems Project
--                Reconfigurable IFFT/FFT Core R2^2SDF (Radix 2^2 Single Delay Feedback)
--                1K/2K/4K points
-------------------------------------------------------------------------------
-- File         : adder_sub_norm.vhd
-- Authors      : Alessandro Colonna, Di Cugno Giovanni, Frache Stefano
--                <alessandro.colonna@studenti.polito.it>
-- Company      : Politecnico di Torino
-- Created      : 01/03/2009
-- Last update  : 20/05/2009
-- Platform     : Windows whith Emacs
-- Standard     : VHDL'87
-------------------------------------------------------------------------------
-- Description  : Beh normalized adder/subtractor
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
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

entity adder_sub_norm is
  
  generic (
    NBITDATA  : integer);           -- data size

  port (
    data1  : in  std_logic_vector(NBITDATA-1 downto 0);
    data2  : in  std_logic_vector(NBITDATA-1 downto 0);
    op     : in  std_logic;
    output : out std_logic_vector(NBITDATA-1 downto 0));

end adder_sub_norm;

architecture beh of adder_sub_norm is

signal output_i : std_logic_vector(NBITDATA downto 0);

begin  -- beh

  -- purpose: instantiation of an adder-subtractor
  -- type   : combinational
  -- inputs : op, data1, data2
  -- outputs: output
  p_op: process (op, data1, data2)
  begin  -- process p_op
    if op='1' then
      output <= data1 - data2;
    else
      output <= data1 + data2;             
    end if;
  end process p_op;

end beh;
