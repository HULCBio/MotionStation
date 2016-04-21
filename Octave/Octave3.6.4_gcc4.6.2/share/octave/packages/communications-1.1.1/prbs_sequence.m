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

## Implement book keeping for a Pseudo-Random Binary Sequence ( PRBS )
## also called as a Linear Feedback Shift Register.
## 
## For the given PRBS in a intial state, compute the PRBS sequence length.
## Length is period of output when the PRBS state is same as 
## the start state of PRBS.
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
## x = prbs_sequence(prbs) #gives 15
## 
##
## See Also: This function is to be used along with functions 
## prbs_generator.

function [itrs,seq]=prbs_sequence(prbs)
  if nargin != 1
    print_usage;
  endif
  nstate=zeros(1,prbs.reglen);
  itrs=0; seq = [];
  inits = prbs.sregs;
  
  ## For each iteration, shift the output bit. Then compute the xor pattern of connections. 
  ## Finally apply feedback the stuff. Insert the computed pattern.
  while( true )
    itrs = itrs + 1;
    
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
    seq = [seq, prbs.sregs(end)];
    prbs.sregs=[0 prbs.sregs(1:prbs.reglen-1)];

    ## insert the feedback.
    for itr2=1:prbs.conlen
      prbs.sregs(itr2)=nstate(itr2);
      nstate(itr2)=0; # reset.
    endfor
    
    if(isequal(prbs.sregs,inits))
      break
    endif
  endwhile
end
