function varargout = map2pix(R,varargin)
%MAP2PIX Convert map coordinates to pixel coordinates.
%
%   [ROW,COL] = MAP2PIX(R,X,Y) calculates pixel coordinates ROW, COL from
%   map coordinates X, Y.  R is a 3-by-2 referencing matrix defining a
%   2-dimensional affine transformation from pixel coordinates to map
%   coordinates.  X and Y are vectors or arrays of matching size.  The
%   outputs ROW and COL have the same size as X and Y.
%
%   P = MAP2PIX(R,X,Y) combines ROW and COL into a single array P.  If X
%   and Y are column vectors of length N, then P is an N-by-2 matrix and
%   each (P(k,:)) specifies the pixel coordinates of a single point.
%   Otherwise, P has size [size(ROW) 2], and P(k1,k2,...,kn,:) contains the
%   pixel coordinates of a single point.
%
%   [...] = MAP2PIX(R,S) combines X and Y into a single array S.  If X and
%   Y are column vectors of length N, the S should be an N-by-2 matrix such
%   that each row (S(k,:)) specifies the map coordinates of a single point.
%   Otherwise, S should have size [size(X) 2], and S(k1,k2,...,kn,:) should
%   contain the map coordinates of a single point.
%
%   Example 
%   -------
%      % Find the pixel coordinates for the spatial coordinates 
%      % (207050, 912900)
%      R = worldfileread('concord_ortho_w.tfw');
%      [r,c] = map2pix(R, 207050, 912900)
%
%   See also LATLON2PIX, MAKEREFMAT, PIX2MAP, WORLDFILEREAD.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/02/01 21:57:29 $ 

checknargin(2,3,nargin,mfilename);
error(nargoutchk(0,2,nargout));

% Check inputs, package coordinatess into column vectors (x,y).
[x, y, coordArraySize] = parseInputs(R, varargin);

% Invert the transformation
%
%     [x y] = [row col 1] * R
%
% in a way that is robust with respect to large offsets from the origin.

P = [x - R(3,1), y - R(3,2)]/R(1:2,:);

% Reshape output pixel coordinates (P) and package into a one-
% or two-element cell array.
varargout = packageOutputs(nargout, coordArraySize, P);

%--------------------------------------------------------------------------
function [x, y, coordArraySize] = parseInputs(R, coordinates)

checkrefmat(R, mfilename, 'R', 1);

switch(length(coordinates))
    
    case 1   % MAP2PIX(R,S)
        s = coordinates{1};
        sizes = size(s);
        if sizes(end) ~= 2
             eid = sprintf('%s:%s:invalidSizeS', getcomp, mfilename);
             error(eid,'The highest dimension of S must have size 2.');
        end
        if length(sizes) > 2
             coordArraySize = sizes(1:end-1);
        else
             coordArraySize = [sizes(1) 1];
        end
        s = reshape(s,prod(coordArraySize),2);
        x = s(:,1);  % Column vector
        y = s(:,2);  % Column vector
        
    case 2   % MAP2PIX(R,X,Y)
        x = coordinates{1};
        y = coordinates{2};
        if any(size(x) ~= size(y))
            eid = sprintf('%s:%s:inconsistentXAndYSizes', getcomp, mfilename);
            error(eid,'X and Y must have the same size.');
        end
        coordArraySize = size(x);
        x = x(:);  % Column vector
        y = y(:);  % Column vector
      
    otherwise
        eid = sprintf('%s:%s:internalError1', getcomp, mfilename);
        error(eid,'map2pix: Internal error.');
        
end

%--------------------------------------------------------------------------
function outputs = packageOutputs(nOutputArgs, coordArraySize, P)

switch(nOutputArgs)
    case {0,1}
        if length(coordArraySize) == 2 && coordArraySize(2) == 1
            outputSize = [coordArraySize(1) 2];
        else
            outputSize = [coordArraySize 2];
        end
        outputs = {reshape(P,outputSize)};

    case 2
        outputs = {reshape(P(:,1),coordArraySize),...
                   reshape(P(:,2),coordArraySize)};
    otherwise
        eid = sprintf('%s:%s:internalError2', getcomp, mfilename);
        error(eid,'map2pix: Internal error.');
end
