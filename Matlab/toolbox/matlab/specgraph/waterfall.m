function h = waterfall(varargin)
%WATERFALL Waterfall plot.
%   WATERFALL(...) is the same as MESH(...) except that the column lines of
%   the mesh are not drawn - thus producing a "waterfall" plot.  For
%   column-oriented data analysis, use WATERFALL(Z') or 
%   WATERFALL(X',Y',Z').
%
%   See also MESH.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.9.4.1 $  $Date: 2002/10/24 02:14:34 $

[cax,args,nargs] = axescheck(varargin{:});
error(nargchk(1,4,nargs));

if nargs == 1
    z = args{1};
    c = z;
    x = 1:size(z,2);
    y = 1:size(z,1);
elseif nargs == 2
    y = args{2};
    z = args{1};
    c = y;
    x = 1:size(z,2);
    y = 1:size(z,1);
elseif nargs == 3
    [x, y, z] = deal(args{1:3});
    c = z;
elseif nargs == 4
    [x, y, z, c] = deal(args{1:4});
end
if min(size(x)) == 1 | min(size(y)) == 1
    [x,y]=meshgrid(x,y);
end

% Create the plot
cax = newplot(cax);

% Add 2 data points to the beginning and three data points at the end
% of each row for a patch.  Two of the points on each side are used
% to make sure the curtain is a constant color under 'interp' or
% 'flat' edge color.  The final point on the right is used to
% make bottom edge invisible.
x = [x(:,[1 1]) x x(:,size(x,2)*[1 1 1])];
y = [y(:,[1 1]) y y(:,size(y,2)*[1 1 1])];
c0 = (max(max(c))+min(min(c)))/2;
z0 = min(min(z));
if z0==max(max(z)), % Special case for a constant surface
  if z0==0, z0 = -1; else, z0 = z0 - abs(z0)/2; end
end

z = [z0*ones(size(x,1),1) z(:,1) z z(:,size(z,2)) z0*ones(size(x,1),2) ];
c = [c0*ones(size(c,1),2)  c c0*ones(size(c,1),2) repmat(NaN,size(x,1),1)];
fc = get(cax,'color');
if strcmp(fc,'none'), fc = get(get(cax,'parent'),'color'); end
hp = patch(x',y',z',c','facecolor',fc,'edgecolor','flat','parent',cax);
view(cax,3), grid(cax,'on')

% return handles, if requested
if nargout > 0
    h = hp;
end

