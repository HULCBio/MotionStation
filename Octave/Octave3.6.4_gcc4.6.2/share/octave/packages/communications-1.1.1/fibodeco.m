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
## @deftypefn {Function File} { } fibodeco (@var{code})
## 
## Returns the decoded fibonacci value from the binary vectors @var{code}.
## Universal codes like fibonacci codes Have a useful synchronization property,
## only for 255 maximum value we have designed these routines. We assume
## user has partitioned the code into several unique segments based on
## the suffix property of unique strings "11" and we just decode the
## parts. Partitioning the stream is as simple as identifying the
## "11" pairs that occur, at the terminating ends. This system implements
## the standard binaary Fibonacci codes, which means that row vectors
## can only contain 0 or 1. Ref: @url{http://en.wikipedia.org/wiki/Fibonacci_coding}
## 
## @example
## @group
##     fibodeco(@{[0 1 0 0 1 1]@}) %decoded to 10
##     fibodeco(@{[1 1],[0 1 1],[0 0 1 1],[1 0 1 1]@}) %[1:4]
## @end group
## @end example
## @end deftypefn
## @seealso{fiboenco}
  
function num=fibodeco(code)
  ##
  ## generate fibonacci series table.
  ##
  ## f(1)=1;
  ## f(2)=1;
  ##
  ## while ((f(end-1)+f(end)) < 256)
  ##    val=(f(end-1)+f(end));
  ##    f=[f val];
  ## end
  ## f=f(2:end);
  ##
  ##all numbers terminate with 1 except 0 itself.
  ##
  ##
  ##f= [75025   46368   28657   17711   10946    6765    4181    2584 \
  ##	 1597     987	 610     377     233     144      89      55 \
  ##	 34      21      13   8       5       3       2       1];
  ##
  ##f= [ 233   144    89    55    34    21    13     8     5     3  2     1];

  f= [  1     2     3     5     8    13    21    34    55    89   144   233];     
  L_C=length(code);

  if (nargin < 1)
    error("Usage:fibodec(cell-array vectors), where each vector is +ve sequence of numbers ...
	      either 1 or 0");
  end

  for j=1:L_C
    word=code{j};
    ##discard the terminating 1.
    word=word(1:end-1);
    L=length(word);
    num(j)=sum(word.*f(1:L));
  end
  
  return
end
%!
%! assert(fibodeco({[1 1],[0 1 1],[0 0 1 1],[1 0 1 1]}),[1:4])
%! assert(fibodeco({[0 1 0 0 1 1]}),10)
%!
