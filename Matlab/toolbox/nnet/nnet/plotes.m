function plotes(wv,bv,es,v)
%PLOTES Plot the error surface of a single input neuron.
%
%  Syntax
%
%    plotes(wv,bv,es,v)
%
%  Description
%  
%    PLOTES(WV,BV,ES,V) takes these arguments,
%      WV - 1xN row vector of values of W.
%      BV - 1xM row vector of values of B.
%      ES - MxN matrix of error vectors.
%      V  - View, default = [-37.5, 30].
%    and plots the error surface with a contour underneath.
%  
%    Calculate the error surface ES with ERRSURF.
%
%  Examples
%  
%    p = [3 2];
%    t = [0.4 0.8];
%    wv = -4:0.4:4; bv = wv;
%    ES = errsurf(p,t,wv,bv,'logsig');
%    plotes(wv,bv,ES,[60 30])
%           
%  See also ERRSURF.

% Mark Beale, 12-15-93
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.10 $

if nargin < 3, error('Not enough input arguments'),end

maxe = max(max(es));
mine = min(min(es));
drop = maxe-mine;
surfpos = mine - drop;
contpos = mine - drop*0.95;

newplot;

% LEFT 3-D PLOT
% =============

subplot(1,2,1);
[px,py] = gradient(es,wv,bv);
scolor = sqrt(px.^2+py.^2);

% SURFACE
sh = surf(wv,bv,es,scolor);
hold on
sh = surf(wv,bv,zeros(length(wv),length(bv))+surfpos,scolor);
set(sh,'edgecolor',[0.5 0.5 0.5])

% ERROR GOAL
if 0
minw = min(wv);
maxw = max(wv);
minb = min(bv);
maxb = max(bv);
z1 = plot3([minw maxw maxw minw minw],...
      [minb minb maxb maxb minb],[0 0 0 0 0],'w');
z2 = plot3([minw minw],[minb minb],[0 es(1,1)],'w');
z3 = plot3([maxw maxw],[minb minb],[0 es(1,length(wv))],'w');
z4 = plot3([maxw maxw],[maxb maxb],[0 es(length(bv),length(wv))],'w');
z5 = plot3([minw minw],[maxb maxb],[0 es(length(bv),1)],'w');
set([z1 z2 z3 z4 z5],'color',[1 1 0])
end

% TITLES
xlabel('Weight W');
ylabel('Bias B');
zlabel('Sum Squared Error')
title('Error Surface')

% WEIGHT & BIAS
set(gca,'xlim',[min(wv),max(wv)])
set(gca,'ylim',[min(bv),max(bv)])
zlim = get(gca,'zlim');

% VIEW
if nargin == 4, view(v), end
set(gca,'zlim',[surfpos maxe]);

% RIGHT 2-D PLOT
% ==============

subplot(1,2,2);

% SURFACE
sh = surf(wv,bv,es*0,scolor);
hold on
set(sh,'edgecolor',[0.5 0.5 0.5])

% CONTOUR
[cc,ch] = contour(wv,bv,es,12);
hold off
set(ch,'edgecolor',[1 1 1])

% TITLES
xlabel('Weight W');
ylabel('Bias B');
title('Error Contour')

% VIEW
view([0 90])
set(gca,'xlim',[min(wv) max(wv)])
set(gca,'ylim',[min(bv) max(bv)])

% COLOR
colormap(cool);

