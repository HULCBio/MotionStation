function m=nbdist(d1,d2,d3,d4,d5)
%NBDIST Neighborhood matrix using vector distance.
%  
%  This function is obselete.
%  Use NEWSOM to create a self-organizing map.

nntobsf('nbdist','Use NEWSOM to create a self-organizing map.')

%  NBDIST(D1,D2,...,DN)
%    Di - Size of layers ith dimension.
%  Returns neighborhood matrix M for (D1*D2*...*DN)
%    neurons arranged in an N dimensional grid, where
%    each element (i,j) is equal to the vector distance
%    between neurons i and j.
%  
%  The N-neighborhood matrix can be found by: (M <= N).
%  
%  EXAMPLE: M = nbdist(2,3)
%  
%  See also NBGRID, NBMAN

% Mark Beale, 1-31-92
% Revised 12-15-93, MB
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $  $Date: 2002/04/14 21:14:29 $

if nargin < 1, error('Not enough arguments.'); end
if nargin == 1, n = 1; end

% COORDINATES
coord = (1:d1)';
S = d1;
for i=2:nargin
  di = eval(sprintf('d%g',i));
  [x,y] = meshgrid(1:S,1:di);
  S = S*di;
  coord = [reshape(coord(x),S,1) reshape(y,S,1)];
end

% DISTANCES
m = zeros(S,S);
for i=1:(S-1)
  j=(i+1):S;
  distij = sqrt(nnsumr((ones(length(j),1)*coord(i,:)-coord(j,:)) .^ 2));
  m(i,j) = distij';
  m(j,i) = distij;
end
