-------------------------------------------------------------------------------
-- Title        : Structural desciption of all stages
-- Project      : Integrated Systems Project
--                Reconfigurable IFFT/FFT Core R2^2SDF (Radix 2^2 Single Delay Feedback)
--                1K/2K/4K points
-------------------------------------------------------------------------------
-- File         : datapath.vhd
-- Authors      : Alessandro Colonna, Di Cugno Giovanni, Frache Stefano
--                <alessandro.colonna@studenti.polito.it>
-- Company      : Politecnico di Torino
-- Created      : 01/03/2009
-- Last update  : 20/05/2009
-- Platform     : Windows whith Emacs
-- Standard     : VHDL'87
-------------------------------------------------------------------------------
-- Description  : Structural desciption of all stages
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

entity datapath is
  
  generic (
    NSTAGE         	: integer;
    NBITINT       	: integer;
    NBITTAP             : integer;
    NBITIN              : integer);

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
  
end datapath;

architecture struct of datapath is

component partial_stage  
  generic (
    NBITINT             : integer;
    NBITTAP             : integer);
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
 end component;
  
component stage
  generic (
    NBITINT             : integer;
    NBITTAP             : integer);
  port (
    clk                 : in  std_logic;
    rst                 : in  std_logic;
    tap_in_Re           : in  std_logic_vector(NBITTAP-1 downto 0);
    tap_in_Im           : in  std_logic_vector(NBITTAP-1 downto 0);
    bfI_mux_sel         : in  std_logic;
    bfII_mux_sel        : in  std_logic;
    bfII_mux_sel_j      : in  std_logic;
    bfI_data_in         : in  std_logic_vector(NBITINT*2-1 downto 0);	 
    mux_to_bfI          : in  std_logic_vector(NBITINT*2-1 downto 0);
    mux_to_bfII         : in  std_logic_vector(NBITINT*2-1 downto 0);
    bfI_to_mux          : out std_logic_vector(NBITINT*2-1 downto 0);
    bfII_to_mux         : out std_logic_vector(NBITINT*2-1 downto 0);
    cm_data_out         : out std_logic_vector(NBITINT*2-1 downto 0));
  end component;

-- signal definitions

  type int_array is array(NSTAGE-2 downto 0) of std_logic_vector(NBITINT*2-1 downto 0);

  signal int_mux_first_stage, int_data_merge, cm_data_out, cm_data_out_i : std_logic_vector(NBITINT*2-1 downto 0);
  signal int_data_in_Im, int_data_in_Re, int_data_in_Im_i, int_data_in_Re_i : std_logic_vector(NBITIN-1 downto 0);
  signal int_data_out_Re, int_data_out_Im : std_logic_vector(NBITINT-1 downto 0);
  signal stage_to_next_i  : int_array;
  signal stage_to_next_ii : int_array;

  constant zeros : std_logic_vector(NBITINT-NBITIN-1 downto 0):= (others => '0');
  
begin  -- struct

