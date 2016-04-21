function plotpv(p,t,v)
%PLOTPV Plot perceptron input/target vectors.
%
%  Syntax
%
%    plotpv(p,t)
%    plotpv(p,t,v)
%
%  Description
%  
%    PLOTPV(P,T) take these inputs,
%      P - RxQ matrix of input vectors (R must be 3 or less).
%      T - SxQ matrix of binary target vectors (S must be 3 or less).
%    and plots column vectors in P with markers based on T.
%  
%    PLOTPV(P,T,V) takes an additional input,
%      V - Graph limits = [x_min x_max y_min y_max]
%    and plots the column vectors with limits set by V.
%
%  Example
%
%    The code below defines and plots the inputs and targets
%    for a perceptron:
%
%      p = [0 0 1 1; 0 1 0 1];
%      t = [0 0 0 1];
%      plotpv(p,t)
%
%    The following code creates a perceptron with inputs ranging
%    over the values in P, assigns values to its weights
%    and biases, and plots the resulting classification line.
%
%      net = newp(minmax(p),1);
%      net.iw{1,1} = [-1.2 -0.5];
%      net.b{1} = 1;
%      plotpc(net.iw{1,1},net.b{1})
%
%  See also PLOTPC.

% Mark Beale, 1-31-92
% Revised 12-15-93, MB
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.12 $  $Date: 2002/04/14 21:34:26 $

% ERROR CHECKING
% ==============

if nargin < 2, error('Not enough arguments.'),end

[pr,pc] = size(p);
[tr,tc] = size(t);

if (pr > 3), error('P must 1, 2, or 3 rows.'), end
if tr > 3, error('T must have 1, 2, or 3 rows.'), end

% DEFAULTS
% ========

if max(pr,tr) <= 2
  plotdim = 2;
else
  plotdim = 3;
end

p = [p; zeros(3-pr,pc)];
t = [t; zeros(3-tr,tc)];

if nargin == 2
  minx = min(p(1,:));
  maxx = max(p(1,:));
  miny = min(p(2,:));
  maxy = max(p(2,:));
  edgx = (maxx-minx)*0.4+0.1;
  edgy = (maxy-miny)*0.4+0.1;
  minz = min(p(3,:));
  maxz = max(p(3,:));
  edgz = (maxz-minz)*0.4;
  if plotdim == 2
    v = [minx-edgx maxx+edgx miny-edgy maxy+edgy];
  else
    v = [minx-edgx maxx+edgx  miny-edgy maxy+edgy minz-edgz maxz+edgz];
  end
end

% MARKERS
% =======

marker = ['ob';'or';'*b';'*r';'+b';'+r';'xb';'xr'];

% PLOTTING
% ========

for i=1:pc
  m = marker([4 2 1]*t(:,i)+1,:);
  plot3(p(1,i),p(2,i),p(3,i),m)
  hold on
end

% PLOT SET UP
% ===========

set(gca,'box','on')
title('Vectors to be Classified')
xlabel('P(1)');
ylabel('P(2)');

if plotdim <= 2
  view(2)
else
  view(3)
  zlabel('P(3)')
end
axis(v)
hold off

