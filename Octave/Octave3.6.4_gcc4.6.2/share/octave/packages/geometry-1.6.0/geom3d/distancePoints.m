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
## @deftypefn {Function File} {@var{d} =} distancePoints(@var{p1}, @var{p2})
## @deftypefnx {Function File} {@var{d} =} distancePoints(@var{p1}, @var{p2},@var{norm})
## @deftypefnx {Function File} {@var{d} = } distancePoints (@dots{}, @asis{'diag'})
## Compute euclidean distance between pairs of points in any dimension
##
##   Return distance @var{d} between points @var{p1} and
##   @var{p2}, given as [X Y Z @dots{} Wdim].
##
##   If @var{p1} and @var{p2} are two arrays of points, result is a N1-by-N2 array
##   containing distance between each point of @var{p1} and each point of @var{p2}.
##
##
##   @var{d} = distancePoints(@var{p1}, @var{p2}, @var{norm})
##   with @var{norm} being 1, 2, or Inf, corresponfing to the norm used. Default is
##   2 (euclidean norm). 1 correspond to manhattan (or taxi driver) distance
##   and Inf to maximum difference in each coordinate.
##
##   When 'diag' is given, computes only distances between @code{@var{p1}(i,:)} and @code{@var{p2}(i,:)}.
##   In this case the numer of points in each array must be the same.
##
## @seealso{points3d, minDistancePoints}
## @end deftypefn

function dist = distancePoints(p1, p2, varargin)

  norm = 2;
  diagonal = false;

  switch numel(varargin)
    case 0
      1;
    case 1
      if isnumeric (varargin{1})
        norm = varargin{1};
      else
        diagonal = true;
      end
    case 2
      norm = varargin{1};
      diagonal = true;
    otherwise
      print_usage;
  end

  # compute difference of coordinate for each all points
  [n1 dim] = size(p1);
  [n2 dim] = size(p2);
  if diagonal
    if n1 ~= n2
      error ("geometry:InvalidArgument",...
      "When option diag is given the number of points must be equal.\n");
    end
    ptsDiff = p2 - p1;
  else
    ptsDiff = zeros (n1,n2,dim);
    for i =1:dim
      ptsDiff(:,:,i) = p2(:,i)' - p1(:,i);
    end
  end

  # Return dist based on the type of measurement requested
  along_dim = length(size(ptsDiff));
  switch(norm)
      case 1
          dist = sum(abs(ptsDiff), along_dim);
      case 2
          if ~diagonal
            dist = reshape(vectorNorm (reshape(ptsDiff,n1*n2,dim)),n1,n2);
          else
            dist = vectorNorm (ptsDiff);
          end
      case Inf
          dist = max(abs(ptsDiff), [], along_dim);
      otherwise
          dist = sum(ptsDiff.^norm, along_dim).^(1/norm);
  end

endfunction

%!shared pt1,pt2,pt3,pt4
%!  pt1 = [10 10];
%!  pt2 = [10 20];
%!  pt3 = [20 20];
%!  pt4 = [20 10];

%!assert (distancePoints(pt1, pt2), 10, 1e-6);
%!assert (distancePoints(pt2, pt3), 10, 1e-6);
%!assert (distancePoints(pt1, pt3), 10*sqrt(2), 1e-6);
%!assert (distancePoints(pt1, pt2, 1), 10, 1e-6);
%!assert (distancePoints(pt2, pt3, 1), 10, 1e-6);
%!assert (distancePoints(pt1, pt3, 1), 20, 1e-6);
%!assert (distancePoints(pt1, pt2, inf), 10, 1e-6);
%!assert (distancePoints(pt2, pt3, inf), 10, 1e-6);
%!assert (distancePoints(pt1, pt3, inf), 10, 1e-6);
%!assert (distancePoints(pt1, [pt1; pt2; pt3]), [0 10 10*sqrt(2)], 1e-6);

%!test
%!  array1 = [pt1;pt2;pt3];
%!  array2 = [pt1;pt2;pt3;pt4];
%!  res = [0 10 10*sqrt(2) 10; 10 0 10 10*sqrt(2); 10*sqrt(2) 10 0 10];
%!  assert (distancePoints(array1, array2), res, 1e-6);
%!  assert (distancePoints(array2, array2, 'diag'), [0;0;0;0], 1e-6);

%!test
%!  array1 = [pt1;pt2;pt3];
%!  array2 = [pt2;pt3;pt1];
%!  assert (distancePoints(array1, array2, inf, 'diag'), [10;10;10], 1e-6);

%!shared pt1,pt2,pt3,pt4
%!  pt1 = [10 10 10];
%!  pt2 = [10 20 10];
%!  pt3 = [20 20 10];
%!  pt4 = [20 20 20];

%!assert (distancePoints(pt1, pt2), 10, 1e-6);
%!assert (distancePoints(pt2, pt3), 10, 1e-6);
%!assert (distancePoints(pt1, pt3), 10*sqrt(2), 1e-6);
%!assert (distancePoints(pt1, pt4), 10*sqrt(3), 1e-6);
%!assert (distancePoints(pt1, pt2, inf), 10, 1e-6);
%!assert (distancePoints(pt2, pt3, inf), 10, 1e-6);
%!assert (distancePoints(pt1, pt3, inf), 10, 1e-6);
%!assert (distancePoints(pt1, pt4, inf), 10, 1e-6);


%!shared pt1,pt2,pt3,pt4
%!  pt1 = [10 10 30];
%!  pt2 = [10 20 30];
%!  pt3 = [20 20 30];
%!  pt4 = [20 20 40];

%!assert (distancePoints(pt1, pt2, 1), 10, 1e-6);
%!assert (distancePoints(pt2, pt3, 1), 10, 1e-6);
%!assert (distancePoints(pt1, pt3, 1), 20, 1e-6);
%!assert (distancePoints(pt1, pt4, 1), 30, 1e-6);

%!test
%!  array1 = [pt1;pt2;pt3];
%!  array2 = [pt2;pt3;pt1];
%!  assert (distancePoints(array1, array2, 'diag'), [10;10;10*sqrt(2)], 1e-6);
%!  assert (distancePoints(array1, array2, 1, 'diag'), [10;10;20], 1e-6);

