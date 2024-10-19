-------------------------------------------------------------------------------
-- Title        : Structural desciption of Control Unit and Phase Generation Logic
-- Project      : Integrated Systems Project
--                Reconfigurable IFFT/FFT Core R2^2SDF (Radix 2^2 Single Delay Feedback)
--                1K/2K/4K points
-------------------------------------------------------------------------------
-- File         : cu_and_phase_gen.vhd
-- Authors      : Alessandro Colonna, Di Cugno Giovanni, Frache Stefano
--                <alessandro.colonna@studenti.polito.it>
-- Company      : Politecnico di Torino
-- Created      : 01/03/2009
-- Last update  : 20/05/2009
-- Platform     : Windows with Emacs
-- Standard     : VHDL'87
-------------------------------------------------------------------------------
-- Description  : Structural desciption of Control Unit and Phase Generation Logic
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
use ieee.std_logic_unsigned.all;

entity cu_and_phase_gen is

  generic (
    NRAMPHASE   : integer ;
    ADD_WIDTH   : integer ;
    logNPOINTS  : integer );

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
    wr_en               : out std_logic_vector(NSTAGE*2-1 downto 0);
    rd_en 		: out std_logic_vector(NSTAGE*2-1 downto 0);
    tap_Re 	 	: out arr_tap;
    tap_Im 	 	: out arr_tap);
          
end cu_and_phase_gen;

architecture beh of cu_and_phase_gen is

component start_and_en_gen_4K

  port (
    clk                 : in  std_logic;
    rst                 : in  std_logic;
    start        	: in  std_logic;
    data_valid          : out std_logic;
    start_out           : out std_logic_vector(4 downto 0);
    bf_start            : out std_logic_vector(5 downto 0);
    wr_en 		: out std_logic_vector(11 downto 0);
    rd_en 		: out std_logic_vector(11 downto 0));

end component;

component start_and_en_gen_2K

  port (
    clk                 : in  std_logic;
    rst                 : in  std_logic;
    start               : in  std_logic;
    data_valid          : out std_logic;
    start_out           : out std_logic_vector(4 downto 0);
    bf_start            : out std_logic_vector(5 downto 0);
    wr_en               : out std_logic_vector(11 downto 0);
    rd_en               : out std_logic_vector(11 downto 0));

end component;

component start_and_en_gen_1K

  port (
    clk                 : in  std_logic;
    rst                 : in  std_logic;
    start               : in  std_logic;
    data_valid          : out std_logic;
    start_out           : out std_logic_vector(4 downto 0);
    bf_start            : out std_logic_vector(5 downto 0);
    wr_en               : out std_logic_vector(11 downto 0);
    rd_en               : out std_logic_vector(11 downto 0));

end component;

component stage_count

    generic (
      NBITTC         : integer;
      NBITINCREMENT  : integer;
      logNWORDS      : integer);
    port (
      counters_start   : in  std_logic;
      bf_start         : in  std_logic;
      ck               : in  std_logic;
      reset            : in  std_logic;
      mux_sel_j        : out std_logic;
      bfI_mux_sel      : out std_logic;
      bfII_mux_sel     : out std_logic;
      terminal_count   : in  std_logic_vector(NBITTC-1 downto 0);
      bin_count        : out std_logic_vector(logNWORDS-1 downto 0));
  
end component;

component tap_memory

  generic( DBITS: integer ;           
           ABITS: integer );           
           --WORDS: integer:=1024);                             -- WORDS=2**ABITS
  port( data_in    : in  std_logic_vector(DBITS-1 downto 0); 	-- input data
        data_out_a : out std_logic_vector(DBITS-1 downto 0);    -- output data
        data_out_b : out std_logic_vector(DBITS-1 downto 0);
        add_a      : in  std_logic_vector(ABITS-1 downto 0);
        add_b      : in  std_logic_vector(ABITS-1 downto 0);
        clk        : in  std_logic;
        wr         : in  std_logic);
end component;

component last_stage_count

    port (
      bf_start         : in  std_logic;
      ck               : in  std_logic;
      reset            : in  std_logic;
      mux_sel_j        : out std_logic;
      bfI_mux_sel      : out std_logic;
      bfII_mux_sel     : out std_logic);
  
end component;


type arr_add is array (0 to NRAMPHASE*2-2) of std_logic_vector(9 downto 0);
type arr_phase is array (0 to NRAMPHASE*2-2) of std_logic_vector(NBITTAP*2-1 downto 0);
type bin_c is array (0 to NRAMPHASE*2-2) of std_logic_vector(11 downto 0);
type arr_mux_sel is array(0 to 4) of std_logic_vector(1 downto 0);

