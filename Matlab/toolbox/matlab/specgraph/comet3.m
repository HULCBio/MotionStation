function comet3(varargin)
%COMET3 3-D Comet-like trajectories.
%   COMET3(Z) displays an animated three dimensional plot of the vector Z.
%   COMET3(X,Y,Z) displays an animated comet plot of the curve through the
%   points [X(i),Y(i),Z(i)].
%   COMET3(X,Y,Z,p) uses a comet of length p*length(Z). Default is p = 0.1.
%
%   COMET3(AX,...) plots into AX instead of GCA.
%
%   Example:
%       t = -pi:pi/500:pi;
%       comet3(sin(5*t),cos(3*t),t)
%
%   See also COMET.

%   Charles R. Denham, MathWorks, 1989.
%   Revised 2-9-92, LS and DTP; 8-18-92, 11-30-92 CBM.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.11.4.1 $  $Date: 2002/09/26 01:55:14 $

% Parse possible Axes input
[ax,args,nargs] = axescheck(varargin{:});

error(nargchk(1,4,nargs));

% Parse the rest of the inputs
if nargs < 2, x = args{1}; end
if nargs == 2, y = args{2}; end
if nargs < 3, z = x; x = 1:length(z); y = 1:length(z); end
if nargs == 3, [x,y,z] = deal(args{:}); end
if nargs < 4, p = 0.10; end
if nargs == 4, [x,y,z,p] = deal(args{:}); end

ax = newplot(ax);
if ~ishold(ax),
  axis(ax,[min(x(isfinite(x))) max(x(isfinite(x))) min(y(isfinite(y)))  ...
        max(y(isfinite(y))) min(z(isfinite(z))) max(z(isfinite(z)))])
end

co = get(ax,'colororder');

if size(co,1)>=3,
  % Choose first three colors for head, body, and tail
  head = line('parent',ax,'color',co(1,:),'marker','o','erase','xor', ...
              'xdata',x(1),'ydata',y(1),'zdata',z(1));
  body = line('parent',ax,'color',co(2,:),'linestyle','-','erase','none', ...
              'xdata',[],'ydata',[],'zdata',[]);
  tail = line('parent',ax,'color',co(3,:),'linestyle','-','erase','none', ...
              'xdata',[],'ydata',[],'zdata',[]);
else
  % Choose first three colors for head, body, and tail
  head = line('parent',ax,'color',co(1,:),'marker','o','erase','xor', ...
              'xdata',x(1),'ydata',y(1),'zdata',z(1));
  body = line('parent',ax,'color',co(1,:),'linestyle','--','erase','none', ...
              'xdata',[],'ydata',[],'zdata',[]);
  tail = line('parent',ax,'color',co(1,:),'linestyle','-','erase','none', ...
              'xdata',[],'ydata',[],'zdata',[]);
end

m = length(z);
k = round(p*m);

% Grow the body
for i = 2:k+1
   j = i-1:i;
   set(head,'xdata',x(i),'ydata',y(i),'zdata',z(i))
   set(body,'xdata',x(j),'ydata',y(j),'zdata',z(j))
   drawnow
end

% Primary loop
m = length(x);
for i = k+2:m
   j = i-1:i;
   set(head,'xdata',x(i),'ydata',y(i),'zdata',z(i))
   set(body,'xdata',x(j),'ydata',y(j),'zdata',z(j))
   set(tail,'xdata',x(j-k),'ydata',y(j-k),'zdata',z(j-k))
   drawnow
end

% Clean up the tail
for i = m+1:m+k
   j = i-1:i;
   set(tail,'xdata',x(j-k),'ydata',y(j-k),'zdata',z(j-k))
   drawnow
end
