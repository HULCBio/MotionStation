function bw2 = bwulterode(varargin)
%BWULTERODE Ultimate erosion.
%   BW2 = BWULTERODE(BW) computes the ultimate erosion of the binary
%   image BW.  The ultimate erosion of BW consists of the regional maxima
%   of the Euclidean distance transform of the complement of BW.  The
%   default connectivity for computing the regional maxima is 8 for two
%   dimensions, 26 for three dimensions, and CONNDEF(NDIMS(BW),'maximal')
%   for higer dimensions. 
%
%   BW2 = BWULTERODE(BW,METHOD,CONN) specifies the distance transform
%   method and the regional maxima connectivity.  METHOD can be one of
%   the strings 'euclidean', 'cityblock', 'chessboard', or
%   'quasi-euclidean'.  CONN may have the following scalar values:  
%
%       4     two-dimensional four-connected neighborhood
%       8     two-dimensional eight-connected neighborhood
%       6     three-dimensional six-connected neighborhood
%       18    three-dimensional 18-connected neighborhood
%       26    three-dimensional 26-connected neighborhood
%
%   Connectivity may be defined in a more general way for any dimension by
%   using for CONN a 3-by-3-by- ... -by-3 matrix of 0s and 1s.  The 1-valued
%   elements define neighborhood locations relative to the center element of
%   CONN.  CONN must be symmetric about its center element.
%
%   Class Support
%   -------------
%   BW can be numeric or logical and it must be nonsparse. It can have 
%   any dimension.  BW2 is always a logical array.
%
%   Example
%   -------
%       bwOriginal = imread('circles.png');
%       imview(bwOriginal)
%       ultimateErosion = bwulterode(bwOriginal);
%       imview(ultimateErosion)
%
%   See also BWDIST, CONNDEF, IMREGIONALMAX.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.3 $  $Date: 2003/05/03 17:50:15 $

% Testing notes
% -------------
% bw     - Real, nonsparse, numeric array, any dimension.
%          Infs and NaNs ok, treated as 1s.
%          Can be empty.
%          Required.
%
% method - Nonambiguous, case-insensitive  abbreviation of one of these
%          strings: 'euclidean', 'cityblock', 'chessboard', or
%          'quasi-euclidean'.
%          Optional.  Defaults to 'euclidean'.
%
% conn   - Valid connectivity specifier.  Defaults to
%          conndef(ndims(bw),'maximal').
%
% bw2    - logical, same size as bw.
%
% The syntax parser accepts method and conn in either order.

[bw,method,conn] = parse_inputs(varargin{:});

bw2 = imregionalmax(bwdist(~bw,method),conn);

% --------------------------------------------------

function [bw,method,conn] = parse_inputs(varargin)

checknargin(1,3,nargin,mfilename);

bw = varargin{1};
checkinput(bw,{'numeric' 'logical'},{'nonsparse'},mfilename,'BW',1);
if ~islogical(bw)
    bw = bw ~= 0;
end

method = 'euclidean';
conn = conndef(ndims(bw),'maximal');

found_method = 0;
found_conn = 0;
for k = 2:length(varargin)
    if ischar(varargin{k})
        if found_method
            eid = 'Images:bwulterode:invalidSyntax';
            msg = 'Invalid input syntax.';
            error(eid,'%s',msg);
        end
        method = checkstrs(varargin{k}, {'euclidean','cityblock',...
                            'chessboard','quasi-euclidean'}, mfilename, ...
                           'METHOD', k);
        found_method = true;
    else
        if found_conn
            eid = 'Images:bwulterode:invalidSyntax';
            msg = 'Invalid input syntax.';
            error(eid,'%s',msg);
        end
        conn = varargin{k};
        checkconn(conn, mfilename, 'CONN', k);
        found_conn = true;
    end
end
