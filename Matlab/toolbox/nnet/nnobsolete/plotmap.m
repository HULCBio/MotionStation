function plotmap(w,m,np)
%PLOTMAP Plot self-organizing map.
%  
%  This function is obselete.
%  Use PLOTSOM(W,M).

nntobsf('plotmap','Use PLOTSOM(W,M).')

%  
%  PLOTMAP(W,M)
%    W - RxS matrix of weight vectors.
%    M - Neighborhood matrix.
%  Plots each neurons weight vector as a dot, and connects
%    neighboring neurons weight vectors with lines.
%  
%  EXAMPLES: w = rands(12,2);
%            m = nbman(3,4);
%            plotmap(w,m)
%  
%            [x,y] = meshgrid(1:5,1:6);
%            w = [x(:) y(:)];
%            m = nbman(5,6);
%            plotmap(w,m)
%  
%  See also NBGRID, NBMAN, NBDIST.

% Mark Beale, 1-31-92
% Revised 12-15-93
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $  $Date: 2002/04/14 21:15:33 $

if nargin < 2, error('Not enough arguments.'),end

% =============== SUPPORT NNT 1.0 CALLING CONVENTION: PLOTMAP(W,F,NP)
if nargin == 3

  disp(' ')
  disp('*WARNING*: PLOTMAP(W,F,NP) is obsolete and will be eliminated')
  disp('in future versions. Use INITSM, SIMSM, TRAINSM, NBMAN')
  disp('and PLOTMAP(W,M) to create and plot self-organizing maps.')
  disp(' ')
  
  f = m;

  % PLOT UNIT CIRCLE
  holdst = ishold;
  plot(cos(0:.1:2*pi),sin(0:.1:2*pi),'--');
  axis('equal')
  hold on

  [wr,wc] = size(w);

  % CONNECT NEIGHBORS WITH LINES
  for i=1:wr
    plot(w(i,1),w(i,2),'.','markersize',20)
    n=feval(f,i,np);
    n = n(find(n > i));
    nl = length(n);
    for j=1:nl
      plot([w(i,1) w(n(j),1)],[w(i,2) w(n(j),2)]);
      end
    end

  % LABEL AXES
  xlabel('W(i,1)');
  ylabel('W(i,2)');
  if ~holdst, hold off, end
  
  return
end
% ===============

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
  plot([ones(len,1)*w(i,1) w(j,1)]',[ones(len,1)*w(i,2)' w(j,2)]');
end

% PLOT WEIGHT VECTORS
plot(w(:,1),w(:,2),'.r','markersize',20)
hold off
drawnow

