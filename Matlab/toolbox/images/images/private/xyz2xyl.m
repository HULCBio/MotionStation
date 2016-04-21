function xyl =xyz2xyl(xyz)
%XYZ2XYL Converts CIEXYZ to CIE Chromaticity and Luminance
%   xyl = XYZ2XYL(XYZ) converts 1931 CIEXYZ tristimulus values scaled to 1.0
%   to 1931 CIE Chromaticity and Luminance
%   Both xyz and xyl are n x 3 vectors
%
%   Example:
%       d50 = whitepoint;
%       xyl =xyz2xyl(xyz)
%       xyl =
%           0.3457    0.3585    1.0000

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2003/08/23 05:54:30 $
%   Author:  Scott Gregory, 10/18/02
%   Revised: Toshia McCabe, 1206/02

% Check input arguments
checknargin(1,1,nargin,'xyz2xyl');
checkinput(xyz,{'double'},{'real','2d','nonsparse','finite'},...
           'xyz2xyl','XYZ',1);
if size(xyz,2) ~= 3
    eid = 'Images:xyz2xyl:invalidXyzData';
    msg = 'Incorrect number of columns in XYZ data.';
    error(eid,'%s',msg);
end

xyl = zeros(size(xyz));
sum_xyz = sum(xyz,2);
xyl(:,1) = clipdivide(xyz(:,1), sum_xyz);
xyl(:,2) = clipdivide(xyz(:,2), sum_xyz);
xyl(:,3) = xyz(:,2);
