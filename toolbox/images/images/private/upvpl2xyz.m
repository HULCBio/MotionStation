function xyz = upvpl2xyz (uvlp)
%UPVPLXYZ Converts CIE u,v and Luminance to CIEXYZ 
%   xyz = UPVPL2XYZ(uvlp) converts to 1976 CIE u',v' Chromaticity and Luminance
%   1931 CIEXYZ tristimulus values scaled to 1.0
%   Both xyz and uvlp are n x 3 vectors
%
%   Example:
%       xyz = upvpl2xyz([0.2092    0.4881    1.0000])
%       xyz =
%           0.9644    1.0000    0.8248

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision.2 $  $Date: 2003/08/23 05:54:25 $
%   Author:  Scott Gregory, 10/18/02
%   Revised: Toshia McCabe, 12/6/02

%Check input arguments
checknargin(1,1,nargin,'upvpl2xyz');
checkinput(uvlp,{'double'},{'real','2d','nonsparse','finite'},...
           'upvpl2xyz','UVLP',1);
if size(uvlp,2) ~= 3
    eid = 'Images:upvpl2lxyz:invalidUpvplData';
    msg = 'Incorrect number of columns in UVLP data.';
    error(eid,'%s',msg);
end

xyz = zeros(size(uvlp));
xyz(:,1) = clipdivide(uvlp(:,3) * 9 .* uvlp(:,1),  4 * uvlp(:,2));
xyz(:,2) = uvlp(:,3);
xyz(:,3) = clipdivide(4 - (20/3) * uvlp(:,2) - uvlp(:,1), ...
                      (4/3) * uvlp(:,2)) .*  uvlp(:,3);
