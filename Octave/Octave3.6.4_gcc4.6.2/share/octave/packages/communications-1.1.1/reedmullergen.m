## Copyright (C) 2007 Muthiah Annamalai <muthiah.annamalai@uta.edu>
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
## @deftypefn {Function File} {}  reedmullergen (@var{R},@var{M})
##
## Definition type construction of Reed Muller code,
## of order @var{R}, length @math{2^M}. This function
## returns the generator matrix for the said order RM code.
## 
## RM(r,m) codes are characterized by codewords,
## @code{sum ( (m,0) + (m,1) + @dots{} + (m,r)}.
## Each of the codeword is got through spanning the
## space, using the finite set of m-basis codewords.
## Each codeword is @math{2^M} elements long.
## see: Lin & Costello, "Error Control Coding", 2nd Ed.
##
## Faster code constructions (also easier) exist, but since 
## finding permutation order of the basis vectors, is important, we 
## stick with the standard definitions. To use decoder
## function reedmullerdec,  you need to use this specific
## generator function.
##
## @example
## @group
## G=reedmullergen(2,4);
## @end group
## @end example
##
## @end deftypefn
## @seealso{reedmullerdec,reedmullerenc}
function G=reedmullergen(R,M)
    if ( nargin < 2 )
       print_usage();
    end

    G=ones(1,2^M);
    if ( R == 0 )
        return;
    end
    
    a=[0];
    b=[1];
    V=[];
    for idx=1:M;
        row=repmat([a,b],[1,2^(M-idx)]);
        V(idx,:)=row;
        a=[a,a];
        b=[b,b];
    end
    
    G=[G; V];

    if ( R == 1 )
        return
    else
        r=2;
        while r <= R
            p=nchoosek(1:M,r);
            prod=V(p(:,1),:).*V(p(:,2),:);
            for idx=3:r
                prod=prod.*V(p(:,idx),:);
            end
            G=[G; prod];
            r=r+1;
        end
    end
    return
end
