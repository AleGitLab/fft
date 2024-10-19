-------------------------------------------------------------------------------
-- Title        : Behavioral description of start generation for CU's counters
-- Project      : Integrated Systems Project
--                Reconfigurable IFFT/FFT Core R2^2SDF (Radix 2^2 Single Delay Feedback)
--                1K/2K/4K points
-------------------------------------------------------------------------------
-- File         : start_and_en_gen_2K.vhd
-- Authors      : Alessandro Colonna, Di Cugno Giovanni, Frache Stefano
--                <alessandro.colonna@studenti.polito.it>
-- Company      : Politecnico di Torino
-- Created      : 01/03/2009
-- Last update  : 20/05/2009
-- Platform     : Windows with Emacs
-- Standard     : VHDL'87
-------------------------------------------------------------------------------
-- Description  : Behavioral description of start generation for CU's counters
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

use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity start_and_en_gen_2K is

  port (
    clk        : in  std_logic;
    rst        : in  std_logic;
    start      : in  std_logic;
    data_valid : out std_logic;
    start_out  : out std_logic_vector(4 downto 0);
    bf_start   : out std_logic_vector(5 downto 0);
    wr_en      : out std_logic_vector(11 downto 0);
    rd_en      : out std_logic_vector(11 downto 0));
  
end start_and_en_gen_2K;

architecture beh of start_and_en_gen_2K is

-- signal definitions
signal count : std_logic_vector(13 downto 0);
  
begin  -- struct

  wr_en(0) <= '0';
  rd_en(0) <= '0';
  
counter_start: process (clk, rst)

begin  -- process counter
  if rst = '0' then                   -- asynchronous reset (active low)
    count <= (others => '0');
    start_out <= (others => '0');
    wr_en(11 downto 1) <= (others => '0');
    rd_en(11 downto 1) <= (others => '0');
    data_valid <= '0';
    bf_start(5 downto 0) <= (others => '0');
  elsif clk'event and clk = '1' then      -- rising clock edge
    if start='1' then
-- start for bfI
      if conv_integer(count) = 0 then
        bf_start(0) <= '1';
        wr_en(11 downto 1) <= (others => '1');
        count <= count + 1;
      elsif conv_integer(count) = 1023 then
        rd_en(11 downto 1) <= (others => '1');
        count <= count + 1;
      elsif conv_integer(count) = 1024 + 512 + 6 then
        bf_start(1) <= '1';
        count <= count + 1;
      elsif conv_integer(count) = 1024 + 512 + 256 + 128 + 12 then
        bf_start(2) <= '1';
        count <= count + 1;
      elsif conv_integer(count) = 1024 + 512 + 256 + 128 + 64 + 32 + 18 then
        bf_start(3) <= '1';
        count <= count + 1;  	
      elsif conv_integer(count) = 1024 + 512 + 256 + 128 + 64 + 32 + 16 + 8 + 24 then
        bf_start(4) <= '1';
        count <= count + 1;
      elsif conv_integer(count) = 1024 + 512 + 256 + 128 + 64 + 32 + 16 + 8 + 4 + 2 + 29 then   -- 'cause bfII_mux_sel is delayed of 1 FF
        bf_start(5) <= '1';
        count <= count + 1;
        
-- start for phase counters  
      elsif conv_integer(count) = 1024 + 512  then
        start_out(0) <= '1';
        count <= count + 1;
      elsif conv_integer(count) = 1024 + 512 + 256 + 128 + 6 then
        start_out(1) <= '1';
        count <= count + 1;
      elsif conv_integer(count) = 1024 + 512 + 256 + 128 + 64 + 32 + 12 then  
        start_out(2) <= '1';
        count <= count + 1;
      elsif conv_integer(count) = 1024 + 512 + 256 + 128 + 64 + 32 + 16 + 8 + 18 then  
        start_out(3) <= '1';
        count <= count + 1;
      elsif conv_integer(count) = 1024 + 512 + 256 + 128 + 64 + 32 + 16 + 8 + 4 + 2 + 24 then  
        start_out(4) <= '1';
        count <= count + 1;
      elsif conv_integer(count) = 2047 + 33 then
        data_valid <= '1';
        count <= count + 1;
      else
        count <= count + 1;
      end if;
    else
      start_out <= (others => '0');
      count <= (others => '0');
      wr_en(11 downto 1) <= (others => '0');
      rd_en(11 downto 1) <= (others => '0');
    end if;
  end if;
end process counter_start;


end beh;


