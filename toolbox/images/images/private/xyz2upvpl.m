function uvlp =xyz2upvpl(xyz)
%XYZ2UPVPL Converts CIEXYZ to CIE u', v', and Luminance
%   uvlp = XYZ2UPVPL(XYZ) converts 1931 CIEXYZ tristimulus values scaled to 1.0
%   to 1976 CIE u',v' Chromaticity and Luminance
%   Both xyz and uvlp are n x 3 vectors
%
%   Example:
%       d50 = getwhitepoint;
%       uvlp = xyz2upvpl(d50)
%       uvlp =
%           0.2092    0.4881    1.0000

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision.2 $  $Date: 2003/08/23 05:54:28 $
%   Author:  Scott Gregory, 10/18/02
%   Revised: Toshia McCabe, 12/06/02

% Check input arguments
checknargin(1,1,nargin,'xyz2upvpl');
checkinput(xyz,{'double'},{'real','2d','nonsparse','finite'},...
    'xyz2upvpl','XYZ',1);
if size(xyz,2) ~= 3
    eid = 'Images:xyz2upvpl:invalidXyzData';
    msg = 'Incorrect number of columns in XYZ data.';
    error(eid,'%s',msg);
end

uvlp = zeros(size(xyz));
uvlp(:,1) = clipdivide(4 * xyz(:,1), xyz * [1; 15; 3]);
uvlp(:,2) = clipdivide(9 * xyz(:,2), xyz * [1; 15; 3]);
uvlp(:,3) = xyz(:,2);
