function [x,y] = cleandata(x,y)
%CLEANDATA  Filters X and Y data to remove unnecessary points.
%   [X,Y] = CLEANDATA(X,Y) removes identical adjacent points and points 
%   that lie between two points on the same line.

%  Written by:  A. Kim
%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.4.4.1 $    $Date: 2003/08/01 18:19:21 $

err = eps*1e5;

if ~isempty([x y])

% fix numerical
[xt,ixt,jxt] = uniqueerr(x,[],err);
[yt,iyt,jyt] = uniqueerr(y,[],err);
x = xt(jxt);  y = yt(jyt);

% remove any identical adjacent points
% ia = find(diff(x)==0 & diff(y)==0);
ia = find(abs(diff(x))<=err & abs(diff(y))<=err);
x(ia) = [];  y(ia) = [];

% remove any points that lie between two points on the same line
%   - calculate slopes
%   - if first point is such a point, shift until a valid point is reached
%   - remove unneccesary points
warnstate=warning;
warning off;
m = (y(2:end)-y(1:end-1))./(x(2:end)-x(1:end-1));
warning(warnstate);
% iinf = find(abs(m)>1/err & ~isinf(m));   % convert almost vertical lines
% m(iinf) = sign(y(iinf+1)-y(iinf))*inf;   % to vertical
% if m(1)==m(end)
if abs(m(1)-m(end))<=err | isnan(m(1)-m(end))
%    ishft = min(find(m~=m(1)));
   ishft = min(find(abs(m-m(1))>err));
   x = [x(ishft:end); x(2:ishft)];
   y = [y(ishft:end); y(2:ishft)];
   m = [m(ishft:end); m(1:ishft-1)];
end
% ib = find(diff(m)==0 | isnan(diff(m))) + 1;
ib = find(abs(diff(m))<=err | isnan(diff(m))) + 1;
x(ib) = [];  y(ib) = [];  m(ib) = [];

% round to apprpriate decimal place
% datamax = max([x; y]);
% dec = 0;  inum = 1;
% if datamax>10
%    while datamax/inum>10
%       dec = dec + 1;
%       inum = eval(['1e' num2str(dec)]);
%    end
% end
% iround = eval(['1e' num2str(dec-13)]);
% x = round(x/iround)*iround;
% y = round(y/iround)*iround;
% x = round(x/1e-9)*1e-9;
% y = round(y/1e-9)*1e-9;

% close open polygons

if isempty(x); return; end

if x(1) ~= x(end) | y(1) ~= y(end)
   x(end+1)=x(1);
   y(end+1)=y(1);
end

end
