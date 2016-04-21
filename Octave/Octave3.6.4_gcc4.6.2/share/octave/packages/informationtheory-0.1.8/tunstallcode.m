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

## -*- texinfo -*-
## @deftypefn {Function File} {@var{code_dictionary} =} tunstallcode (@var{probability_list})
##
## Implementation of a @code{|A|}-bit tunstall coder given the source 
## probability of the @code{|A|} symbols from the source with @code{2^|A|} 
## code-words involved. The variable @var{probability_list} ordering of 
## symbols is preserved in the output symbol/code dictionary.
## Tunstall code is a variable to fixed source coding scheme,
## and the arrangement of the codeword list order corrseponds to
## to the regular tunstall code ordering of the variable source 
## word list, and the codes for each of them are enumerations 
## from @code{1:2^N}. Return only the ordering (grouping) of source symbols
## as their index of match is the corresponding code word. The
## probabilites of the various symbols are also stored in here.
## for example
##
## @example
##   [cw_list, prob_list] = tunstallcode([0.6 .3 0.1]) 
## @end example
##
## essentially you will use the cw_list to parse the input
## and then compute the code as the binary value of their index
## of match, since it is a variable to fixed code.
##
## Reference: "Synthesis of noiseless compression codes", Ph.D. Thesis
##             of B.P. Tunstall, Georgia Tech, Sept 1967
## @end deftypefn

function [cw_list,prob_list]=tunstallcode(prob_list)
  if nargin < 1
    error('usage: tunstallcode(probability_list)');
  end
  
  N=length(prob_list);
  S=1:N;
  CWMAX=2**N;
  porig_list=prob_list;
  
  prob_op=prob_list;
  for idx=1:N
    cw_list{idx}=sprintf("%d",idx);
  end

  while ((length(cw_list)+N-1) <= CWMAX)
    L=length(cw_list);

    %
    %assuming maximum of list is on top.
    %i.e: all lists are in descending order.
    %
    base=cw_list{1};
    base_prob=prob_list(1);
    
    prob_list=[prob_list(2:end) base_prob];
    cw_list={cw_list{2:end}};

    for idx=1:N
      prob_list(L+idx-1)=base_prob*porig_list(idx);
      w=sprintf("%s%d",base,idx);
      cw_list{L+idx-1}=w;
    end
    
    idx=find(prob_list==max(prob_list));
    prob_list=[prob_list(idx) prob_list(1:idx-1) prob_list(idx+1:end)];
    cw_list={cw_list{idx} cw_list{1:idx-1} cw_list{idx+1:end}};
  end

  return
end
%!assert(tunstallcode([0.7 0.3]),{"111","2","12","112"})

%
%P=[  0.500000   0.250000   0.125000   0.125];
%tunstallcode(P)
%tunstallcode([0.6 .3 0.1])
%