inst_stage: for i in 0 to NSTAGE-1 generate

  first_stage: if i=0 generate
    stage_inst_one : Stage generic map (
      NBITINT   => NBITINT,
      NBITTAP   => NBITTAP)
      port map (
        clk             => clk,
        rst             => rst,
        tap_in_Re       => tap_in_Re(i),
        tap_in_Im       => tap_in_Im(i),
        bfI_mux_sel     => bfI_mux_sel(i),
        bfII_mux_sel    => bfII_mux_sel(i),
        bfII_mux_sel_j  => bfII_mux_sel_j(i),
        mux_to_bfI      => dp_to_bfI(i), 
        mux_to_bfII     => dp_to_bfII(i),  
        bfI_to_mux      => dp_from_bfI(i),
        bfII_to_mux     => dp_from_bfII(i),		  
        bfI_data_in     => int_data_merge, 
        cm_data_out     => int_mux_first_stage);
  end generate first_stage;
  
  middle_stage: if (i>0 and i<NSTAGE-1) generate  
    stage_inst : Stage generic map (
      NBITINT   => NBITINT,
      NBITTAP   => NBITTAP)
    port map (
        clk             => clk,
        rst             => rst,
        tap_in_Re       => tap_in_Re(i),
        tap_in_Im       => tap_in_Im(i),
        bfI_mux_sel     => bfI_mux_sel(i),
        bfII_mux_sel    => bfII_mux_sel(i),
        bfII_mux_sel_j  => bfII_mux_sel_j(i),
        mux_to_bfI      => dp_to_bfI(i), 
        mux_to_bfII     => dp_to_bfII(i), 
        bfI_to_mux      => dp_from_bfI(i),
        bfII_to_mux     => dp_from_bfII(i), 
        bfI_data_in     => stage_to_next_ii(i-1),
        cm_data_out     => stage_to_next_i(i));
  end generate middle_stage;

  last_stage: if i=NSTAGE-1 generate
    stage_inst_last : partial_stage generic map (
      NBITINT   => NBITINT,
      NBITTAP   => NBITTAP)
      port map (
        clk             => clk,
        rst             => rst,
        mux_sel_2K      => mux_sel_2K,
        bfI_mux_sel     => bfI_mux_sel(i),
        bfII_mux_sel    => bfII_mux_sel(i),
        bfII_mux_sel_j  => bfII_mux_sel_j(i),
        mux_to_bfI      => dp_to_bfI(i), 
        mux_to_bfII     => dp_to_bfII(i), 
        bfI_to_mux      => dp_from_bfI(i),
        bfII_to_mux     => dp_from_bfII(i),
        bfI_data_in  	=> stage_to_next_ii(i-1),     
        cm_data_out  	=> cm_data_out);
  end generate last_stage;


  end generate inst_stage;

  ff_stage: process (clk, rst)
	begin  -- process ff_stage
    if rst = '0' then	 -- asynchronous reset (active low)
      int_data_in_Im <= (others => '0');
      int_data_in_Re <= (others => '0');
      data_out_Im    <= (others => '0');
      data_out_Re    <= (others => '0');
      cm_data_out_i  <= (others => '0');
      for i in 0 to NSTAGE-2 loop
        stage_to_next_ii(i) <= (others => '0');
      end loop;  -- i
    elsif clk'event and clk = '1' then  -- rising clock edge
      int_data_in_Im <= data_in_Im;
      int_data_in_Re <= data_in_Re;
      data_out_Im <= int_data_out_Im;
      data_out_Re <= int_data_out_Re;
      cm_data_out_i <= cm_data_out;
      for i in 0 to NSTAGE-2 loop
        stage_to_next_ii(i) <= stage_to_next_i(i);
      end loop;  -- i
    end if;
  end process ff_stage;

--
-- Mux bypass 1K (First Stage)
--
mux_1K_bypass: process (mux_sel_1K, int_mux_first_stage, int_data_merge)
begin  -- process mux_1K_bypass
  if mux_sel_1K = '0' then
    stage_to_next_i(0) <= int_mux_first_stage;
  else
    stage_to_next_i(0) <= int_data_merge;
  end if;
end process mux_1K_bypass;    	

--
-- Input Mux bypass FFT/IFFT
--
in_mux_fft_ifft: process (int_data_in_Re, int_data_in_Im, fft_nifft)
begin  -- process mux_1K_bypass
  if fft_nifft = '1' then
    int_data_in_Im_i <= int_data_in_Im;
    int_data_in_Re_i <= int_data_in_Re;
  else -- swap inputs
    int_data_in_Im_i <= int_data_in_Re; 
    int_data_in_Re_i <= int_data_in_Im;
  end if;
end process in_mux_fft_ifft;

--
-- Output Mux bypass FFT/IFFT
--
out_mux_fft_ifft: process (cm_data_out_i, fft_nifft)
begin  -- process mux_1K_bypass
  if fft_nifft = '1' then
    int_data_out_Im <= cm_data_out_i(NBITINT*2-1 downto NBITINT);
    int_data_out_Re <= cm_data_out_i(NBITINT-1 downto 0);
  else -- swap inputs
    int_data_out_Im <= cm_data_out_i(NBITINT-1 downto 0);
    int_data_out_Re <= cm_data_out_i(NBITINT*2-1 downto NBITINT);
  end if;
end process out_mux_fft_ifft; 

int_data_merge(NBITINT*2-1 downto NBITINT*2-NBITIN) <= int_data_in_Im_i;
int_data_merge(NBITINT*2-NBITIN-1 downto NBITINT) <= zeros;
int_data_merge(NBITINT-1 downto NBITINT-NBITIN) <= int_data_in_Re_i;
int_data_merge(NBITINT-NBITIN-1 downto 0) <= zeros;

end struct;
