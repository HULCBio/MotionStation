## Copyright (c) 2010 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{clusteridx} =} clustersegment (@var{unos})
## Calculate boundary indexes of clusters of 1's.
##
## The function calculates the initial index and end index of the sequences of
## 1's in the rows of @var{unos}. The result is returned in a cell of size
## 1-by-Np, being Np the numer of rows in @var{unos}. Each element of the cell
## has two rows. The first row is the inital index of a sequence of 1's and the
## second row is the end index of that sequence.
##
## If Np == 1 the output is a matrix with two rows.
##
## @end deftypefn

function contRange = clustersegment(xhi)

  % Find discontinuities
  bool_discon = diff(xhi,1,2);
  [Np Na] = size(xhi);
  contRange = cell(1,Np);

  for i = 1:Np
      idxUp = find(bool_discon(i,:)>0)+1;
      idxDwn = find(bool_discon(i,:)<0);
      tLen = length(idxUp) + length(idxDwn);

      if xhi(i,1)==1
      % first event was down
          contRange{i}(1) = 1;
          contRange{i}(2:2:tLen+1) = idxDwn;
          contRange{i}(3:2:tLen+1) = idxUp;
      else
      % first event was up
          contRange{i}(1:2:tLen) = idxUp;
          contRange{i}(2:2:tLen) = idxDwn;
      end

      if xhi(i,end)==1
      % last event was up
         contRange{i}(end+1) = Na;
      end

      tLen = length(contRange{i});
      if tLen ~=0
        contRange{i}=reshape(contRange{i},2,tLen/2);
      end

  end

  if Np == 1
   contRange = cell2mat (contRange);
  end

endfunction

%!demo
%! xhi = [0 0 1 1 1 0 0 1 0 0 0 1 1];
%! ranges = clustersegment (xhi)
%!
%! % The first sequence of 1's in xhi lies in the interval
%! ranges(1,1):ranges(2,1)

%!demo
%! xhi = rand(3,10)>0.4
%! ranges = clustersegment(xhi)
