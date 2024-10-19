-------------------------------------------------------------------------------
-- Title        : Structural complex multiplier
-- Project      : Integrated Systems Project
--                Reconfigurable IFFT/FFT Core R2^2SDF (Radix 2^2 Single Delay Feedback)
--                1K/2K/4K points
-------------------------------------------------------------------------------
-- File         : complex_mult.vhd
-- Authors      : Alessandro Colonna, Di Cugno Giovanni, Frache Stefano
--                <alessandro.colonna@studenti.polito.it>
-- Company      : Politecnico di Torino
-- Created      : 01/03/2009
-- Last update  : 20/05/2009
-- Platform     : Windows whith Emacs
-- Standard     : VHDL'87
-------------------------------------------------------------------------------
-- Description  : Structural complex multiplier
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

entity complex_mult is
  
  generic (
    NBITINT     : integer;          -- data size
    NBITTAP     : integer           -- internal precision of data (Re or Im)
);
	 
  port (
    tap_in_Re   : in  std_logic_vector(NBITTAP-1 downto 0);             -- imaginary part tap input
    tap_in_Im   : in  std_logic_vector(NBITTAP-1 downto 0);             -- real part tap input
    mult_in     : in  std_logic_vector(NBITINT*2-1 downto 0);           -- data input ( most significant imaginary part)
    clk         : in  std_logic;                                        -- clock signal
    rst         : in  std_logic;                                        -- reset signal
    data_out    : out std_logic_vector(NBITINT*2-1 downto 0));  	-- data output (most significant imaginary part)

end complex_mult;

architecture struct of complex_mult is

  component adder_sub_norm
    generic (
      NBITDATA  : integer);           -- data size
    port (
      data1  : in  std_logic_vector(NBITDATA-1 downto 0);
      data2  : in  std_logic_vector(NBITDATA-1 downto 0);
      op     : in  std_logic;
      output : out std_logic_vector(NBITDATA-1 downto 0));
  end component;

  component multiplier
    generic (
      NBITTAP : integer;                  -- tap size (normalized form)
      NBITINT : integer);                 -- internal data size (normalized form)
    port (
      clk    : in  std_logic;
      tap    : in  std_logic_vector(NBITTAP-1 downto 0);
      data   : in  std_logic_vector(NBITINT-1 downto 0);
      output : out std_logic_vector(NBITINT-1 downto 0));
  end component;

  signal int_mult_in_Re, int_mult_in_Im : std_logic_vector(NBITINT-1 downto 0);
  signal int_data_out_Re, int_data_out_Im : std_logic_vector(NBITINT-1 downto 0);
  
  -- first stage signals
  signal int_mult1_i : std_logic_vector(NBITINT-1 downto 0);
  signal int_mult2_i : std_logic_vector(NBITINT-1 downto 0);
  signal int_mult3_i : std_logic_vector(NBITINT-1 downto 0);
  signal int_mult4_i : std_logic_vector(NBITINT-1 downto 0);

  -- second stage signals
  signal int_mult1_ii : std_logic_vector(NBITINT-1 downto 0);
  signal int_mult2_ii : std_logic_vector(NBITINT-1 downto 0);
  signal int_mult3_ii : std_logic_vector(NBITINT-1 downto 0);
  signal int_mult4_ii : std_logic_vector(NBITINT-1 downto 0);

  
begin  -- struct
  

  int_mult_in_Re <= mult_in(NBITINT-1 downto 0);
  int_mult_in_Im <= mult_in(NBITINT*2-1 downto NBITINT);
  
  Mult1 : multiplier
    generic map (
      NBITTAP  => NBITTAP,
      NBITINT  => NBITINT)
    port map (
      tap    => tap_in_Re,
      data   => int_mult_in_Re,
      output => int_mult1_i,
      clk    => clk);

  Mult2 : multiplier
    generic map (
      NBITTAP  => NBITTAP,
      NBITINT  => NBITINT)
    port map (
      tap    => tap_in_Im,
      data   => int_mult_in_Im,
      output => int_mult2_i,
      clk    => clk);

  Mult3 : multiplier
    generic map (
      NBITTAP  => NBITTAP,
      NBITINT  => NBITINT)
    port map (
      tap    => tap_in_Re,
      data   => int_mult_in_Im,
      output => int_mult3_i,
      clk    => clk);

  Mult4 : multiplier
    generic map (
      NBITTAP  => NBITTAP,
      NBITINT  => NBITINT)
    port map (
      tap    => tap_in_Im,
      data   => int_mult_in_Re,
      output => int_mult4_i,
      clk    => clk);
--
-- Real Part Adder
--
  Add1 : adder_sub_norm
    generic map (
      NBITDATA => NBITINT)
    port map (
      data1  => int_mult1_ii,
      data2  => int_mult2_ii,
      op     => '1',
      output => int_data_out_Re);

--
-- Imaginary Part Adder
--
  Add2 : adder_sub_norm
    generic map (
      NBITDATA => NBITINT)
    port map (
      data1  => int_mult3_ii,
      data2  => int_mult4_ii,
      op     => '0',
      output => int_data_out_Im);

--
-- FF from multipliers to adders
--
  ff_inst: process (clk, rst)
  begin  -- process ff_inst
    if rst = '0' then                     -- asynchronous reset (active low)
      int_mult1_ii <= (others=>'0');
      int_mult2_ii <= (others=>'0');
      int_mult3_ii <= (others=>'0');
      int_mult4_ii <= (others=>'0');     
    elsif clk'event and clk = '1' then    -- rising clock edge
      int_mult1_ii <= int_mult1_i;
      int_mult2_ii <= int_mult2_i;
      int_mult3_ii <= int_mult3_i;
      int_mult4_ii <= int_mult4_i;   
    end if;
  end process ff_inst;

  data_out(NBITINT*2-1 downto NBITINT) <= int_data_out_Im;
  data_out(NBITINT-1 downto 0) <= int_data_out_Re;


end struct;
