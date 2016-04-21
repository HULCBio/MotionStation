## Copyright (C) 2006 Muthiah Annamalai <muthiah.annamalai@uta.edu>
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.
##

## -*- texinfo -*-
## @deftypefn {Function File} {} arithmetic_encode (@var{message}, @var{symbol_probabilites_list})
##
## Computes the arithmetic code for the message with symbol
## probabilities are given. The arithmetic coding procedure assumes
## that @var{message} is a list of numbers and the symbol probabilities
## correspond to the index. For example
##
## @example
## @group
##          symbols=[1,2,3,4]; sym_prob=[0.5 0.25 0.15 0.10];
##          message=[1, 1, 2, 3, 4];
##          arithmetic_encode(message,sym_prob) ans=0.18078
## @end group
## @end example
## @end deftypefn
## @seealso{arithmetic_decode}

%  FIXME
% -------
% Limits on floating point lengths. Not fool proof 
% (interval doubling? not implemented).
%
% First assume that the list is in symbolic-order 
% (sorting not necessary). 
%
% Message is an array of symbols (numbers).
%
function tag=arithmetic_encode(message,problist)
  if nargin < 2
      error('Usage: arithmetic_encode(message,problist)');
  end

  Up=1;
  Lo=0;
  L_MSG=length(message);

  for itr=1:L_MSG
    Mi=message(itr);
    T1=Lo;
    T2=+(Up-Lo);
    T3=sum(problist(1:Mi)); 
    Lo=T1+T2*(T3-problist(Mi));
    Up=T1+T2*T3;
  end

  tag=0.5*(Up+Lo);
  return;
end
%!arithmetic_encode([1, 1, 2, 3, 4],[0.5 0.25 0.15 0.10]),0.18078,1e-4)
