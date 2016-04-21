function [vxx,vy] = voronoi(varargin)
%VORONOI Voronoi diagram.
%   VORONOI(X,Y) plots the Voronoi diagram for the points X,Y. Cells that
%   contain a point at infinity are unbounded and are not plotted.
%
%   VORONOI(X,Y,TRI) uses the triangulation TRI instead of
%   computing it via DELAUNAY. 
%
%   VORONOI(X,Y,OPTIONS) specifies a cell array of strings to be used as
%   options in Qhull via DELAUNAY.
%   If OPTIONS is [], the default DELAUNAY options will be used.
%   If OPTIONS is {''}, no options will be used, not even the default.
%
%   VORONOI(AX,...) plots into AX instead of GCA.
%
%   H = VORONOI(...,'LineSpec') plots the diagram with color and linestyle
%   specified and returns handles to the line objects created in H.
%
%   [VX,VY] = VORONOI(...) returns the vertices of the Voronoi
%   edges in VX and VY so that plot(VX,VY,'-',X,Y,'.') creates the
%   Voronoi diagram.
%
%   For the topology of the voronoi diagram, i.e. the vertices for
%   each voronoi cell, use the function VORONOIN as follows: 
%
%         [V,C] = VORONOIN([X(:) Y(:)])
%
%   See also VORONOIN, DELAUNAY, CONVHULL.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.15.4.5 $  $Date: 2004/04/10 23:32:27 $

[cax,args,nargs] = axescheck(varargin{:});
error(nargchk(2,4,nargs));

x = args{1};
y = args{2};

if nargs == 2,
    tri = delaunay(x,y);
    ls = '';
else 
    arg3 = args{3};
    if nargs == 3,
        ls = '';
    else
        arg4 = args{4};
        ls = arg4;
    end 
    if isempty(arg3),
        tri = delaunay(x,y);
    elseif isstr(arg3),
        tri = delaunay(x,y); 
        ls = arg3;
    elseif iscellstr(arg3),
        tri = delaunay(x,y,arg3);
    else
        tri = arg3;
    end
end

% re-orient the triangles so that they are all clockwise
xt = x(tri); yt=y(tri);
ot = xt(:,1).*(yt(:,2)-yt(:,3)) + ...
    xt(:,2).*(yt(:,3)-yt(:,1)) + ...
    xt(:,3).*(yt(:,1)-yt(:,2));
bt = find(ot<0);
tri(bt,[1 2]) = tri(bt,[2 1]);

n = prod(size(x));
ntri = size(tri,1);
t = (1:ntri)';
T = sparse(tri,tri(:,[3 1 2]),t(:,ones(1,3)),n,n); % Triangle edge if T(i,j) 
E = (T & T').*T; % Voronoi edge if E(i,j) 

[i,j,v] = find(triu(E));
[i,j,vv] = find(triu(E'));
c1 = circle(tri(v,:),x,y);
c2 = circle(tri(vv,:),x,y);

vx = [c1(:,1) c2(:,1)].';
vy = [c1(:,2) c2(:,2)].';

if nargout<2
    if isempty(cax)
        cax = gca;
    end
    if isempty(ls),
        co = get(ancestor(cax,'figure'),'defaultaxescolororder');
        h = plot(vx,vy,'-',x,y,'.','color',co(1,:),'parent',cax);
    else
        [l,c,m,msg] = colstyle(ls); error(msg)
        if isempty(m), m = '.'; end
        h = plot(vx,vy,ls,x,y,[c m],'parent',cax);
    end
    if ~ishold(cax),
        view(cax,2), axis(cax,[min(x(:)) max(x(:)) min(y(:)) max(y(:))])
    end
    if nargout==1, vxx = h; end
else
    vxx = vx;
end

function c = circle(tri,x,y)
%CIRCLE Return center and radius for circumcircles
%   C = CIRCLE(TRI,X,Y) returns a N-by-3 vector containing [xcenter(:)
%   ycenter(:) radius(:)] for each triangle in TRI.

% Reference: Watson, p32.
x = x(:); y = y(:);

x1 = x(tri(:,1)); x2 = x(tri(:,2)); x3 = x(tri(:,3));
y1 = y(tri(:,1)); y2 = y(tri(:,2)); y3 = y(tri(:,3));

% Set equation for center of each circumcircle: 
%    [a11 a12;a21 a22]*[x;y] = [b1;b2] * 0.5;

a11 = x2-x1; a12 = y2-y1;
a21 = x3-x1; a22 = y3-y1;

b1 = a11 .* (x2+x1) + a12 .* (y2+y1);
b2 = a21 .* (x3+x1) + a22 .* (y3+y1);

% Solve the 2-by-2 equation explicitly
idet = a11.*a22 - a21.*a12;

% Add small random displacement to points that are either the same
% or on a line.
d = find(idet == 0);
if ~isempty(d), % Add small random displacement to points
    delta = sqrt(eps);
    x1(d) = x1(d) + delta*(rand(size(d))-0.5);
    x2(d) = x2(d) + delta*(rand(size(d))-0.5);
    x3(d) = x3(d) + delta*(rand(size(d))-0.5);
    y1(d) = y1(d) + delta*(rand(size(d))-0.5);
    y2(d) = y2(d) + delta*(rand(size(d))-0.5);
    y3(d) = y3(d) + delta*(rand(size(d))-0.5);
    a11 = x2-x1; a12 = y2-y1;
    a21 = x3-x1; a22 = y3-y1;
    b1 = a11 .* (x2+x1) + a12 .* (y2+y1);
    b2 = a21 .* (x3+x1) + a22 .* (y3+y1);
    idet = a11.*a22 - a21.*a12;
end

idet = 0.5 ./ idet;

xcenter = ( a22.*b1 - a12.*b2) .* idet;
ycenter = (-a21.*b1 + a11.*b2) .* idet;

radius = (x1-xcenter).^2 + (y1-ycenter).^2;

c = [xcenter ycenter radius];


