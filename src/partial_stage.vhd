-------------------------------------------------------------------------------
-- Title        : Structural description of last processing stage
-- Project      : Integrated Systems Project
--                Reconfigurable IFFT/FFT Core R2^2SDF (Radix 2^2 Single Delay Feedback)
--                1K/2K/4K points
-------------------------------------------------------------------------------
-- File         : partial_stage.vhd
-- Authors      : Alessandro Colonna, Di Cugno Giovanni, Frache Stefano
--                <alessandro.colonna@studenti.polito.it>
-- Company      : Politecnico di Torino
-- Created      : 01/03/2009
-- Last update  : 30/04/2009
-- Platform     : Windows whith Emacs
-- Standard     : VHDL'87
-------------------------------------------------------------------------------
-- Description  : Structural description of last processing stage
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


entity partial_stage is
  generic (
    NBITINT       : integer;
    NBITTAP       : integer);

  port (
    clk                 : in  std_logic;
    rst                 : in  std_logic;
    mux_sel_2K       	: in  std_logic;
    bfI_mux_sel         : in  std_logic;
    bfII_mux_sel        : in  std_logic;
    bfII_mux_sel_j      : in  std_logic;
    bfI_data_in         : in  std_logic_vector(NBITINT*2-1 downto 0);	 
    mux_to_bfI          : in  std_logic_vector(NBITINT*2-1 downto 0);
    mux_to_bfII         : in  std_logic_vector(NBITINT*2-1 downto 0);
    bfI_to_mux          : out std_logic_vector(NBITINT*2-1 downto 0);
    bfII_to_mux         : out std_logic_vector(NBITINT*2-1 downto 0);
    cm_data_out         : out std_logic_vector(NBITINT*2-1 downto 0));

end partial_stage;

architecture struct of partial_stage is

component bfI
  generic (
    NBITINT : integer);         -- internal precision of data (Re or Im)
  port (
    bfI_mux_sel         : in  std_logic;
    bfI_data_in 	: in  std_logic_vector(NBITINT*2-1 downto 0);
    mux_to_bfI   	: in  std_logic_vector(NBITINT*2-1 downto 0);
    bfI_data_out 	: out std_logic_vector(NBITINT*2-1 downto 0);
    bfI_to_mux   	: out std_logic_vector(NBITINT*2-1 downto 0));
	 
end component;

component bfII
  generic (
    NBITINT : integer);         -- internal precision of data (Re or Im)
  port (
    bfII_mux_sel    	: in  std_logic;
    bfII_mux_sel_j 	: in  std_logic;
    bfII_data_in        : in  std_logic_vector(NBITINT*2-1 downto 0);
    mux_to_bfII         : in  std_logic_vector(NBITINT*2-1 downto 0);
    bfII_data_out 	: out std_logic_vector(NBITINT*2-1 downto 0);
    bfII_to_mux     	: out std_logic_vector(NBITINT*2-1 downto 0));

end component;


-- signal definitions
signal bfI_to_bfII_i  	: std_logic_vector(NBITINT*2-1 downto 0);
signal bfI_to_bfII_ii 	: std_logic_vector(NBITINT*2-1 downto 0);
signal int_mux_data_out : std_logic_vector(NBITINT*2-1 downto 0);

begin  -- struct

BF_I : bfI generic map (
  NBITINT => NBITINT)
  port map (
    bfI_mux_sel  => bfI_mux_sel,
    bfI_data_in  => bfI_data_in,
    mux_to_bfI   => mux_to_bfI,
    bfI_data_out => bfI_to_bfII_i,
    bfI_to_mux   => bfI_to_mux);

BF_II : bfII generic map (
  NBITINT => NBITINT)
  port map (
    bfII_mux_sel_j => bfII_mux_sel_j,
    bfII_mux_sel   => bfII_mux_sel,
    bfII_data_in   => bfI_to_bfII_ii,
    mux_to_bfII    => mux_to_bfII,
    bfII_data_out  => int_mux_data_out,
    bfII_to_mux    => bfII_to_mux);



stage_ff: process (clk, rst)
 begin  -- process stage_ff
   if rst = '0' then                  -- asynchronous reset (active low)
     bfI_to_bfII_ii <= (others => '0');
   elsif clk'event and clk = '1' then   -- rising clock edge
     bfI_to_bfII_ii <= bfI_to_bfII_i;
   end if;
 end process stage_ff;

--
-- Mux bypass 2K (Last Stage)
--
last_stage_mux_bypass : process (mux_sel_2K, int_mux_data_out, bfI_to_bfII_ii)
begin  -- process mux_2K_bypass
  if mux_sel_2K = '0' then
    cm_data_out <= int_mux_data_out;
  else 
    cm_data_out <= bfI_to_bfII_ii; 
  end if;
end process last_stage_mux_bypass;  

end struct;


