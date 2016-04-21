function [in, on] = inpolygon(x,y,xv,yv)
%INPOLYGON True for points inside or on a polygonal region.
%   IN = INPOLYGON(X,Y,XV,YV) returns a matrix IN the size of X and Y.
%   IN(p,q) = 1 if the point (X(p,q), Y(p,q)) is either strictly inside or
%   on the edge of the polygonal region whose vertices are specified by the
%   vectors XV and YV; otherwise IN(p,q) = 0.
%
%   [IN ON] = INPOLYGON(X,Y,XV,YV) returns a second matrix, ON, which is 
%   the size of X and Y.  ON(p,q) = 1 if the point (X(p,q), Y(p,q)) is on 
%   the edge of the polygonal region; otherwise ON(p,q) = 0.
%
%   Example:
%       xv = rand(6,1); yv = rand(6,1);
%       xv = [xv ; xv(1)]; yv = [yv ; yv(1)];
%       x = rand(1000,1); y = rand(1000,1);
%       in = inpolygon(x,y,xv,yv);
%       plot(xv,yv,x(in),y(in),'.r',x(~in),y(~in),'.b')
%
%   Class support for inputs X,Y,XV,YV:
%      float: double, single

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.14.4.3 $  $Date: 2004/03/02 21:47:43 $

% If (xv,yv) is not closed, close it.
xv = xv(:);
yv = yv(:);
Nv = length(xv);
if ((xv(1) ~= xv(Nv)) || (yv(1) ~= yv(Nv)))
    xv = [xv ; xv(1)];
    yv = [yv ; yv(1)];
    Nv = Nv + 1;
end

inputSize = size(x);

x = x(:).';
y = y(:).';

mask = (x >= min(xv)) & (x <= max(xv)) & (y>=min(yv)) & (y<=max(yv));
if ~any(mask)
    in = false(inputSize);
    on = in;
    return
end
inbounds = find(mask);
x = x(mask);
y = y(mask);


% Choose block_length to keep memory usage of vec_inpolygon around
% 10 Megabytes.
block_length = 1e5;

M = numel(x);

if M*Nv < block_length
    if nargout > 1
        [in on] = vec_inpolygon(Nv,x,y,xv,yv);
    else
        in = vec_inpolygon(Nv,x,y,xv,yv);
    end
else
    % Process at most N elements at a time
    N = ceil(block_length/Nv);
    in = false(1,M);
    if nargout > 1
        on = false(1,M);
    end
    n1 = 0;  n2 = 0;
    while n2 < M,
        n1 = n2+1;
        n2 = n1+N;
        if n2 > M,
            n2 = M;
        end
        if nargout > 1
            [in(n1:n2) on(n1:n2)] = vec_inpolygon(Nv,x(n1:n2),y(n1:n2),xv,yv);
        else
            in(n1:n2) = vec_inpolygon(Nv,x(n1:n2),y(n1:n2),xv,yv);
        end
    end
end

if nargout > 1
    onmask = mask;
    onmask(inbounds(~on)) = 0;
    on = reshape(onmask, inputSize);
end

mask(inbounds(~in)) = 0;
% Reshape output matrix.
in = reshape(mask, inputSize);


%----------------------------------------------
function [in, on] = vec_inpolygon(Nv,x,y,xv,yv)
% vectorize the computation.

% Translate the vertices so that the test points are
% at the origin.

Np = length(x);
x = x(ones(Nv,1),:);
y = y(ones(Nv,1),:);
xv = xv(:,ones(1,Np)) - x;
yv = yv(:,ones(1,Np)) - y;

% Compute the quadrant number for the vertices relative
% to the test points.
posX = xv > 0;
posY = yv > 0;
negX = ~posX;
negY = ~posY;
quad = (negX & posY) + 2*(negX & negY) + ...
    3*(posX & negY);

% Compute the sign() of the cross product and dot product
% of adjacent vertices.
m = 1:Nv-1;
mp1 = 2:Nv;
signCrossProduct = sign(xv(m,:) .* yv(mp1,:) ...
    - xv(mp1,:) .* yv(m,:));
dotProduct = xv(m,:) .* xv(mp1,:) + yv(m,:) .* yv(mp1,:);

% Compute the vertex quadrant changes for each test point.
diffQuad = diff(quad);

% Fix up the quadrant differences.  Replace 3 by -1 and -3 by 1.
% Any quadrant difference with an absolute value of 2 should have
% the same sign as the cross product.
idx = (abs(diffQuad) == 3);
diffQuad(idx) = -diffQuad(idx)/3;
idx = (abs(diffQuad) == 2);
diffQuad(idx) = 2*signCrossProduct(idx);

% Find the inside points.
in = (sum(diffQuad) ~= 0);

% Find the points on the polygon.  If the cross product is 0 and
% the dot product is nonpositive anywhere, then the corresponding
% point must be on the contour.
on = any((signCrossProduct == 0) & (dotProduct <= 0));

in = in | on;
