## Copyright (C) 2004-2011 David Legland <david.legland@grignon.inra.fr>
## Copyright (C) 2004-2011 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas)
## Copyright (C) 2012 Adapted to Octave by Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
## All rights reserved.
## 
## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions are met:
## 
##     1 Redistributions of source code must retain the above copyright notice,
##       this list of conditions and the following disclaimer.
##     2 Redistributions in binary form must reproduce the above copyright
##       notice, this list of conditions and the following disclaimer in the
##       documentation and/or other materials provided with the distribution.
## 
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ''AS IS''
## AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
## IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
## ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
## ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
## DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
## SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
## CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
## OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
## OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{y} =} polygon (@var{x})
## Returns a simple closed path that passes through all the points in @var{x}.
## @var{x} is a vector containing 2D coordinates of the points.
##
## @end deftypefn

## Author: Simeon Simeonov <simeon.simeonov.s@gmail.com>

function y = closed_path(x)

  if(size(x,1) > 1 && size(x,1) < size(x,2))
      x = x';
  end

  N = size(x,1); # Number of points
  idx = zeros(N, 1); # ind contains the indices of the sorted coordinates

  a = find(x(:,2)==min(x(:,2)));

  if(size(a,1) > 1)
      [~, i] = sort(x(a,1));
      a = a(i(1));
  end

  x_1 = x(x(:,2)==x(a,2),:); # find all x with the same y coordinate

  if(x(a,1) == min(x(:,1)))
      x_2 = x(x(:,1)==x(a,1),:); # find all x with the same x coordinate
  else
     x_2 = x(a,:);
  end

  if(size(x_1,1) > 1 || size(x_2,1) > 1)
      if(size(x_1,1) > 1)
          x_1 = sort(x_1); # Sort by x coordinate
          y(1,:) = x(a,:); # original starting point
      end

      if (size(x_2,1) > 1)
          x_2 = sort(x_2, 'descend');
      end

      x_not = [x_1; x_2];
      i = ismember(x,x_not,'rows');
      x(i, :) = [];
      x = [x_1(size(x_1,1),:); x];
      x_1(size(x_1, 1),:) = [];
      N = size(x,1);
      a = 1;
  else
      x_1 = [];
      x_2 = x(a,:);
  end
  d = x - repmat(x(a,:), N, 1);
  th = d(:,2)./(d(:,1) + d(:,2));

  [~, idx0] = ismember(sort(th(th==0)), th);
  [~, idx1] = ismember(sort(th(th>0)), th);
  [~, idx2] = ismember(sort(th(th<0)), th);

  idx = [a; idx0; idx1; idx2];
  # I contains the indices of idx in a sorted order. [v i] = sort(idx) then
  # i==I.
  [~,I,J]= unique(idx);
  if(size(I,1) ~= size(J,1))
      R = histc(J, 1:size(I,1)); # R(1) will always be 1?
      idx_sorted = idx(I);
      r = find(R>1);
      for ri = r'
          idx_repeated = idx_sorted(ri);
          idx(idx==idx_repeated) = find(th==th(idx_sorted(ri)));
      end
  end

  y = [x_1; x(idx,:); x_2;];

endfunction

%!demo
%! maxInt = 100;
%! N = 25;
%!
%! for i = 1:5
%!   x = randi(maxInt, N, 2);
%!   y = closed_path(x);
%!   plot(y(:,1), y(:,2), '*');
%!   hold on;
%!   plot(y(:,1), y(:,2));
%! end
