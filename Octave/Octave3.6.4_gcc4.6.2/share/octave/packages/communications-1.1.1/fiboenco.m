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
## @deftypefn {Function File} {} fiboenco (@var{num})
## 
## Returns the cell-array of encoded fibonacci value from the column vectors @var{num}.
## Universal codes like fibonacci codes have a useful synchronization
## property, only for 255 maximum value we have designed these routines. We assume
## user has partitioned the code into several unique segments based on
## the suffix property of unique elements [1 1] and we just decode the
## parts. Partitioning the stream is as simple as identifying the [1 1]
## pairs that occur, at the terminating ends. This system implements
## the standard binaary Fibonacci codes, which means that row vectors
## can only contain 0 or 1. Ref: http://en.wikipedia.org/wiki/Fibonacci_coding
## Ugly O(k.N^2) encoder.Ref: Wikipedia article accessed March, 2006.
## @url{http://en.wikipedia.org/wiki/Fibonacci_coding},  UCI Data Compression
## Book, @url{http://www.ics.uci.edu/~dan/pubs/DC-Sec3.html}, (accessed 
## October 2006)
## 
## @example
## @group
##      fiboenco(10) #=  code is @{[ 0 1 0 0 1 1]@}
##      fiboenco(1:4) #= code is @{[1 1],[0 1 1],[0 0 1 1],[1 0 1 1]@}
## @end group
## @end example
## @end deftypefn
## @seealso{fibodeco}

function op_num=fiboenco(num)
     %
     % generate fibonacci series table.
     %
     % f(1)=1;
     % f(2)=1;
     %
     % while ((f(end-1)+f(end)) < 256)
     %     val=(f(end-1)+f(end));
     %     f=[f val];
     % end
     % f=sort(f(2:end),"descend");
     %

     %f= [75025   46368   28657   17711   10946    6765    4181    2584 \
     %	 1597     987	 610     377     233     144      89      55 \
     %	 34      21      13   8       5       3       2       1];
     
     if(nargin < 1) || (min(num) <= 0 || max(num) > 608)
       error("Usage:fiboenco(num), where num is +ve sequence of numbers ...
       and less than equal to 608");
     end
     f= [ 233   144    89    55    34    21    13     8     5     3     2     1];
     
     onum=num;
     LEN_F=length(f);
     LEN_N=length(num);
     
     for j=1:LEN_N
       N=num(j);
       rval=[];

       %create Fibonacci encoding of a number
       for i=find(f<=N):LEN_F
	 if(N >= f(i))
	   N=N-f(i);
	   rval=[1 rval];
	 else
	   rval=[0 rval];
	 end
       end      
       op_num{j}=[rval 1];
     end
     return
end
%!
%!assert(fibodeco(fiboenco(1:600)),[1:600])
%!
