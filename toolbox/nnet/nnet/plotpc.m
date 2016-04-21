function h = plotpc(w,b,hh)
%PLOTPC Plot a classification line on a perceptron vector plot.
%
%  Syntax
%
%    plotpc(W,b)
%    plotpc(W,b,h)
%
%  Description
%
%    PLOTPC(W,B) takes these inputs,
%      W - SxR weight matrix (R must be 3 or less).
%      B - Sx1 bias vector.
%    and returns a handle to a plotted classification line.
%  
%    PLOTPC(W,B,H) takes these inputs,
%      H - Handle to last plotted line.
%    and deletes the last line before plotting the new one.
%  
%    This function does not change the current axis and is intended
%    to be called after PLOTPV.
%
%  Example
%
%    The code below defines and plots the inputs and targets for a
%    perceptron:
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
%  See also PLOTPV.

% Mark Beale, 1-31-92
% Revised 12-15-93, MB
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.12 $  $Date: 2002/04/14 21:31:32 $

% ERROR CHECKING
% ==============

if nargin < 2, error('Not enough arguments.'), end

[wr,wc] = size(w);
[br,bc] = size(b);

if length(w) > 3,error('Weight matrix must not be larger than 3x3.'),end
if br ~= wr, error('Weight matrix & bias vector must have same # of rows.'),end

% DEFAULTS
% ========

if max(wr,wc) <= 2
  plotdim = 2;
else
  plotdim = 3;
end

w = [w zeros(wr,3-wc)];
  
if nargin == 3
  delete(hh);
end

% PLOTTING
% ========

xlim = get(gca,'xlim');
ylim = get(gca,'ylim');
zlim = get(gca,'zlim');
view = get(gca,'view');

if nargout == 1, h = zeros(1,wr); end
co = 'mbrg';

hold on
for i = 1:wr
  c = [co(rem(i,4)+1) '-'];

  % 2-D PLOT

  if plotdim == 2
    if w(i,2) ~= 0
      x = xlim;
      y = (-w(i,1)*x-b(i))/w(i,2);
  elseif w(i,1) ~= 0
      y = ylim;
      x = (-w(i,2)*y-b(i))/w(i,1);
  else
    x = NaN;
    y = NaN;
  end
    hh = plot(x,y,c);
  
  % 3-D PLOT
  
  else
    x = [0:0.05:1]*(xlim(2)-xlim(1))+xlim(1);
    y = [0:0.05:1]*(ylim(2)-ylim(1))+ylim(1);
    [X,Y] = meshgrid(x,y);
    Z = -(X*w(i,1)+Y*w(i,2)+b(i)) / w(i,3);
    ind = find(Z < zlim(1) | Z > zlim(2));
    Z(ind) = NaN+Z(ind);
    hh = surf(x,y,Z);
  set(hh,'edgecolor',[1 1 1]*0.5)
  end

  if nargout == 1
    h(i) = hh;
  end
end
set(gca,'xlim',xlim);
set(gca,'ylim',ylim);
set(gca,'zlim',zlim);
set(gca,'view',view);
hold off
