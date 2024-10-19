-------------------------------------------------------------------------------
-- Title        : Structural desciption of all FIFOs and bypass multiplexers
-- Project      : Integrated Systems Project
--                Reconfigurable IFFT/FFT Core R2^2SDF (Radix 2^2 Single Delay Feedback)
--                1K/2K/4K points
-------------------------------------------------------------------------------
-- File         : fifos_and_muxes.vhd
-- Authors      : Alessandro Colonna, Di Cugno Giovanni, Frache Stefano
--                <alessandro.colonna@studenti.polito.it>
-- Company      : Politecnico di Torino
-- Created      : 01/03/2009
-- Last update  : 20/05/2009
-- Platform     : Windows whith Emacs
-- Standard     : VHDL'87
-------------------------------------------------------------------------------
-- Description  : Structural desciption of all FIFOs and bypass multiplexers
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

entity fifos_and_muxes is
  generic (
    NPOINTS : integer ;
    NSTAGE  : integer ;
    NBITINT : integer );
  
  port (
    clk         : in  std_logic;
    rd_en       : in  std_logic_vector(NSTAGE*2-1 downto 0);
    rst         : in  std_logic_vector(NSTAGE*2-1 downto 0);
    wr_en       : in  std_logic_vector(NSTAGE*2-1 downto 0);
    mux_sel_2K  : in  std_logic;
    from_bfI    : in  bf_fifo; 
    from_bfII   : in  bf_fifo; 
    to_bfI      : out bf_fifo;
    to_bfII     : out bf_fifo);

end fifos_and_muxes;


architecture beh of fifos_and_muxes is

signal int_mux_to_fifo, int_fifo_to_mux : data_fifo;

component fifo_beh 
  generic (
    NBITINT    : integer;
    NWORDS     : integer);
  port (
    clk          : in  std_logic;
    rst          : in  std_logic;
    rd_en        : in  std_logic;
    wr_en        : in  std_logic;
    din          : in  std_logic_vector(NBITINT-1 downto 0);
    dout         : out std_logic_vector(NBITINT-1 downto 0));
end component;

  
component fifo_generator_2K
	port (
	clk: IN std_logic;
	din: IN std_logic_VECTOR(63 downto 0);
	rd_en: IN std_logic;
	rst: IN std_logic;
	wr_en: IN std_logic;
	dout: OUT std_logic_VECTOR(63 downto 0);
	empty: OUT std_logic;
	full: OUT std_logic);
end component;

component fifo_generator_1K
	port (
	clk: IN std_logic;
	din: IN std_logic_VECTOR(63 downto 0);
	rd_en: IN std_logic;
	rst: IN std_logic;
	wr_en: IN std_logic;
	dout: OUT std_logic_VECTOR(63 downto 0);
	empty: OUT std_logic;
	full: OUT std_logic);
end component;

component fifo_generator_512
	port (
	clk: IN std_logic;
	din: IN std_logic_VECTOR(63 downto 0);
	rd_en: IN std_logic;
	rst: IN std_logic;
	wr_en: IN std_logic;
	dout: OUT std_logic_VECTOR(63 downto 0);
	empty: OUT std_logic;
	full: OUT std_logic);
end component;

component fifo_generator_256
	port (
	clk: IN std_logic;
	din: IN std_logic_VECTOR(63 downto 0);
	rd_en: IN std_logic;
	rst: IN std_logic;
	wr_en: IN std_logic;
	dout: OUT std_logic_VECTOR(63 downto 0);
	empty: OUT std_logic;
	full: OUT std_logic);
end component;

component fifo_generator_128
	port (
	clk: IN std_logic;
	din: IN std_logic_VECTOR(63 downto 0);
	rd_en: IN std_logic;
	rst: IN std_logic;
	wr_en: IN std_logic;
	dout: OUT std_logic_VECTOR(63 downto 0);
	empty: OUT std_logic;
	full: OUT std_logic);
end component;

component fifo_generator_64
	port (
	clk: IN std_logic;
	din: IN std_logic_VECTOR(63 downto 0);
	rd_en: IN std_logic;
	rst: IN std_logic;
	wr_en: IN std_logic;
	dout: OUT std_logic_VECTOR(63 downto 0);
	empty: OUT std_logic;
	full: OUT std_logic);
end component;

component fifo_generator_32
	port (
	clk: IN std_logic;
	din: IN std_logic_VECTOR(63 downto 0);
	rd_en: IN std_logic;
	rst: IN std_logic;
	wr_en: IN std_logic;
	dout: OUT std_logic_VECTOR(63 downto 0);
	empty: OUT std_logic;
	full: OUT std_logic);
end component;

