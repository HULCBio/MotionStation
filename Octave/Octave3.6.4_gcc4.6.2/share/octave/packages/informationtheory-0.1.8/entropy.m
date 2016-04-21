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
## @deftypefn {Function File} {} entropy (@var{symbol_probabilites}, @var{base})
##
## Computes the Shannon entropy of a discrete source whose
## probabilities are by @var{symbol_probabilities}, and optionally 
## @var{base} can be specified. Base of logarithm defaults to 2,
## when the entropy can be thought of as a measure of bits
## needed to represent any message of the source. For example
##
## @example
## @group
##          entropy([0.25 0.25 0.25 0.25]) @result{} ans = 2
##          entropy([0.25 0.25 0.25 0.25],4) @result{} ans = 1
## @end group
## @end example
## @end deftypefn

function val=entropy(symprob,base)
  if nargin < 1
       error("usage: entropy(symbol_probability_list); computes entropy in base-2");
  elseif nargin < 2
       base=2;
  end
  val=0.0;

  #eliminate zeros from x.
  x=symprob(symprob > 0);

  val=-sum(log10(x).*x)/log10(base);
  return
end
%!
%!assert(entropy([0.25 0.25 0.25 0.25]),2,0)
%!
