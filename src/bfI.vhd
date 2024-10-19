-------------------------------------------------------------------------------
-- Title        : Structural butterfly type I
-- Project      : Integrated Systems Project
--                Reconfigurable IFFT/FFT Core R2^2SDF (Radix 2^2 Single Delay Feedback)
--                1K/2K/4K points
-------------------------------------------------------------------------------
-- File         : bfI.vhd
-- Authors      : Alessandro Colonna, Di Cugno Giovanni, Frache Stefano
--                <alessandro.colonna@studenti.polito.it>
-- Company      : Politecnico di Torino
-- Created      : 01/03/2009
-- Last update  : 20/05/2009
-- Platform     : Windows whith Emacs
-- Standard     : VHDL'87
-------------------------------------------------------------------------------
-- Description  : Structural butterfly type I
-- Copy Right   : Copyright (c) 2009 Alessandro Colonna
--
-- Revisions    :
-- Date         Version      Authors                     Description
--
-- 02/04/2009   2.0          Alessandro Colonna
--                           Di Cugno Giovanni
--                           Frache Stefano
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

entity bfI is
  
  generic (
    NBITINT : integer);         -- internal precision of data (Re or Im)

  port (
    bfI_mux_sel         : in  std_logic;
    bfI_data_in 	: in  std_logic_vector(NBITINT*2-1 downto 0);
    mux_to_bfI   	: in  std_logic_vector(NBITINT*2-1 downto 0);
    bfI_data_out 	: out std_logic_vector(NBITINT*2-1 downto 0);
    bfI_to_mux   	: out std_logic_vector(NBITINT*2-1 downto 0));
	 
end bfI;

architecture struct of bfI is

  component Adder_Sub
    generic (
      NBITDATA : integer);

    port (
      data1  : in  std_logic_vector(NBITDATA-1 downto 0);
      data2  : in  std_logic_vector(NBITDATA-1 downto 0);
      op     : in  std_logic;
      output : out std_logic_vector(NBITDATA-1 downto 0));
  end component;

  signal int_add1, int_add2, int_add3, int_add4 : std_logic_vector(NBITINT-1 downto 0);
  signal int_add_plus, int_add_minus : std_logic_vector(NBITINT*2-1 downto 0);
  signal int_mux_to_bfI_Im, int_mux_to_bfI_Re, int_bfI_data_in_Im, int_bfI_data_in_Re : std_logic_vector(NBITINT-1 downto 0);
  
begin  -- struct


  int_mux_to_bfI_Im  <= mux_to_bfI(NBITINT*2-1 downto NBITINT);
  int_mux_to_bfI_Re  <= mux_to_bfI(NBITINT-1 downto 0);
  int_bfI_data_in_Im <= bfI_data_in(NBITINT*2-1 downto NBITINT);
  int_bfI_data_in_Re <= bfI_data_in(NBITINT-1 downto 0);
  int_add_plus       <= int_add1 & int_add2;
  int_add_minus      <= int_add3 & int_add4;

  Adder1 : adder_sub
    generic map (
      NBITDATA => NBITINT)
    port map (
      data1  => int_mux_to_bfI_Im,
      data2  => int_bfI_data_in_Im,
      op     => '0',
      output => int_add1);

  Adder2 : adder_sub
    generic map (
      NBITDATA => NBITINT)
    port map (
      data1  => int_mux_to_bfI_Re,
      data2  => int_bfI_data_in_Re,
      op     => '0',
      output => int_add2);

  Adder3 : adder_sub
    generic map (
      NBITDATA => NBITINT)
    port map (
      data1  => int_mux_to_bfI_Im,
      data2  => int_bfI_data_in_Im,
      op     => '1',
      output => int_add3);

  Adder4 : adder_sub
    generic map (
      NBITDATA => NBITINT)
    port map (
      data1  => int_mux_to_bfI_Re,
      data2  => int_bfI_data_in_Re,
      op     => '1',
      output => int_add4);

--
-- OUTPUT MUXs
--
  
-- Mux FIFO
with bfI_mux_sel select
  bfI_to_mux <=
  bfI_data_in           when '0',
  int_add_minus         when others;

-- Mux data
with bfI_mux_sel select
  bfI_data_out <=
  mux_to_bfI            when '0',
  int_add_plus          when others;
 
end struct;
