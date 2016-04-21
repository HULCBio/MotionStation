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
## @deftypefn {Function File} {@var{y} = } pammod (@var{x}, @var{m})
## @deftypefnx {Function File} {@var{y} = } pammod (@var{x}, @var{m}, @var{phi})
## @deftypefnx {Function File} {@var{y} = } pammod (@var{x}, @var{m}, @var{phi}, @var{type})
##
## Modulates an information sequence of integers @var{x} in the range 
## @code{[0 @dots{} M-1]} onto a pulse amplitude modulated signal @var{y}. 
## @var{phi} controls the initial phase and @var{type} controls the 
## constellation mapping. If @var{type} is set to 'Bin' will result in 
## binary encoding, in contrast, if set to 'Gray' will give Gray encoding.
## An example of Gray-encoded 8-PAM is
##
## @example
## @group
## d = randint(1,1e4,8);
## y = pammod(d,8,0,'Gray');
## z = awgn(y,20);
## plot(z,'rx')
## @end group
## @end example
## @end deftypefn
## @seealso{pamdemod}

function y=pammod(x,M,phi,type)

if nargin<2
	usage("y = pammod (x, M, [phi, [type]])");   
endif    

m=0:M-1;
if ~isempty(find(ismember(x,m)==0))
	error("x elements should be integers in the set [0, M-1].");
endif	

if nargin<3
    phi=0;
endif

if nargin<4
	type="Bin";
endif	

constellation=[-M+1:2:M-1].*exp(-1j*phi);

if (strcmp(type,"Bin")||strcmp(type,"bin"))
    y=constellation(x+1);
elseif (strcmp(type,"Gray")||strcmp(type,"gray"))
    [a,b]=sort(bitxor(m,bitshift(m,-1)));
    y=constellation(b(x+1));
else
    usage("y = pammod (x, M, [phi, [type]])");
endif

if (iscomplex(y) && all (imag(y(:)) == 0))
  y = real (y);
endif


%!assert(round(pammod([0:7],8,0,'Bin')),[-7:2:7])
%!assert(round(pammod([0:7],8,0,'Gray')),[-7 -5 -1 -3 7 5 1 3])
