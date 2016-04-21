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
## @deftypefn {Function File} {@var{dist} = } minDistancePoints (@var{pts})
## @deftypefnx {Function File} {@var{dist} = } minDistancePoints (@var{pts1},@var{pts2})
## @deftypefnx {Function File} {@var{dist} = } minDistancePoints (@dots{},@var{norm})
## @deftypefnx {Function File} {[@var{dist} @var{i} @var{j}] = } minDistancePoints (@var{pts1}, @var{pts2}, @dots{})
## @deftypefnx {Function File} {[@var{dist} @var{j}] = } minDistancePoints (@var{pts1}, @var{pts2}, @dots{})
## Minimal distance between several points.
##
##   Returns the minimum distance between all couple of points in @var{pts}. @var{pts} is
##   an array of [NxND] values, N being the number of points and ND the
##   dimension of the points.
##
##   Computes for each point in @var{pts1} the minimal distance to every point of
##   @var{pts2}. @var{pts1} and @var{pts2} are [NxD] arrays, where N is the number of points,
##   and D is the dimension. Dimension must be the same for both arrays, but
##   number of points can be different.
##   The result is an array the same length as @var{pts1}.
##
##   When @var{norm} is provided, it uses a user-specified norm. @var{norm}=2 means euclidean norm (the default), 
##   @var{norm}=1 is the Manhattan (or "taxi-driver") distance.
##   Increasing @var{norm} growing up reduces the minimal distance, with a limit
##   to the biggest coordinate difference among dimensions. 
##   
##
##   Returns indices @var{i} and @var{j} of the 2 points which are the closest. @var{dist}
##   verifies relation:
##   @var{dist} = distancePoints(@var{pts}(@var{i},:), @var{pts}(@var{j},:));
##
##   If only 2 output arguments are given, it returns the indices of points which are the closest. @var{j} has the
##   same size as @var{dist}. for each I It verifies the relation : 
##   @var{dist}(I) = distancePoints(@var{pts1}(I,:), @var{pts2}(@var{J},:));
##
##
##   Examples:
##
## @example
##   # minimal distance between random planar points
##       points = rand(20,2)*100;
##       minDist = minDistancePoints(points);
##
##   # minimal distance between random space points
##       points = rand(30,3)*100;
##       [minDist ind1 ind2] = minDistancePoints(points);
##       minDist
##       distancePoints(points(ind1, :), points(ind2, :))
##   # results should be the same
##
##   # minimal distance between 2 sets of points
##       points1 = rand(30,2)*100;
##       points2 = rand(30,2)*100;
##       [minDists inds] = minDistancePoints(points1, points2);
##       minDists(10)
##       distancePoints(points1(10, :), points2(inds(10), :))
##   # results should be the same
## @end example
##
##   @seealso{points2d, distancePoints}
## @end deftypefn