component fifo_generator_16
	port (
	clk: IN std_logic;
	din: IN std_logic_VECTOR(63 downto 0);
	rd_en: IN std_logic;
	rst: IN std_logic;
	wr_en: IN std_logic;
	dout: OUT std_logic_VECTOR(63 downto 0);
	empty: OUT std_logic;
	full: OUT std_logic);
end component;


begin  -- beh


  FIFO_inst_0 : fifo_generator_2K
    port map (
      clk   => clk,
      din   => int_mux_to_fifo(0),
      rd_en => rd_en(0),
      rst   => rst(0),
      wr_en => wr_en(0),
      dout  => int_fifo_to_mux(0));
  
  FIFO_inst_1 : fifo_generator_1K
    port map (
      clk   => clk,
      din   => int_mux_to_fifo(1),
      rd_en => rd_en(1),
      rst   => rst(1),
      wr_en => wr_en(1),
      dout  => int_fifo_to_mux(1));

  FIFO_inst_2 : fifo_generator_512
    port map (
      clk   => clk,
      din   => int_mux_to_fifo(2),
      rd_en => rd_en(2),
      rst   => rst(2),
      wr_en => wr_en(2),
      dout  => int_fifo_to_mux(2));

		
  FIFO_inst_3 : fifo_generator_256
    port map (
      clk   => clk,
      din   => int_mux_to_fifo(3),
      rd_en => rd_en(3),
      rst   => rst(3),
      wr_en => wr_en(3),
      dout  => int_fifo_to_mux(3));


  FIFO_inst_4 : fifo_generator_128
    port map (
      clk   => clk,
      din   => int_mux_to_fifo(4),
      rd_en => rd_en(4),
      rst   => rst(4),
      wr_en => wr_en(4),
      dout  => int_fifo_to_mux(4));


  FIFO_inst_5 : fifo_generator_64
    port map (
      clk   => clk,
      din   => int_mux_to_fifo(5),
      rd_en => rd_en(5),
      rst   => rst(5),
      wr_en => wr_en(5),
      dout  => int_fifo_to_mux(5));


  FIFO_inst_6 : fifo_generator_32
    port map (
      clk   => clk,
      din   => int_mux_to_fifo(6),
      rd_en => rd_en(6),
      rst   => rst(6),
      wr_en => wr_en(6),
      dout  => int_fifo_to_mux(6));


  FIFO_inst_7 : fifo_generator_16
    port map (
      clk   => clk,
      din   => int_mux_to_fifo(7),
      rd_en => rd_en(7),
      rst   => rst(7),
      wr_en => wr_en(7),
      dout  => int_fifo_to_mux(7));
		

  ff_fifo_inst: for i in 8 to 11 generate
    fifo_beh_inst : fifo_beh
      generic map (
        NBITINT => NBITINT*2,
        NWORDS  => NPOINTS/2**(i+1))
      port map (
        clk   => clk,
        rst   => rst(i),
        rd_en => rd_en(i),
        wr_en => wr_en(i),
        din   => int_mux_to_fifo(i),
        dout  => int_fifo_to_mux(i));
	end generate ff_fifo_inst;
    

  mux_2K_bypass: process (mux_sel_2K,int_fifo_to_mux,from_bfI,from_bfII)
  begin  -- process mux_2K_bypass
    if mux_sel_2K = '0' then
      for i in NSTAGE-1 downto 0 loop
        to_bfI(i) <= int_fifo_to_mux(i*2);
        to_bfII(i) <= int_fifo_to_mux(i*2+1);
        int_mux_to_fifo(i*2)    <= from_bfI(i);
        int_mux_to_fifo(i*2+1)  <= from_bfII(i);
      end loop;  -- i		
    else
      to_bfI(0) <= int_fifo_to_mux(1);
      to_bfII(0) <= int_fifo_to_mux(2);
      int_mux_to_fifo(0) <= from_bfI(0);
      int_mux_to_fifo(1) <= from_bfI(0);  
      for i in NSTAGE-2 downto 1 loop
        to_bfI(i) <= int_fifo_to_mux(i*2+1);
        to_bfII(i) <= int_fifo_to_mux(i*2+2);
        int_mux_to_fifo(i*2)    <= from_bfII(i-1);
        int_mux_to_fifo(i*2+1)  <= from_bfI(i);
      end loop;  -- i		
      to_bfI(5) <= int_fifo_to_mux(11);
      to_bfII(5) <= int_fifo_to_mux(11);
      int_mux_to_fifo(10)    <= from_bfII(4);
      int_mux_to_fifo(11)  <= from_bfI(5);
    end if;
  end process mux_2K_bypass;      


end beh;
