function hh=feather(varargin)
%FEATHER Feather plot.
%   FEATHER(U,V) plots the velocity vectors with components U and V as
%   arrows emanating from equally spaced points along a horizontal axis.
%   FEATHER is useful for displaying direction and magnitude data that
%   is collected along a path.
%
%   FEATHER(Z) for complex Z is the same as FEATHER(REAL(Z),IMAG(Z)).
%   FEATHER(...,'LineSpec') uses the color and linestyle specification
%   from 'LineSpec' (see PLOT for possibilities).
%
%   FEATHER(AX,...) plots into AX instead of GCA.
%
%   H = FEATHER(...) returns a vector of line handles.
%
%   Example:
%      theta = (-90:10:90)*pi/180; r = 2*ones(size(theta));
%      [u,v] = pol2cart(theta,r);
%      feather(u,v), axis equal
%
%   See also COMPASS, ROSE, QUIVER.

%   Charles R. Denham, MathWorks 3-20-89
%   Modified 1-2-92, ls.
%   Modified 12-7-93 Mark W. Reichelt
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.13.4.3 $  $Date: 2004/04/10 23:31:47 $

% Parse possible Axes input
[cax,args,nargs] = axescheck(varargin{:});
error(nargchk(1,3,nargs));

if nargs > 0, x = args{1}; end
if nargs > 1, y = args{2}; end
if nargs > 2, s = args{3}; end

if isstr(x)
    error('First argument must be numeric.');
end
xx = [0 1 .8 1 .8]';
yy = [0 0 .08 0 -.08].';
arrow = xx + yy.*sqrt(-1);

if nargs == 2
   if isstr(y)
      s = y;
      y = imag(x); x = real(x);
   else
      s = '-';
   end
elseif nargs == 1
   s = '-';
   y = imag(x); x = real(x);
end
if isstr(x) | isstr(y)
    error('First 1 or 2 numeric arguments must be numeric.')
end
[st,co,mark,msg] = colstyle(s); error(msg)

x = x(:);
y = y(:);
if length(x) ~= length(y)
   error('X and Y must be the same length.');
end
[m,n] = size(x);

z = (x + y.*sqrt(-1)).';
a = arrow * z + ones(5,1)*(1:m);

% Plot the feather
cax = newplot(cax);
h = plot('v6',real(a), imag(a), [st co mark], [1 m], [0 0], [st co mark], ...
    'parent',cax);
if isempty(co),
  co = get(cax,'colororder');
  set(h,'color',co(1,:))
end

if nargout>0, hh = h; end