function varargout = minDistancePoints(p1, varargin)

  ## Initialisations

  # default norm (euclidean)
  n = 2;

  # flag for processing of all points
  allPoints = false;

  # process input variables
  if isempty(varargin)
      # specify only one array of points, not the norm
      p2 = p1;
      
  elseif length(varargin)==1
      var = varargin{1};
      if length(var)>1       
          # specify two arrays of points
          p2  = var;
          allPoints = true;
      else
          # specify array of points and the norm
          n   = var;
          p2  = p1;
      end
      
  else
      # specify two array of points and the norm
      p2  = varargin{1};
      n   = varargin{2};
      allPoints = true;
  end


  # number of points in each array
  n1  = size(p1, 1);
  n2  = size(p2, 1);

  # dimension of points
  d   = size(p1, 2);


  ## Computation of distances

  # allocate memory
  dist = zeros(n1, n2);

  # different behaviour depending on the norm used
  if n==2
      # Compute euclidian distance. this is the default case
      # Compute difference of coordinate for each pair of point ([n1*n2] array)
      # and for each dimension. -> dist is a [n1*n2] array.
      # in 2D: dist = dx.*dx + dy.*dy;
      for i=1:d
          dist = dist + (repmat(p1(:,i), [1 n2])-repmat(p2(:,i)', [n1 1])).^2;
      end

      # compute minimal distance:
      if ~allPoints
          # either on all couple of points
          mat = repmat((1:n1)', [1 n1]);
          ind = mat < mat';
          [minSqDist ind] = min(dist(ind));
      else
          # or for each point of P1
          [minSqDist ind] = min(dist, [], 2);
      end
      
      # convert squared distance to distance
      minDist = sqrt(minSqDist);
  elseif n==inf
      # infinite norm corresponds to maximum absolute value of differences
      # in 2D: dist = max(abs(dx) + max(abs(dy));
      for i=1:d
          dist = max(dist, abs(p1(:,i)-p2(:,i)));
      end
  else
      # compute distance using the specified norm.
      # in 2D: dist = power(abs(dx), n) + power(abs(dy), n);
      for i=1:d
          dist = dist + power((abs(repmat(p1(:,i), [1 n2])-repmat(p2(:,i)', [n1 1]))), n);
      end

      # compute minimal distance
      if ~allPoints
          # either on all couple of points
          mat = repmat((1:n1)', [1 n1]);
          ind = mat < mat';
          [minSqDist ind] = min(dist(ind));
      else
          # or for each point of P1
          [minSqDist ind] = min(dist, [], 2);
      end

      # convert squared distance to distance
      minDist = power(minSqDist, 1/n);
  end



  if ~allPoints
      # convert index in array to row ad column subindices.
      # This uses the fact that index are sorted in a triangular matrix,
      # with the last index of each column being a so-called triangular
      # number
      ind2 = ceil((-1+sqrt(8*ind+1))/2);
      ind1 = ind - ind2*(ind2-1)/2;
      ind2 = ind2 + 1;
  end


  ## format output parameters

  # format output depending on number of asked parameters
  if nargout<=1
      varargout{1} = minDist;
  elseif nargout==2
      # If two arrays are asked, 'ind' is an array of indices, one for each
      # point in var{pts}1, corresponding to the result in minDist
      varargout{1} = minDist;
      varargout{2} = ind;
  elseif nargout==3
      # If only one array is asked, minDist is a scalar, ind1 and ind2 are 2
      # indices corresponding to the closest points.
      varargout{1} = minDist;
      varargout{2} = ind1;
      varargout{3} = ind2;
  end

endfunction

%!test
%!  pts = [50 10;40 60;30 30;20 0;10 60;10 30;0 10];
%!  assert (minDistancePoints(pts), 20);

%!test
%!  pts = [10 10;25 5;20 20;30 20;10 30];
%!  [dist ind1 ind2] = minDistancePoints(pts);
%!  assert (10, dist, 1e-6);
%!  assert (3, ind1, 1e-6);
%!  assert (4, ind2, 1e-6);

%!test
%!  pts = [0 80;10 60;20 40;30 20;40 0;0 0;100 0;0 100;0 -10;-10 -20];
%!  assert (minDistancePoints([40 50], pts), 10*sqrt(5), 1e-6);
%!  assert (minDistancePoints([25 30], pts), 5*sqrt(5), 1e-6);
%!  assert (minDistancePoints([30 40], pts), 10, 1e-6);
%!  assert (minDistancePoints([20 40], pts), 0, 1e-6);

%!test
%!  pts1 = [40 50;25 30;40 20];
%!  pts2 = [0 80;10 60;20 40;30 20;40 0;0 0;100 0;0 100;0 -10;-10 -20];
%!  res = [10*sqrt(5);5*sqrt(5);10];
%!  assert (minDistancePoints(pts1, pts2), res, 1e-6);

%!test
%!  pts = [50 10;40 60;40 30;20 0;10 60;10 30;0 10];
%!  assert (minDistancePoints(pts, 1), 30, 1e-6);
%!  assert (minDistancePoints(pts, 100), 20, 1e-6);

%!test
%!  pts = [0 80;10 60;20 40;30 20;40 0;0 0;100 0;0 100;0 -10;-10 -20];
%!  assert (minDistancePoints([40 50], pts, 2), 10*sqrt(5), 1e-6);
%!  assert (minDistancePoints([25 30], pts, 2), 5*sqrt(5), 1e-6);
%!  assert (minDistancePoints([30 40], pts, 2), 10, 1e-6);
%!  assert (minDistancePoints([20 40], pts, 2), 0, 1e-6);
%!  assert (minDistancePoints([40 50], pts, 1), 30, 1e-6);
%!  assert (minDistancePoints([25 30], pts, 1), 15, 1e-6);
%!  assert (minDistancePoints([30 40], pts, 1), 10, 1e-6);
%!  assert (minDistancePoints([20 40], pts, 1), 0, 1e-6);

%!test
%!  pts1 = [40 50;25 30;40 20];
%!  pts2 = [0 80;10 60;20 40;30 20;40 0;0 0;100 0;0 100;0 -10;-10 -20];
%!  res1 = [10*sqrt(5);5*sqrt(5);10];
%!  assert (minDistancePoints(pts1, pts2, 2), res1, 1e-6);
%!  res2 = [30;15;10];
%!  assert (minDistancePoints(pts1, pts2, 1), res2);

%!test
%!  pts1    = [40 50;20 30;40 20];
%!  pts2    = [0 80;10 60;20 40;30 20;40 0;0 0;100 0;0 100;0 -10;-10 -20];
%!  dists0  = [10*sqrt(5);10;10];
%!  inds1   = [3;3;4];
%!  [minDists inds] = minDistancePoints(pts1, pts2);
%!  assert (dists0, minDists);
%!  assert (inds1, inds);
