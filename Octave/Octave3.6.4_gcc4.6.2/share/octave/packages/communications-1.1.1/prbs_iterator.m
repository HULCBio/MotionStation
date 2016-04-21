## Copyright (C) 2006 Muthiah Annamalai <muthiah.annamalai@uta.edu>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## This function generates the output bits from the PRBS
## state, for the number of iterations specified.
##
## First argument is the PRBS structure obtained from prbs_generator.
## PRBS iterations is specified in the second argument.
## PRBS start state is taken from the prbs.sregs.
##
## Second argument of the output is PRBS structure with a new
## state. This allows usage like: 
## 
## [ seq, prbs ] =  prbs_iterator( prbs, niterations );
## 
## while the state of the PRBS is updated.
## 
## Example: If you had a PRBS shift register like the diagram
## below with 4 registers we use representation by polynomial
## of [ 1 2 3 4], and feedback connections between [ 1 3 4 ].
## The output PRBS sequence is taken from the position 4.
## 
##  +---+    +----+   +---+   +---+
##  | D |----| D  |---| D |---| D |
##  +---+    +----+   +---+   +---+
##    |                 |       |
##    \                 /      /
##    [+]---------------+------+
##   1   +    0.D   + 1.D^2 + 1.D^3
##
## The code to implement this PRBS will be 
## prbs=prbs_generator([1 3 4],{[1 3 4]},[1 0 1 1]);
## x = prbs_iterator(prbs,15)
## 
## See Also: This function is to be used along with functions 
## prbs_iterator, prbs_generator and prbs_sequence.

function [outputseq, prbs] = prbs_iterator (prbs, iterations = 2^(prbs.reglen)-1)

  if ( nargin < 1 || nargin > 2 )
    print_usage;
  endif
  outputseq=zeros(1,iterations);
  nstate=zeros(1,prbs.reglen);
  
  ## For each iteration, shift the output bit. Then compute the xor pattern of connections. 
  ## Finally apply feedback the stuff. Insert the computed pattern.
  for itr=1:iterations
    ## save output.
    outputseq(itr)=prbs.sregs(prbs.reglen);
    
    ## compute the feedback.
    for itr2=1:prbs.conlen
      val=0;
      L=length(prbs.connections{itr2});
      for itr3=2:L
        val=bitxor(val,prbs.sregs(prbs.connections{itr2}(itr3)));
      endfor
      nstate(prbs.connections{itr2}(1))=val;
    endfor
    
    ## rotate the output discarding the last output.
    prbs.sregs=[0 prbs.sregs(1:prbs.reglen-1)];

    ## insert the feedback.
    for itr2=1:prbs.conlen
      prbs.sregs(itr2)=nstate(itr2);
      nstate(itr2)=0; # reset.
    endfor
    
  endfor
endfunction

##
##  TEST CASES FOR PRBS.
##
##
##  2^31 -1 : D31 + D28 + 1 =0  inverted 
##  2^23 -1 : D23 + D18 + 1 = 0 ,
##  2^15 -1 : D15 + D14 + 1 = 0,
##  2^10 -1 : D10 + D7 + 1 = 0,
##  2^7  -1 : D7 + D6 + 1 = 0,
##  2^4  -1 : D3 + D2 + 1 = 0,
##
##  +---+    +----+   +---+   +---+
##  | D |----| D  |---| D |---| D |
##  +---+    +----+   +---+   +---+
##    |                 |       |
##    \                 /      /
##    [+]---------------+------+
##   1   +    0.D   + 1.D^2 + 1.D^3
##
##
## prbs=prbs_generator([1 3 4],{[1 3 4]},[1 0 1 1]);
## x = prbs_iterator(prbs,15)
## y = prbs_iterator(prbs,30)(16:end)
## z = prbs_sequence(prbs)
## exit
## break

##
## Multiple Tap, Simple Sequence Generator.
##
## n=10;
## k=8;
## inits=round(abs(rand(1,n)*1.0))
## prbs=prbs_generator([n 1],{[1 2 k n-1 n]},inits);
## prbs_iterator(prbs,1023)
## prbs_seqlength(prbs,inits)

##prbs=prbs_generator([1 2 3],{[1 2 3]},[1 1 1]);
##prbs_iterator(prbs,7)

##
##  2^4  -1 : D4 + D1 + 1 = 0,
##
##  +---+    +----+   +---+   +---+
##  | D |----| D  |---| D |---| D |
##  +---+    +----+   +---+   +---+
##    |        |                |
##    \        /                /
##    [+]---------------+------+
##   1   +    0.D   + 1.D^2 + 1.D^3
##
##prbs=prbs_generator([1 3 4],{[1 2 4]},[1 0 1 1]);
##prbs_iterator(prbs,16)
##prbs_iterator(prbs,32)


##prbs=prbs_generator([7],{[1 7 6]},[1 0 0 1 0 0 0]);
##y=prbs_iterator(prbs,128);
##x=prbs_iterator(prbs,256);
