## Copyright (C) 2006 Charalampos C. Tsimenidis
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

## -*- texinfo -*-
## @deftypefn {Function File} {@var{y} =} genqammod (@var{x}, @var{c})
##
## Modulates an information sequence of intergers @var{x} in the range
## @code{[0 @dots{} M-1]} onto a quadrature amplitude modulated signal 
## @var{y}, where  @code{M = length(c) - 1} and @var{c} is a 1D vector 
## specifing the signal constellation mapping to be used. An example of
## combined 4PAM-4PSK is
##
## @example
## @group
##  d = randint(1,1e4,8);
##  c = [1+j -1+j -1-j 1-j 1+sqrt(3) j*(1+sqrt(3)) -1-sqrt(3) -j*(1+sqrt(3))];
##  y = genqammod(d,c);
##  z = awgn(y,20);
##  plot(z,'rx')
## @end group
## @end example
## @end deftypefn
## @seealso{genqamdemod}

function y=genqammod(x,c)

if nargin<2
	usage("y = genqammod (x, c)");   
endif    

m=0:length(c)-1;
if ~isempty(find(ismember(x,m)==0))
	error("x elements should be integers in the set [0, length(c)-1].");
endif	

y=c(x+1);

%!assert(genqammod([0:7],[-7:2:7]),[-7:2:7])
%!assert(genqammod([0:7],[-7 -5 -1 -3 7 5 1 3]),[-7 -5 -1 -3 7 5 1 3])
