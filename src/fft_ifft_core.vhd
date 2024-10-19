-------------------------------------------------------------------------------
-- Title        : Fully structural desciption of FFTCore (Control Unit and Processing Unit)
-- Project      : Integrated Systems Project
--                Reconfigurable IFFT/FFT Core R2^2SDF (Radix 2^2 Single Delay Feedback)
--                1K/2K/4K points
-------------------------------------------------------------------------------
-- File         : FFT_IFFT_Core.vhd
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
-- 02/04/2009     2.0          Alessandro Colonna
--                             Di Cugno Giovanni
--                             Frache Stefano
-------------------------------------------------------------------------------

library ieee;
use work.array_def.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;


entity FFT_IFFT_Core is
--
--  generic (
--    NPOINTS          : integer ;
--    NSTAGE           : integer ;
--    NBITIN           : integer ;
--    NBITINT          : integer ;
--    NBITTAP          : integer );
  generic (
    NPOINTS          : integer :=4096;
    NSTAGE           : integer :=6;
    NBITIN           : integer :=8;
    NBITINT          : integer :=32;
    NBITTAP   	     : integer :=16);
  port (
    clk           : in  std_logic;
    rst 	  : in  std_logic;
    start 	  : in  std_logic;
    data_valid	  : out std_logic;
    fft_nifft     : in  std_logic;
    n_points 	  : in  std_logic_vector(1 downto 0);
    data_in_Re    : in  std_logic_vector(NBITIN-1 downto 0);
    data_in_Im    : in  std_logic_vector(NBITIN-1 downto 0);
    data_out_Re   : out std_logic_vector(NBITINT-1 downto 0);
    data_out_Im   : out std_logic_vector(NBITINT-1 downto 0));

end FFT_IFFT_Core;

architecture Behavioral of FFT_IFFT_Core is

component pu
  generic (
    NPOINTS          : integer;
    NSTAGE           : integer;
    NBITINT          : integer;
    NBITTAP   	     : integer;
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
    tap_in_Re 	  	: in  arr_tap;
    tap_in_Im 	  	: in  arr_tap;
    fft_nifft           : in  std_logic;  
    data_in_Re    	: in  std_logic_vector(NBITIN-1 downto 0);
    data_in_Im    	: in  std_logic_vector(NBITIN-1 downto 0);
    data_out_Re   	: out std_logic_vector(NBITINT-1 downto 0);
    data_out_Im   	: out std_logic_vector(NBITINT-1 downto 0)

    );
	 
end component;

component cu_and_phase_gen

  generic (
    NRAMPHASE   : integer;
    ADD_WIDTH   : integer;
    logNPOINTS  : integer);

  port(
    clk 	    	: in  std_logic;
    mux_1K   		: out std_logic;
    mux_2K   		: out std_logic;
    rst 	    	: in  std_logic;
    start 	 	: in  std_logic;
    data_valid          : out std_logic;
    n_points 		: in  std_logic_vector(1 downto 0);
    mux_sel_j		: out std_logic_vector(NRAMPHASE*2-1 downto 0);
    bfI_mux_sel         : out std_logic_vector(NRAMPHASE*2-1 downto 0);
    bfII_mux_sel        : out std_logic_vector(NRAMPHASE*2-1 downto 0);
    wr_en 		: out std_logic_vector(NSTAGE*2-1 downto 0);
    rd_en 		: out std_logic_vector(NSTAGE*2-1 downto 0);
    tap_Re 	 	: out arr_tap;
    tap_Im 	 	: out arr_tap);
          
end component;

signal int_wr_en, int_rd_en : std_logic_vector(11 downto 0);
signal int_bfI_mux_sel : std_logic_vector(NSTAGE-1 downto 0);
signal int_bfII_mux_sel : std_logic_vector(NSTAGE-1 downto 0);
signal int_bfII_mux_sel_j : std_logic_vector(NSTAGE-1 downto 0);
signal int_rst 	: std_logic_vector(NSTAGE*2-1 downto 0);
signal int_mux_sel_2K : std_logic;
signal int_mux_sel_1K : std_logic;
signal int_tap_Re : arr_tap;
signal int_tap_Im : arr_tap;

begin


  rst_conn : for i in 0 to NSTAGE*2-1 generate
    int_rst(i) <= rst;
  end generate rst_conn;
  
pu_inst : pu
  generic map (
    NPOINTS   => NPOINTS,
    NSTAGE    => NSTAGE,
    NBITINT   => NBITINT,
    NBITTAP   => NBITTAP,
    NBITIN    => NBITIN)
  port map (
    clk            => clk,
    bfI_mux_sel    => int_bfI_mux_sel,
    bfII_mux_sel   => int_bfII_mux_sel,
    bfII_mux_sel_j => int_bfII_mux_sel_j,
    mux_sel_2K     => int_mux_sel_2K,
    mux_sel_1K     => int_mux_sel_1K,
    wr_en	   => int_wr_en,
    rd_en          => int_rd_en,
    fft_nifft      => fft_nifft,
    rst            => int_rst,
    tap_in_Re 	   => int_tap_Re,
    tap_in_Im 	   => int_tap_Im,
    data_in_Re     => data_in_Re,
    data_in_Im     => data_in_Im,
    data_out_Re    => data_out_Re,
    data_out_Im    => data_out_Im);

cu_and_phase_gen_inst : cu_and_phase_gen
  generic map (
    NRAMPHASE    => 3,
    ADD_WIDTH    => 10,
    logNPOINTS   => 12)
  port map(
    clk          => clk,
    bfI_mux_sel	 => int_bfI_mux_sel,
    bfII_mux_sel => int_bfII_mux_sel,
    mux_sel_j 	 => int_bfII_mux_sel_j,
    mux_2K    	 => int_mux_sel_2K,
    mux_1K    	 => int_mux_sel_1K,
    rst          => rst,
    start        => start,
    data_valid   => data_valid,
    n_points     => n_points,
    wr_en	 => int_wr_en,
    rd_en        => int_rd_en,
    tap_Re 	 => int_tap_Re,
    tap_Im 	 => int_tap_Im);


end Behavioral;

