function hh = plotvec(x,c,m)
%PLOTVEC Plot vectors with different colors.
%
%  Syntax
%
%    plotvec(x,c,m)
%
%  Description
%
%    PLOTVEC(X,C,M) takes these inputs,
%      X - Matrix of (column) vectors.
%      C - Row vector of color coordinate.
%      M - Marker, default = '+'.
%    and plots each ith vector in X with a marker M, using the
%    ith value in C as the color coordinate.
%  
%    PLOTVEC(X) only takes a matrix X and plots each ith
%    vector in X with marker '+' using the index i as the
%    color coordinate.
%  
%  Examples
%
%    x = [0 1 0.5 0.7; -1 2 0.5 0.1];
%    c = [1 2 3 4];
%    plotvec(x,c)

% Mark Beale, 12-15-93
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.10 $  $Date: 2002/04/14 21:38:16 $

if nargin < 1,error('Not enough input arguments.'); end

% VECTORS
[xr,xc] = size(x);
if xr < 2
  x = [x; zeros(2-xr,xc)];
  xr = 2;
end

% COLORS
if nargin == 1
  c = [0:(xc-1)]/(xc-1);
end
map = colormap;
[mapr,mapc] = size(map);
mapr = mapr-1;
cc = map(round((c-min(c))*(mapr-1)/max(c))+1,:);

% MARKER
if nargin < 3
  m = '+';
end

hold on
H = zeros(1,xc);
minx = min(x,[],2);
maxx = max(x,[],2);
difx = maxx-minx;
minx = minx-difx*0.05;
maxx = maxx+difx*0.05;

% 2-D PLOTTING
if xr == 2
  for i=1:xc
    h = plot(x(1,i),x(2,i),m);
  set(h,'color',cc(i,:))
  H(i) = h;
  end
  
% 3-D PLOTTING
else
  for i=1:xc
    h = plot3(x(1,i),x(2,i),x(3,i),m);
  set(h,'color',cc(i,:))
  H(i) = h;
  end
end

set(gca,'box','on')
hold off
if nargout == 1, hh = H; end
set(gca,'color',[0 0 0]+0.5)
