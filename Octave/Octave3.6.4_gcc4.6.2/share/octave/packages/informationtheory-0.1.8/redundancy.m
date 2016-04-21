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
## @deftypefn {Function File} {} redundancy (@var{code_word_list}, @var{symbol_probabilites})
##
## Computes the wasted excessive bits over the entropy when using a
## particular coding scheme. For example
##
## @example
## @group
##          prob_list = [0.5 0.25 0.15 0.1];
##          min_bits = entropy(prob_list);
##          cw_list = huffman(prob_list);
##          redundancy(cw_list,prob_list)
## @end group
## @end example
## @end deftypefn

function [val,ent,lavg]=redundancy(code_word_list,symprob)
  if ( nargin < 2 )
       error("usage: redundancy(code_word_list,symbol_probability_list); computes entropy in base-2");
  end
  
  #eliminate zeros from x.
  ent=entropy(symprob);
  lavg=laverage(code_word_list,symprob);
  val=1.0-(ent/lavg);
  return
end
%!
%!assert(redundancy({"1","01","000","001"},[0.5 0.25 0.15 0.1]),0.0041499,1e-3)
%!assert(redundancy({"00","01","10","11"},[0.25 0.25 0.25 0.25]),0,0)
%!