signal bfI_mux_sel_i, bfII_mux_sel_i : std_logic_vector(NRAMPHASE*2-1 downto 0);
signal int_start : std_logic_vector(4 downto 0);
signal int_bf_start : std_logic_vector(5 downto 0);
signal int_terminal_count_0 : std_logic_vector(10 downto 0);
signal int_terminal_count_1 : std_logic_vector(8 downto 0);
signal int_terminal_count_2 : std_logic_vector(6 downto 0);
signal int_terminal_count_3 : std_logic_vector(4 downto 0);
signal int_terminal_count_4 : std_logic_vector(2 downto 0);

signal int_bf_start_4K, int_bf_start_2K, int_bf_start_1K : std_logic_vector(5 downto 0);
signal wr_en_4K, wr_en_2K, wr_en_1K :  std_logic_vector(NSTAGE*2-1 downto 0);
signal rd_en_4K, rd_en_2K, rd_en_1K :  std_logic_vector(NSTAGE*2-1 downto 0);
signal data_valid_4K, data_valid_2K, data_valid_1K :  std_logic;
signal int_start_4K, int_start_2K, int_start_1K : std_logic_vector(4 downto 0);

		
signal int_tap_Re, int_tap_Im : arr_tap;
signal mux_sel, mux_sel_i : arr_mux_sel;
signal int_bin_count : bin_c; 
signal int_phase : arr_phase;
signal int_add : arr_add;

constant zero : std_logic_vector(NBITTAP-1 downto 0):= (others => '0');
constant unconn_port1 : std_logic_vector(NBITTAP*2-1 downto 0):= (others => '0');
constant unconn_port2 : std_logic_vector(9 downto 0):= (others => '0');

