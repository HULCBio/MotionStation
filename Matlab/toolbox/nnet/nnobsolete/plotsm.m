function plotsm(w,m)
%PLOTSM Plot weights vectors of self-organizing map.
%  
%
%  This function is obselete.
%  Use PLOTSOM to plot a self-organizing map.

nntobsf('adaptwh','Use NNT2LIN and ADAPT to update and adapt your network.')

%  PLOTSM(W,M)
%    W - RxS matrix of weight vectors.
%    M - Neighborhood matrix.
%  Plots each neurons weight vector as a dot, and connects
%    neighboring neurons weight vectors with lines.
%  
%  EXAMPLES: W = rands(12,2);
%            M = nbman(3,4);
%            plotsm(W,M)
%  
%            [x,y] = meshgrid(1:5,1:6);
%            W = [x(:) y(:)];
%            M = nbman(5,6);
%            plotsm(W,M)
%  
%  See also NBGRID, NBMAN, NBDIST.

% Mark Beale, 12-15-93
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $  $Date: 2002/04/14 21:15:36 $

if nargin < 2, error('Not enough arguments.'),end

[S,R] = size(w);
if R < 2,error('W must have at least two columns.'),end

newplot;
set(gca,'box','on')
hold on
xlabel('W(i,1)');
ylabel('W(i,2)');
  
% CONNECT WEIGHT VECTORS
for i=1:(S-1)
  j=(i+1):S;
  ind = find(m(i,j) <= 1.1);
  j = j(ind);
  len = length(j);
  plot([ones(len,1)*w(i,1) w(j,1)]',[ones(len,1)*w(i,2)' w(j,2)]','b');
end

% PLOT WEIGHT VECTORS
plot(w(:,1),w(:,2),'.r','markersize',20)
hold off
drawnow
