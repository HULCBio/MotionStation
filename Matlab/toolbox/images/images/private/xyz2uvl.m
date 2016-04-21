function uvl =xyz2uvl(xyz)
%XYZ2UVL Converts CIEXYZ to CIE u, v, and Luminance
%   uvl = XYZ2UVL(XYZ) converts 1931 CIEXYZ tristimulus values scaled to 1.0
%   to 1960 CIE u,v Chromaticity and Luminance
%   Both xyz and uvl are n x 3 vectors
%
%   Example:
%       d50 = getwhitepoint;
%       uvl = xyz2uvl(d50)
%       uvl =
%           0.2092    0.3254    1.0000

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2003/08/23 05:54:29 $
%   Author:  Scott Gregory, 10/18/02
%   Revised: Toshia McCabe, 12/06/02 

% Check input arguments
checknargin(1,1,nargin,'xyz2uvl');
checkinput(xyz,{'double'},{'real','2d','nonsparse','finite'},...
           'xyz2uvl','XYZ',1);
if size(xyz,2) ~= 3
    eid = 'Images:xyz2uvl:invalidXyzData';
    msg = 'Incorrect number of columns in XYZ data.';
    error(eid,'%s',msg);
end

uvl = zeros(size(xyz));
uvl(:,1) = clipdivide(4 * xyz(:,1), xyz * [1; 15; 3]);
uvl(:,2) = clipdivide(6 * xyz(:,2), xyz * [1; 15; 3]);
uvl(:,3) = xyz(:,2);
