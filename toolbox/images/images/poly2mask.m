function BW = poly2mask(x,y,M,N)
%POLY2MASK Convert region polygon to region mask.
%   BW = POLY2MASK(X,Y,M,N) computes a binary region-of-interest mask,
%   BW, from a region-of-interest polygon, represented by the vectors X
%   and Y.  The size of BW is M-by-N.  Pixels in BW that are inside
%   the polygon (X,Y) are 1; pixels outside the polygon are 0.  The class
%   of BW is logical.
%
%   POLY2MASK closes the polygon automatically if it isn't already
%   closed.
%
%   Example
%   -------
%       x = [63 186 54 190 63];
%       y = [60 60 209 204 60];
%       bw = poly2mask(x,y,256,256);
%       imshow(bw)
%       hold on
%       plot(x,y,'b','LineWidth',2)
%       hold off
%
%   Or using random points:
%
%       x = 256*rand(1,4);
%       y = 256*rand(1,4);
%       x(end+1) = x(1);
%       y(end+1) = y(1);
%       bw = poly2mask(x,y,256,256);
%       imshow(bw)
%       hold on
%       plot(x,y,'b','LineWidth',2)
%       hold off
%
%   See also ROIPOLY.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2003/08/23 05:53:11 $

checknargin(4,4,nargin,mfilename);
checkinput(x,{'double'},{'real','vector','finite'},mfilename,'X',1);
checkinput(y,{'double'},{'real','vector','finite'},mfilename,'Y',2);
checkinput(M,{'double'},{'real','integer','nonnegative'},mfilename,'M',3);
checkinput(N,{'double'},{'real','integer','nonnegative'},mfilename,'N',4);
if length(x) ~= length(y)
    error('Images:poly2mask:vectorSizeMismatch','%s',...
          'Function POLY2MASK expected its first two inputs, X and Y, to be vectors with the same length.');
end

if isempty(x)
    BW = false(M,N);
    return;
end

if (x(end) ~= x(1)) || (y(end) ~= y(1))
    x(end+1) = x(1);
    y(end+1) = y(1);
end

[xe,ye] = poly2edgelist(x,y);
BW = edgelist2mask(M,N,xe,ye);
