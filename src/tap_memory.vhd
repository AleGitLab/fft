-------------------------------------------------------------------------------
-- Title        : Behavioral desciption of a daul-port memory for phase storing 
-- Project      : Integrated Systems Project
--                Reconfigurable IFFT/FFT Core R2^2SDF 
--                (Radix 2^2 Single Delay Feedback) 1K/2K/4K points
-------------------------------------------------------------------------------
-- File         : tap_memory.vhd
-- Authors      : Alessandro Colonna, Di Cugno Giovanni, Frache Stefano
--                <alessandro.colonna@studenti.polito.it>
-- Company      : Politecnico di Torino
-- Created      : 01/03/2009
-- Last update  : 19/05/2009
-- Platform     : Windows whith Emacs
-- Standard     : VHDL'87
-------------------------------------------------------------------------------
-- Description  : Behavioral desciption of a daul-port memory for phase storing
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

entity tap_memory is

  generic( DBITS: integer ;           
           ABITS: integer );           
           --WORDS: integer:=1024); 			        -- WORDS=2**ABITS
  port( data_in    : in  std_logic_vector(DBITS-1 downto 0); 	-- input data
        data_out_a : out std_logic_vector(DBITS-1 downto 0);    -- output data
        data_out_b : out std_logic_vector(DBITS-1 downto 0);
        add_a      : in  std_logic_vector(ABITS-1 downto 0);
        add_b      : in  std_logic_vector(ABITS-1 downto 0);
        clk        : in  std_logic;
        wr         : in  std_logic);


end tap_memory;

architecture behavioural of tap_memory is

type datamem is array (0 to 2**ABITS-1) of std_logic_vector(DBITS-1 downto 0);
signal myarray : datamem :=((others=> (others=>'0')));

begin

  pwr: process(clk)
  begin
    if clk'event and clk='1' then
      if wr='1' then
        myarray(conv_integer(add_a))<=data_in;
      elsif wr='0' then
        data_out_a <= myarray(conv_integer(add_a));
        data_out_b <= myarray(conv_integer(add_b));
      end if;
    end if;
  end process;
    
end behavioural;
 

