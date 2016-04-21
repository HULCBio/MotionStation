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
## Given a polynomial create a PRBS structure for that polynomial.
## Now all we need is to just create this polynomial and make it work.
## polynomial must be a vector containing the powers of x and an optional
## value 1. eg: x^3 + x^2 + x + 1 must be written as [3 2 1 0]
## all the coefficients are either 1 or 0. It generates only a Binary \
## sequence, and the generator polynomial need to be only a binary
## polynomial in GF(2).
## 
## connections, contains a struct of vectors where each vector is the
## connection list mapping its vec(2:end) elements to the vec(1) output.
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
## The code to implement this PRBS with a start state of [1 0 1 1]
## will be:
## 
## prbs=prbs_generator([1 3 4],{[1 3 4]},[1 0 1 1]);
## x = prbs_sequence(prbs) #gives 15
## 
## prbs_iterator( prbs, 15 ) #15 binary digits seen
## [ 1   1   0   1   0   1   1   1   1   0   0   0   1   0   0 ]
## 
## See Also: This function is to be used along with functions 
## prbs_iterator, and prbs_sequence.

function prbs=prbs_generator(polynomial,connections,initstate)
  prbs.reglen=max(polynomial);
  prbs.polynomial=polynomial;
  prbs.sregs=initstate;
  prbs.connections=connections;
  prbs.conlen=length(connections);
end
