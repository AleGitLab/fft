-------------------------------------------------------------------------------
-- Title        : Beh adder/subtractor
-- Project      : Integrated Systems Project
--                Reconfigurable IFFT/FFT Core R2^2SDF (Radix 2^2 Single Delay Feedback)
--                1K/2K/4K points
-------------------------------------------------------------------------------
-- File         : adder_sub.vhd
-- Authors      : Alessandro Colonna, Di Cugno Giovanni, Frache Stefano
--                <alessandro.colonna@studenti.polito.it>
-- Company      : Politecnico di Torino
-- Created      : 01/03/2009
-- Last update  : 20/05/2009
-- Platform     : Windows whith Emacs
-- Standard     : VHDL'87
-------------------------------------------------------------------------------
-- Description  : Beh adder/subtractor
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

entity adder_sub is
  
  generic (
    NBITDATA  : integer);           -- data size

  port (
    data1  : in  std_logic_vector(NBITDATA-1 downto 0);
    data2  : in  std_logic_vector(NBITDATA-1 downto 0);
    op     : in  std_logic;
    output : out std_logic_vector(NBITDATA-1 downto 0));

end adder_sub;

architecture beh of adder_sub is

signal output_i : std_logic_vector(NBITDATA downto 0);
signal int_data1, int_data2  : std_logic_vector(NBITDATA downto 0);

begin  -- beh

  sign_ext1: process (data1)
  begin  -- process sign_ext
    if data1(NBITDATA-1) = '1' then
      int_data1 <= '1' & data1;
    else
      int_data1 <= '0' & data1;
    end if;
  end process sign_ext1;


  sign_ext2: process (data2)
  begin  -- process sign_ext
    if data2(NBITDATA-1) = '1' then
      int_data2 <= '1' & data2;
    else
      int_data2 <= '0' & data2;
    end if;
  end process sign_ext2;


  -- purpose: instantiation of an adder-subtractor
  -- type   : combinational
  -- inputs : op, data1, data2
  -- outputs: output
  p_op: process (op, int_data1, int_data2)
  begin  -- process p_op
    if op='1' then
      output_i <= int_data1 - int_data2;
    else
      output_i <= int_data1 + int_data2;             
    end if;
  end process p_op;


  output <= output_i(NBITDATA downto 1);  -- most significant NBITDATA

end beh;
