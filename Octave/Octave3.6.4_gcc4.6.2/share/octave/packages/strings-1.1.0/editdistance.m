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
## @deftypefn {Function File} {[@var{dist},@var{L}] =} editdistance (@var{string1}, @var{string2}, @var{weights})
## Compute the Levenshtein edit distance between the strings @var{string1} and
## @var{string2}. This operation is symmetrical.
##
## The optional argument @var{weights} specifies weights for the
## deletion, matched, and insertion operations; by default it is set to
## +1, 0, +1 respectively, so that a least editdistance means a 
## closer match between the two strings. This function implements
## the Levenshtein edit distance as presented in Wikipedia article,
## accessed Nov 2006. Also the levenshtein edit distance of a string
## with an empty string is defined to be its length.
## 
## The default return value is @var{dist} the edit distance, and
## the other return value  @var{L} is the distance matrix.
##
## @example
## @group
##          editdistance('marry','marie') 
##          ##returns value +2 for the distance.
## @end group
## @end example
##
## @end deftypefn

function [dist, L] = editdistance (str1, str2, weights)
  if(nargin < 2 || (nargin == 3 && length(weights)  < 3) )
    print_usage();
  end
  
  L1=length(str1)+1;
  L2=length(str2)+1;
  L=zeros(L1,L2);
  
  if(nargin < 3)
    g=+1;%insertion
    m=+0;%match
    d=+1;%deletion
  else
    g=weights(1);
    m=weights(2);
    d=weights(3);
  end

  L(:,1)=[0:L1-1]'*g;
  L(1,:)=[0:L2-1]*g;
  
  m4=0;
  for idx=2:L1;
    for idy=2:L2
      if(str1(idx-1)==str2(idy-1))
        score=m;
      else
        score=d;
      end
      m1=L(idx-1,idy-1) + score;
      m2=L(idx-1,idy) + g;
      m3=L(idx,idy-1) + g;
      L(idx,idy)=min(m1,min(m2,m3));
    end
  end
  
  dist=L(L1,L2);
endfunction
