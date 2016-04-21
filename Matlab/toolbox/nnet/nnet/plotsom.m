function plotsom(w,d,nd)
%PLOTSOM Plot self-organizing map.
%
%  Syntax
%
%    plotsom(pos)
%    plotsom(W,d,nd)
%
%  Description
%
%    PLOTSOM(POS) takes one argument,
%      POS - NxS matrix of S N-dimension neural positions.
%    and plots the neuron positions with red dots, linking
%    the neurons within a Euclidean distance of 1.
%
%    PLOTSOM(W,D,ND) takes three arguments,
%      W  - SxR weight matrix.
%      D  - SxS distance matrix.
%      ND - Neighborhood distance, default = 1.
%    and plots the neuron's weight vectors with connections
%    between weight vectors whose neurons are within a
%    distance of 1.
%
%  Examples
%
%    Here are some neat plots of various layer topologies:
%
%      pos = hextop(5,6); plotsom(pos)
%      pos = gridtop(4,5); plotsom(pos)
%      pos = randtop(18,12); plotsom(pos)
%      pos = gridtop(4,5,2); plotsom(pos)
%      pos = hextop(4,4,3); plotsom(pos)
%
%    See NEWSOM for an example of plotting a layer's
%    weight vectors with the input vectors they map.
%
%  See also NEWSOM, LEARNSOM, INITSOM.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.8 $

% Arguments
if nargin < 1, error('Not enough arguments.'),end
if nargin < 2
  d = dist(w);
  w = w';
  t = 'Neuron Positions';
  var = 'position(%g,i)';
else
  t = 'Weight Vectors';
  var = 'W(i,%g)';
end
if nargin < 3
  nd = 1;
end

% Check Dimensions
[S,R] = size(w);
if R < 3
  w = [w zeros(S,3-R)];
elseif R > 3
  disp('Warning - PLOTSOM only shows first three dimensions.');
  w = w(:,1:3);
end 

% Line coordinates
[I,J] = meshgrid(1:S,1:S);
[i,j] = find((d <= (nd+1e-10)) & (I<J));
keep = find((w(i,1) ~= w(j,1)) | (w(i,2) ~= w(j,2)) | (w(i,3) ~= w(j,3)));
i = i(keep);
j = j(keep);
numLines = length(i);
x = [w(i,1)'; w(j,1)'; zeros(1,numLines)+NaN];
y = [w(i,2)'; w(j,2)'; zeros(1,numLines)+NaN];
z = [w(i,3)'; w(j,3)'; zeros(1,numLines)+NaN];
x = reshape(x,1,3*numLines);
y = reshape(y,1,3*numLines);
z = reshape(z,1,3*numLines);

% Plot
plot3(x,y,z,'b',w(:,1),w(:,2),w(:,3),'.r','markersize',20)
set(gca,'box','on')
xlabel(sprintf(var,1));
ylabel(sprintf(var,2));
zlabel(sprintf(var,3));
title(t)
view(2 + (R>=3));
if numLines
  axis('equal')
end
