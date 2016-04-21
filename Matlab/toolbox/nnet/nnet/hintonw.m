function hintonw(w,max_m,min_m)
%HINTONW Hinton graph of weight matrix.
%
%  Syntax
%
%    hintonw(W,maxw,minw)
%
%  Description
%  
%    HINTONW(W,MAXW,MINW) takes these inputs,
%      W    - SxR weight matrix
%      MAXW - Maximum weight, default = max(max(abs(W))).
%      MINW - Minimum weight, default = M1/100.
%    and displays a weight matrix represented as a grid of squares.
%  
%    Each square's AREA represents a weight's magnitude.
%    Each square's COLOR represents a weight's sign.
%    RED for negative weights, GREEN for positive.
%
%  Examples
%
%    W = rands(4,5);
%    hintonw(W)
%  
%  See also HINTONWB.

% Mark Beale, 1-31-92
% Revised 12-15-93, MB
% Revised 11-31-97, MB
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $  $Date: 2002/04/14 21:30:53 $

if nargin < 1,error('Not enough input arguments.');end
if nargin < 2, max_m = max(max(abs(w))); end
if nargin < 3, min_m = max_m / 100; end
if max_m == min_m, max_m = 1; min_m = 0; end

% DEFINE BOX EDGES
xn1 = [-1 -1 +1]*0.5;
xn2 = [+1 +1 -1]*0.5;
yn1 = [+1 -1 -1]*0.5;
yn2 = [-1 +1 +1]*0.5;

% DEFINE POSITIVE BOX
xn = [-1 -1 +1 +1 -1]*0.5;
yn = [-1 +1 +1 -1 -1]*0.5;

% DEFINE POSITIVE BOX
xp = [xn [-1 +1 +1 +0 +0]*0.5];
yp = [yn [+0 +0 +1 +1 -1]*0.5];

[S,R] = size(w);

cla reset
hold on
set(gca,'xlim',[0 R]+0.5);
set(gca,'ylim',[0 S]+0.5);
set(gca,'xlimmode','manual');
set(gca,'ylimmode','manual');
xticks = get(gca,'xtick');
set(gca,'xtick',xticks(find(xticks == floor(xticks))))
yticks = get(gca,'ytick');
set(gca,'ytick',yticks(find(yticks == floor(yticks))))
set(gca,'ydir','reverse');
if get(0,'screendepth') > 1
  set(gca,'color',[1 1 1]*.5);
  set(gcf,'color',[1 1 1]*.3);
end

for i=1:S
  for j=1:R
    m = sqrt((abs(w(i,j))-min_m)/max_m);
  m = min(m,max_m)*0.95;
  if real(m)
    if w(i,j) >= 0
      fill(xn*m+j,yn*m+i,[0 0.8 0])
        plot(xn1*m+j,yn1*m+i,'w',xn2*m+j,yn2*m+i,'k')
    elseif w(i,j) < 0
      fill(xn*m+j,yn*m+i,[0.8 0 0]);
        plot(xn1*m+j,yn1*m+i,'k',xn2*m+j,yn2*m+i,'w');
    end
  end
  end
end

plot([0 R R 0 0]+0.5,[0 0 S S 0]+0.5,'w');
xlabel('Input');
ylabel('Neuron');
grid on
