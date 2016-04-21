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
## @deftypefn {Function File} {}  systematize (@var{G})
## 
## Given @var{G}, extract P partiy check matrix. Assume row-operations in GF(2).
## @var{G} is of size KxN, when decomposed through row-operations into a @var{I} of size KxK
## identity matrix, and a parity check matrix @var{P} of size Kx(N-K).
## 
## Most arbitrary code with a given generator matrix @var{G}, can be converted into its
## systematic form using this function.
##
## This function returns 2 values, first is default being @var{Gx} the systematic version of
## the @var{G} matrix, and then the parity check matrix @var{P}.
##
## @example
## @group
##   G=[1 1 1 1; 1 1 0 1; 1 0 0 1];
##   [Gx,P]=systematize(G);
##    
##   Gx = [1 0 0 1; 0 1 0 0; 0 0 1 0];
##   P = [1 0 0];
## @end group
## @end example
##
## @end deftypefn
## @seealso{bchpoly,biterr}
function [G,P]=systematize(G)
    if ( nargin < 1 )
         print_usage();
    end
    
    [K,N]=size(G);

    if ( K >= N )
         error('G matrix must be ordered as KxN, with K < N');
    end
    
    %
    % gauss-jordan echelon formation,
    % and then back-operations to get I of size KxK
    % remaining is the P matrix.
    % 
    
    for row=1:K
    
    %
    %pick a pivot for this row, by finding the
    %first of remaining rows that have non-zero element
    %in the pivot.
    %
    
    found_pivot=0;
    if ( G(row,row) > 0 )
       found_pivot=1;
    else
     %
     % next step of Gauss-Jordan, you need to
     % re-sort the remaining rows, such that their
     % pivot element is non-zero.
     %    
     for idx=row+1:K
        if ( G(idx,row) > 0 )            
            tmp=G(row,:);
            G(row,:)=G(idx,:);
            G(idx,:)=tmp;
            found_pivot=1;
            break;
        end
     end
    end
  
    %
    %some linearly dependent problems:
    %
    if ( ~found_pivot )
        error('cannot systematize matrix G');
        return
    end

    %
    % Gauss-Jordan method:
    % pick pivot element, then remove it
    % from the rest of the rows.
    %    
    for idx=row+1:K
        if( G(idx,row) > 0 )
            G(idx,:)=mod(G(idx,:)+G(row,:),2);
        end
    end 
    
    end
      
    %
    % Now work-backward.       
    %
    for row=K:-1:2
        for idx=row-1:-1:1
            if( G(idx,row) > 0 )
                G(idx,:)=mod(G(idx,:)+G(row,:),2);
            end
        end
    end
    
    %I=G(:,1:K);
    P=G(:,K+1:end);
    return;
end
