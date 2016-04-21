function hintonwb(w,b,max_m,min_m)
%HINTONWB Hinton graph of weight matrix and bias vector.
%
%  Syntax
%
%    hintonwb(W,b,maxw,minw)
%
%  Description
%  
%    HINTONWB(W,B,M1,M2)
%      W    - SxR weight matrix
%      B    - Sx1 bias vector.
%      MAXW - Maximum weight, default = max(max(abs(W))).
%      MINW - Minimum weight, default = M1/100.
%    and displays a weight matrix and a bias vector represented
%    as a grid of squares.
%  
%    Each square's AREA represents a weight's magnitude.
%    Each square's COLOR represents a weight's sign.
%    RED for negative weights, GREEN for positive.
%
%  Examples
%
%    W = rands(4,5);
%    b = rands(4,1);
%    hintonwb(W,b)
%  
%  See also HINTONW.

% Mark Beale, 1-31-92
% Revised 12-15-93, MB
% Revised 11-31-97, MB
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $  $Date: 2002/04/14 21:38:08 $

if nargin < 2,error('Not enough input arguments.');end
if nargin < 3, max_m = max(max(abs(w))); end
if nargin < 4, min_m = max_m / 100; end

if 1
  pos = [0 0.8 0];
  neg = [0.8 0 0];
  bias = [0 0 0.87];
  edge = 'k';
else
  pos = [1 1 1]*0.8;
  neg = [1 1 1]*0.2;
  bias = [1 1 1]*0.5;
  edge = 'k';
end

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
set(gca,'xlim',[-1 R]+0.5);
set(gca,'ylim',[0 S]+0.5);
set(gca,'xlimmode','manual');
set(gca,'ylimmode','manual');
xticks = get(gca,'xtick');
set(gca,'xtick',xticks(find(xticks == floor(xticks))))
yticks = get(gca,'ytick');
set(gca,'ytick',yticks(find(yticks == floor(yticks))))
set(gca,'ydir','reverse');

fill([0 1 1 0 0]-0.5,[0 0 S S 0]+0.5,bias);

for i=1:S
  m = sqrt((abs(b(i))-min_m)/max_m);
  m = min(m,max_m)*0.95;
  if real(m)
    if b(i) >= 0
    fill(xn*m,yn*m+i,pos)
      plot(xn1*m,yn1*m+i,'w',xn2*m,yn2*m+i,'k')
  else
    fill(xn*m,yn*m+i,neg);
      plot(xn1*m,yn1*m+i,'k',xn2*m,yn2*m+i,'w');
  end
  end

  for j=1:R
    m = sqrt((abs(w(i,j))-min_m)/max_m);
  m = min(m,max_m)*0.95;
  if real(m)
    if w(i,j) >= 0
      fill(xn*m+j,yn*m+i,pos)
        plot(xn1*m+j,yn1*m+i,'w',xn2*m+j,yn2*m+i,'k')
    else
      fill(xn*m+j,yn*m+i,neg);
        plot(xn1*m+j,yn1*m+i,'k',xn2*m+j,yn2*m+i,'w');
    end
  end
  end
end

plot([0 R R 0 0]+0.5,[0 0 S S 0]+0.5,edge);
plot([0 1 1 0 0]-0.5,[0 0 S S 0]+0.5,edge);
xlabel('Input');
ylabel('Neuron');
grid on