begin


  points_change : process (n_points, int_bf_start_4K, wr_en_4K, rd_en_4K, data_valid_4K, int_start_4K, int_bf_start_2K, wr_en_2K, rd_en_2K, data_valid_2K, int_start_2K, int_bf_start_1K, wr_en_1K, rd_en_1K, data_valid_1K, int_start_1K)
  begin
    if n_points = "01" then -- 2K
      int_terminal_count_0 <= conv_std_logic_vector(1023,11);
      int_terminal_count_1 <= conv_std_logic_vector(255,9);
      int_terminal_count_2 <= conv_std_logic_vector(63,7);
      int_terminal_count_3 <= conv_std_logic_vector(15,5);
      int_terminal_count_4 <= conv_std_logic_vector(3,3);
      int_bf_start <= int_bf_start_2K;
      wr_en <= wr_en_2K;
      rd_en <= rd_en_2K;
      data_valid <= data_valid_2K;
      int_start <= int_start_2K;
    else 
      int_terminal_count_0 <= conv_std_logic_vector(2047,11);
      int_terminal_count_1 <= conv_std_logic_vector(511,9);
      int_terminal_count_2 <= conv_std_logic_vector(127,7);
      int_terminal_count_3 <= conv_std_logic_vector(31,5);
      int_terminal_count_4 <= conv_std_logic_vector(7,3);
      if n_points = "10" then -- 1K
        int_bf_start <= int_bf_start_1K;
        wr_en <= wr_en_1K;
        rd_en <= rd_en_1K;
        data_valid <= data_valid_1K;
        int_start <= int_start_1K;
      else -- always 4K
        int_bf_start <= int_bf_start_4K;
        wr_en <= wr_en_4K;
        rd_en <= rd_en_4K;
        data_valid <= data_valid_4K;
        int_start <= int_start_4K;
      end if;
    end if;
  end process points_change;


  points_change_last_bf : process (n_points,bfI_mux_sel_i,bfII_mux_sel_i)
  begin
    if n_points = "01" then -- 2K
      bfI_mux_sel(5) <= bfII_mux_sel_i(5);
      bfII_mux_sel(5) <= bfII_mux_sel_i(5);
      for i in 0 to 4 loop
        bfI_mux_sel(i) <= bfI_mux_sel_i(i);
        bfII_mux_sel(i) <= bfII_mux_sel_i(i);	
      end loop;
    else -- 1K and 4K
      for i in 0 to 5 loop
        bfI_mux_sel(i) <= bfI_mux_sel_i(i);
        bfII_mux_sel(i) <= bfII_mux_sel_i(i);	
      end loop;
    end if;
  end process points_change_last_bf;


  tap_mem_01 : tap_memory
    generic map (
      DBITS => NBITTAP*2,
      ABITS => 10)
    port map (
      data_in  => unconn_port1,
      data_out_a => int_phase(0),
      data_out_b => int_phase(1),
      add_a  => int_add(0),
      add_b  => int_add(1),
      clk   => clk,
      WR   => '0');
      --OE   => '1');    

  tap_mem_23 : tap_memory
    generic map (
      DBITS => NBITTAP*2,
      ABITS => 10)
    port map (
      data_in  => unconn_port1,
      data_out_a => int_phase(2),
      data_out_b => int_phase(3),
      add_a  => int_add(2),
      add_b  => int_add(3),
      clk   => clk,
      WR   => '0');
		  

  tap_mem_4 : tap_memory
    generic map (
      DBITS => NBITTAP*2,
      ABITS => 10)
    port map (
      data_in  => unconn_port1,
      data_out_a => int_phase(4),
      add_a  => int_add(4),
      add_b  => unconn_port2,
      clk   => clk,
      WR   => '0');

  inst_count_0 : stage_count
    generic map (
      NBITTC         => 11,
      NBITINCREMENT  => 2,
      logNWORDS      => 12)
    port map (
      counters_start  => int_start(0),
      bf_start        => int_bf_start(0),
      ck 	      => clk,
      reset  	      => rst,
      mux_sel_j       => mux_sel_j(0),
      bfI_mux_sel     => bfI_mux_sel_i(0),
      bfII_mux_sel    => bfII_mux_sel_i(0),
      terminal_count  => int_terminal_count_0,
      bin_count       => int_bin_count(0));    


  inst_count_1 : stage_count
    generic map (
      NBITTC         => 9,
      NBITINCREMENT  => 4,
      logNWORDS      => 12)
    port map (
      counters_start  => int_start(1),
      bf_start        => int_bf_start(1),
      ck 	      => clk,
      reset  	      => rst,
      mux_sel_j       => mux_sel_j(1),
      bfI_mux_sel     => bfI_mux_sel_i(1),
      bfII_mux_sel    => bfII_mux_sel_i(1),
      terminal_count  => int_terminal_count_1,
      bin_count       => int_bin_count(1));    

  inst_count_2 : stage_count
    generic map (
      NBITTC         => 7,
      NBITINCREMENT  => 6,
      logNWORDS      => 12)
    port map (
      counters_start  => int_start(2),
      bf_start        => int_bf_start(2),
      ck 	      => clk,
      reset  	      => rst,
      mux_sel_j       => mux_sel_j(2),
      bfI_mux_sel     => bfI_mux_sel_i(2),
      bfII_mux_sel    => bfII_mux_sel_i(2),
      terminal_count  => int_terminal_count_2,
      bin_count       => int_bin_count(2));    
		  

  inst_count_3 : stage_count
    generic map (
      NBITTC         => 5,
      NBITINCREMENT  => 8,
      logNWORDS      => 12)
    port map (
      counters_start  => int_start(3),
      bf_start        => int_bf_start(3),
      ck 	      => clk,
      reset  	      => rst,
      mux_sel_j       => mux_sel_j(3),
      bfI_mux_sel     => bfI_mux_sel_i(3),
      bfII_mux_sel    => bfII_mux_sel_i(3),
      terminal_count  => int_terminal_count_3,
      bin_count       => int_bin_count(3));    
		  

  inst_count_4 : stage_count
    generic map (
      NBITTC         => 3,
      NBITINCREMENT  => 10, 
      logNWORDS      => 12)
    port map (
      counters_start  => int_start(4),
      bf_start        => int_bf_start(4),
      ck 	      => clk,
      reset  	      => rst,
      mux_sel_j       => mux_sel_j(4),
      bfI_mux_sel     => bfI_mux_sel_i(4),
      bfII_mux_sel    => bfII_mux_sel_i(4),
      terminal_count  => int_terminal_count_4,
      bin_count       => int_bin_count(4));

  inst_last_count : last_stage_count
    port map (
      bf_start          => int_bf_start(5),
      ck                => clk,
      reset             => rst,
      mux_sel_j         => mux_sel_j(5),
      bfI_mux_sel       => bfI_mux_sel_i(5),
      bfII_mux_sel      => bfII_mux_sel_i(5));
		  

  add_conn: process (n_points, int_bin_count)
  begin  -- process add_conn
    if n_points = "01" then -- 2K
      for i in 0 to 4 loop
        int_add(i)<= int_bin_count(i)(logNPOINTS-4 downto 0) & '0';
        mux_sel(i)<= int_bin_count(i)(logNPOINTS-2 downto logNPOINTS-3);
      end loop;  -- i
    else -- always 4K
      for i in 0 to 4 loop
        int_add(i)<= int_bin_count(i)(logNPOINTS-3 downto 0);
        mux_sel(i)<= int_bin_count(i)(logNPOINTS-1 downto logNPOINTS-2);
      end loop;  -- i
    end if;
  end process add_conn;
 

  ff_stage: process (clk, rst) -- one FF delay 
  begin  -- process ff_stage
    if rst = '0' then	 -- asynchronous reset (active low)
      for i in 0 to 4 loop
        mux_sel_i(i)<= (others => '0');
        tap_Im(i)<= (others => '0');
        tap_Re(i)<= (others => '0');
      end loop;
    elsif clk'event and clk = '1' then  -- rising clock edge
      for i in 0 to 4 loop
        mux_sel_i(i)<= mux_sel(i);
        tap_Im(i)<= int_tap_Im(i);
        tap_Re(i)<= int_tap_Re(i);
      end loop;
    end if;
  end process ff_stage;

  start_and_en_gen_inst_4K : start_and_en_gen_4K
    port map (
      clk               => clk,
      rst               => rst,
      start             => start,
      bf_start          => int_bf_start_4K,
      wr_en             => wr_en_4K,
      data_valid        => data_valid_4K,
      rd_en             => rd_en_4K,
      start_out         => int_start_4K);
		
  start_and_en_gen_inst_2K : start_and_en_gen_2K
    port map (
      clk               => clk,
      rst               => rst,
      start             => start,
      bf_start          => int_bf_start_2K,
      wr_en		=> wr_en_2K,
      data_valid        => data_valid_2K,
      rd_en             => rd_en_2K,
      start_out         => int_start_2K);
		
  start_and_en_gen_inst_1K : start_and_en_gen_1K
    port map (
      clk               => clk,
      rst               => rst,
      start             => start,
      bf_start          => int_bf_start_1K,
      wr_en             => wr_en_1K,
      data_valid        => data_valid_1K,
      rd_en             => rd_en_1K,
      start_out         => int_start_1K);

  -- purpose: multiplexer for four quadrant generation
  -- type   : combinational
  -- inputs : mux_sel, int_phase
  -- outputs: tap_Re, tap_Im
  mux_4_quad: process (mux_sel_i, int_phase)
  begin  -- process mux_4_quad  
    for i  in 0 to 4 loop
      if mux_sel_i(i) = "01" then
        if int_phase(i)(NBITTAP-1 downto 0) =  zero then
          int_tap_Im(i)<= (others => '0');
        else
          int_tap_Im(i)<= not(int_phase(i)(NBITTAP-1 downto 0))+1;
        end if;
        if int_phase(i)(NBITTAP*2-1 downto NBITTAP) =  zero then
          int_tap_Re(i)<= (others => '0');
        else
          int_tap_Re(i)<= not(int_phase(i)(NBITTAP*2-1 downto NBITTAP))+1;
        end if;
      elsif mux_sel_i(i) = "10" then
        if int_phase(i)(NBITTAP*2-1 downto NBITTAP) =  zero then
          int_tap_Im(i)<= (others => '0');
        else
          int_tap_Im(i)<= int_phase(i)(NBITTAP*2-1 downto NBITTAP);
        end if;
        if int_phase(i)(NBITTAP-1 downto 0) =  zero then
          int_tap_Re(i)<= (others => '0');
        else
          int_tap_Re(i)<= not(int_phase(i)(NBITTAP-1 downto 0))+1;
        end if;	
      else -- always 4K mux_sel_i(i) = "00"
        if int_phase(i)(NBITTAP*2-1 downto NBITTAP) =  zero then
          int_tap_Im(i)<= (others => '0');
        else
          int_tap_Im(i)<= not(int_phase(i)(NBITTAP*2-1 downto NBITTAP))+1;
        end if;
        if int_phase(i)(NBITTAP-1 downto 0) =  zero then
          int_tap_Re(i)<= (others => '0');
        else
          int_tap_Re(i)<= int_phase(i)(NBITTAP-1 downto 0);
        end if;	
      end if;
    end loop;  -- i
  end process mux_4_quad;


-- purpose: generation of mux2K/4K signals for bypass FIFOs
-- type   : combinational
-- inputs : n_points
-- outputs: mux_1K, mux_2K
  mux_signal_gen: process (n_points) 
  begin  -- process mux_signal_gen
    if n_points = "01" then            -- 2K points
      mux_2K <= '1';
      mux_1K <= '0';
    elsif n_points = "10" then         -- 1K points
      mux_2K <= '0';
      mux_1K <= '1';
    else                               -- always 4K points
      mux_2K <= '0';
      mux_1K <= '0';
    end if;
  end process mux_signal_gen;
           
		
end beh;

