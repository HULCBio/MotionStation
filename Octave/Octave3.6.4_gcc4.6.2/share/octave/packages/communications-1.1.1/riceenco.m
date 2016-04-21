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
## @deftypefn {Function File} {} riceenco (@var{sig}, @var{K})
##
## Returns the Rice encoded signal using @var{K} or optimal K . 
## Default optimal K is chosen between 0-7. Currently no other way
## to increase the range except to specify explicitly. Also returns
## @var{K} parameter used (in case it were to be chosen optimally) 
## and @var{Ltot} the total length of output code in bits.
## This function uses a @var{K} if supplied or by default chooses
## the optimal K for encoding signal vector into a rice coded vector.
## A restrictions is that a signal set must strictly be non-negative.
## The Rice algorithm is used to encode the data into unary coded
## quotient part which is represented as a set of 1's separated from
## the K-part (binary) using a zero. This scheme doesnt need any 
## kind of dictionaries and its close to O(N), but this implementation
## *may be* sluggish, though correct.
##
## Reference: Solomon Golomb, Run length Encodings, 1966 IEEE Trans
## Info' Theory
##
## An exmaple of the use of @code{riceenco} is
## @example
## @group
##   riceenco(1:4) #  
##   riceenco(1:10,2) # 
## @end group
## @end example
## @end deftypefn
## @seealso{ricedeco}

function [rcode,K,Ltot]=riceenco(sig,K)
  if ( nargin < 1 )
    error('usage: riceenco(sig,{K})');
  elseif (nargin < 2)
    use_optimal_k=1;
  else
    use_optimal_k=0;
  end

  if (min(sig) < 0)
    error("signal has elements that are outside alphabet set ...
	. Accepts only non-negative numbers. Cannot encode.");
  end

    
  L=length(sig);

  ##compute the optimal rice parameter.
  if(use_optimal_k)
    k_opt=0;
    len_past=sum(sig)+L+k_opt*L;
    quot=sig;
    
    for k=1:7
      k_pow_2=2**k;
      quot_k=floor(sig./k_pow_2);
      len=sum(quot_k)+L+k*L;
      if(len < len_past)
	len_past=len;
	k_opt=k;
	rem=mod(sig,k_pow_2);
	quot=quot_k;
      end
    end
    Ltot=len_past;
    K=k_opt;
    K_pow_2=2**K;
  else
    K_pow_2=2**K;
    quot=floor(sig./K_pow_2);
    rem=mod(sig,K_pow_2);
  end

  for j=1:L
    rice_part=zeros(1,K);
    %
    % How can we eliminate this loop?
    % I essentially need to get the binary
    % representation of rem(j) in the rice_part(i)
    %
    for i=K:-1:1
      rice_part(i)=mod(rem(j),2);
      rem(j)=floor(rem(j)/2);
    end
    rcode{j}=[ones(1,quot(j)) 0 rice_part];
  end
  Ltot=sum(quot)+L+K*L;
  
  return
end
%! 
%! assert(riceenco(1:4,2),{[0 0 1],[0 1 0], [0 1 1], [ 1 0 0 0]})
%! 
