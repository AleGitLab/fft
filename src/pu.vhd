-------------------------------------------------------------------------------
-- Title        : Structural desciption of butterflies, bypass logic and FIFOs
-- Project      : Integrated Systems Project
--                Reconfigurable IFFT/FFT Core R2^2SDF (Radix 2^2 Single Delay Feedback)
--                1K/2K/4K points
-------------------------------------------------------------------------------
-- File         : pu.vhd
-- Authors      : Alessandro Colonna, Di Cugno Giovanni, Frache Stefano
--                <alessandro.colonna@studenti.polito.it>
-- Company      : Politecnico di Torino
-- Created      : 01/03/2009
-- Last update  : 20/05/2009
-- Platform     : Windows whith Emacs
-- Standard     : VHDL'87
-------------------------------------------------------------------------------
-- Description  : Structural desciption of butterflies, bypass logic and FIFOs
-- Copy Right   : Copyright (c) 2009 Alessandro Colonna
--
-- Revisions    :
-- Date           Version      Authors                     Description
--
-- 02/04/2009     1.0          Alessandro Colonna
--                             Di Cugno Giovanni
--                             Frache Stefano
-------------------------------------------------------------------------------

library ieee;
use work.array_def.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

entity pu is
  generic (
    NPOINTS          : integer ;
    NSTAGE           : integer ;
    NBITINT          : integer ;
    NBITTAP   	     : integer ;
    NBITIN           : integer);

  port (
    clk           	: in  std_logic;
    bfI_mux_sel   	: in  std_logic_vector(NSTAGE-1 downto 0);
    bfII_mux_sel   	: in  std_logic_vector(NSTAGE-1 downto 0);
    bfII_mux_sel_j 	: in  std_logic_vector(NSTAGE-1 downto 0);
    mux_sel_2K    	: in  std_logic;
    mux_sel_1K    	: in  std_logic;
    wr_en 		: in  std_logic_vector(NSTAGE*2-1 downto 0);
    rd_en 		: in  std_logic_vector(NSTAGE*2-1 downto 0);
    rst   		: in  std_logic_vector(NSTAGE*2-1 downto 0);
    fft_nifft           : in  std_logic;
    tap_in_Re 	  	: in  arr_tap;
    tap_in_Im 	  	: in  arr_tap;
    data_in_Re    	: in  std_logic_vector(NBITIN-1 downto 0);
    data_in_Im    	: in  std_logic_vector(NBITIN-1 downto 0);
    data_out_Re   	: out std_logic_vector(NBITINT-1 downto 0);
    data_out_Im   	: out std_logic_vector(NBITINT-1 downto 0));
	 
end pu;


architecture struct of pu is

signal int_from_bfI, int_from_bfII, int_to_bfI, int_to_bfII : bf_fifo;
  
component datapath
  
  generic (
    NSTAGE           : integer;
    NBITINT          : integer;
    NBITTAP   	     : integer;
    NBITIN           : integer);

  port (
    clk           	: in  std_logic;
    rst           	: in  std_logic;
    bfI_mux_sel 	: in  std_logic_vector(NSTAGE-1 downto 0);
    bfII_mux_sel 	: in  std_logic_vector(NSTAGE-1 downto 0);
    bfII_mux_sel_j 	: in  std_logic_vector(NSTAGE-1 downto 0);
    tap_in_Re 	  	: in  arr_tap;
    tap_in_Im 	  	: in  arr_tap;
    mux_sel_2K    	: in  std_logic;
    mux_sel_1K    	: in  std_logic;
    fft_nifft           : in  std_logic;
    dp_to_bfI   	: in  bf_fifo; 
    dp_to_bfII   	: in  bf_fifo; 
    dp_from_bfI  	: out bf_fifo;
    dp_from_bfII 	: out bf_fifo;
    data_in_Re    	: in  std_logic_vector(NBITIN-1 downto 0);
    data_in_Im    	: in  std_logic_vector(NBITIN-1 downto 0);
    data_out_Re   	: out std_logic_vector(NBITINT-1 downto 0);
    data_out_Im   	: out std_logic_vector(NBITINT-1 downto 0));
  
end component;

component fifos_and_muxes  
  generic (
    NPOINTS : integer ;
    NSTAGE  : integer ;
    NBITINT : integer );

  port (
    clk   		: in  std_logic;
    rd_en 		: in  std_logic_vector(NSTAGE*2-1 downto 0);
    rst   		: in  std_logic_vector(NSTAGE*2-1 downto 0);
    wr_en 		: in  std_logic_vector(NSTAGE*2-1 downto 0);
    mux_sel_2K          : in  std_logic;
    from_bfI            : in  bf_fifo; 
    from_bfII           : in  bf_fifo; 
    to_bfI 		: out bf_fifo;
    to_bfII             : out bf_fifo);

end component;


begin

mem_inst : fifos_and_muxes
  generic map (
    NPOINTS => NPOINTS,
    NSTAGE  => NSTAGE,
    NBITINT => NBITINT)
  port map (
    clk         => clk,
    rd_en       => rd_en,
    rst         => rst,
    wr_en       => wr_en,
    mux_sel_2K  => mux_sel_2K,
    from_bfI  	=> int_from_bfI,
    from_bfII   => int_from_bfII,
    to_bfI      => int_to_bfI,
    to_bfII      => int_to_bfII);


datapath_inst : Datapath
  generic map (
    NSTAGE  => NSTAGE,
    NBITINT => NBITINT,
    NBITTAP => NBITTAP,
    NBITIN  => NBITIN)
  port map (
    clk            => clk,
    rst            => rst(0),
    bfI_mux_sel    => bfI_mux_sel,
    bfII_mux_sel   => bfII_mux_sel,
    bfII_mux_sel_j => bfII_mux_sel_j,
    tap_in_Re      => tap_in_Re,
    tap_in_Im      => tap_in_Im,
    mux_sel_2K     => mux_sel_2K,
    mux_sel_1K     => mux_sel_1K,
    fft_nifft      => fft_nifft,
    dp_to_bfI      => int_to_bfI,
    dp_to_bfII     => int_to_bfII, 
    dp_from_bfI    => int_from_bfI,
    dp_from_bfII   => int_from_bfII,
    data_in_Re     => data_in_Re,
    data_in_Im     => data_in_Im,
    data_out_Re    => data_out_Re,
    data_out_Im    => data_out_Im);     	 	 
  
end struct;
