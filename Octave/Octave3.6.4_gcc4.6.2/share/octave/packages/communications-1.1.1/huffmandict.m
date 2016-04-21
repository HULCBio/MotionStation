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

## -*- texinfo -*-
## @deftypefn {Function File} {}  huffmandict (@var{symb}, @var{prob})
## @deftypefnx {Function File} {}  huffmandict (@var{symb}, @var{prob}, @var{toggle})
## @deftypefnx {Function File} {}  huffmandict (@var{symb}, @var{prob}, @var{toggle}, @var{minvar})
##
## Builds a Huffman code, given a probability list. The Huffman codes 
## per symbol are output as a list of strings-per-source symbol. A zero 
## probability symbol is NOT assigned any codeword as this symbol doesn't 
## occur in practice anyway.
##
## @var{toggle} is an optional argument with values 1 or 0, that starts 
## building a code based on 1's or 0's, defaulting to 0. Also @var{minvar} 
## is a boolean value that is useful in choosing if you want to optimize 
## buffer for transmission in the applications of Huffman coding, however 
## it doesn't affect the type or average codeword length of the generated 
## code. An example of the use of @code{huffmandict} is
##
## @example
## @group
##   huffmandict(symbols, [0.5 0.25 0.15 0.1]) => CW(0,10,111,110)
##   huffmandict(symbols, 0.25*ones(1,4)) => CW(11,10,01,00)
##
##   prob=[0.5 0 0.25 0.15 0.1]
##   dict=huffmandict(1:5,[0.5 0 0.25 0.15 0.1],1)
##   entropy(prob)
##   laverage(dict,prob)
##         
##   x =   [0.20000   0.40000   0.20000   0.10000   0.10000];
##   #illustrates the minimum variance thing.
##   huffmandict(1,x,0,true) #min variance tree.
##   huffmandict(1,x)     #normal huffman tree.
## @end group
## @end example
##
## Reference: Dr.Rao's course EE5351 Digital Video Coding, at UT-Arlington.
## @seealso{huffmandeco, huffmanenco}
## @end deftypefn

## Huffman code algorithm.
## while (uncombined_symbols_remain)
##       combine least probable symbols into one with,
##      their probability being the sum of the two.
##       save this result as a stage at lowest order rung.
##       (Moving to lowest position possible makes it non-minimum variance
##        entropy coding)
## end
##
## for each (stage)
## Walk the tree we built, and assign each row either 1,
## or 0 of 
## end
## 
## reverse each symbol, and dump it out.
##

function cw_list = huffmandict (sym, source_prob, togglecode = 0, minvar = 0)
  if nargin < 2
    print_usage;
  ## need to compare to 1
  elseif((sum(source_prob)-1.0) > 1e-7 )
    error("source probabilities must add up to 1.0");
  end

  %
  %need to find & eliminate the zero-probability code words.
  %in practice we donot need to assign anything to them. Reasoning
  %being that if_ it doesnt occur why bother saving its value anyway?
  %--(Oct 9) Actually some experts in the area dont agree to this,
  %and being a generic implementation we should stick to generating
  %CW's for_ zero symbols. Why impose a bad implementation? --Muthu
  % 
  
  origsource_prob=source_prob;

  %
  %sort the list and know the index transpositions. kills the speed O(n^2).
  %
  L=length(source_prob);
  index=[1:L];
  for itr1=1:L
    for itr2=itr1:L
      if(source_prob(itr1) < source_prob(itr2))
        t=source_prob(itr1);
        source_prob(itr1)=source_prob(itr2);
        source_prob(itr2)=t;

        t=index(itr1);
        index(itr1)=index(itr2);
        index(itr2)=t;
      end
    end
  end
  
  stage_list = {};
  cw_list    = cell(1,L);

  stage_curr={};
  stage_curr.prob_list=source_prob;
  stage_curr.sym_list={};
  S=length(source_prob);
  for i=1:S; 
    stage_curr.sym_list{i}=[i];
    #cw_list{i}="";
  end

  %
  % another O(n^2) part.
  %
  I=1;
  while (I<S)
    L=length(stage_curr.prob_list);
    nprob=stage_curr.prob_list(L-1)+stage_curr.prob_list(L);
    nsym=[stage_curr.sym_list{L-1}(1:end),stage_curr.sym_list{L}(1:end)];

    %stage_curr;
    %archive old stage list.
    stage_list{I}=stage_curr;

    %
    %insert the new probability into the list, at the
    %first-position (greedy?) possible.
    %
    for i=1:(L-2)
      if((minvar && stage_curr.prob_list(i)<=nprob) || \
          stage_curr.prob_list(i) < nprob)
        break;
      end
    end
    


    stage_curr.prob_list=[stage_curr.prob_list(1:i-1) nprob stage_curr.prob_list(i:L-2)];
    stage_curr.sym_list={stage_curr.sym_list{1:i-1}, nsym, stage_curr.sym_list{i:L-2}};

    % Loopie
    I=I+1;
  end

  if (togglecode==0)
      one_cw=1;
      zero_cw=0;
  else
     one_cw=0;
     zero_cw=1;
  end

  %
  % another O(n^2) part.
  %
  %printf("Exit Loop");
  I=I-1;
  while (I>0)
    stage_curr=stage_list{I};
    L=length(stage_curr.sym_list);

    clist=stage_curr.sym_list{L};
    for k=1:length(clist)
      cw_list{1,clist(k)}=[cw_list{1,clist(k)} one_cw];
    end

    clist=stage_curr.sym_list{L-1};
    for k=1:length(clist)
      cw_list{1,clist(k)}=[cw_list{1,clist(k)}, zero_cw];
    end

    % Loopie
    I=I-1;
  end

  %
  %zero all the code-words of zero-probability length, 'cos they
  %never occur.
  %
  S=length(source_prob);
  for itr=(S+1):length(origsource_prob)
    cw_list{1,itr}=-1;
  end

  %disp('Before resorting')
  %cw_list

  nw_list = cell(1,L);
  %
  % Re-sort the indices according to the probability list.
  %
  L=length(source_prob);
  for itr=1:(L)
    t=cw_list{index(itr)};
    nw_list{index(itr)}=cw_list{itr};
  end
  cw_list=nw_list;
  
  %zero all the code-words of zero-probability length, 'cos they
  %never occur.
  
  %for itr=1:L
  %  if(origsource_prob(itr)==0)
  %    cw_list{itr}="";
  %  end
  %end

  return
end

%!assert(huffmandict(1:4,[0.5 0.25 0.15 0.1],1), {[0],[1 0],[1 1 1],[1 1 0]},0)
%!assert(huffmandict(1:4,0.25*ones(1,4),1),{[1 1],[1 0],[0 1],[0 0]},0)
%!assert(huffmandict(1:4,[1  0 0 0 ]),{[1],[0 1],[0 0 0],[0 0 1]},0)
