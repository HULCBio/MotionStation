function lab = xyz2lab(xyz,wp)
%XYZ2LAB Converts CIEXYZ to CIELAB.
%   lab = XYZ2LAB(XYZ,xyzn) converts 1931 CIEXYZ tristimulus values to
%   1976 CIELAB as specified by ISO 13655:1996 in annex B
%   Both xyz and lab are n x 3 vectors, xyzn is a 1 x 3 vector
%
%   lab = XYZ2LAB(xyz) converts XYZ to Lab with the white reference
%   illuminant set to D50
%
%   lab = XYZ2LAB(xyz,wp) converts XYZ to Lab with the white reference
%   wp.
%
%   Example:
%       d50 = whitepoint;
%       lab = xyz2lab(d50)
%       lab =
%           100     0     0

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2003/08/01 18:11:29 $
%   Author:  Scott Gregory, 10/18/02
%   Revised: Toshia McCabe, 12/02/02 

%Check input arguments
checknargin(1,2,nargin,'xyz2lab');
checkinput(xyz,{'double'},{'real','2d','nonsparse','finite'},...
           'xyz2lab','XYZ',1);
if size(xyz,2) ~= 3
    eid = 'Images:xyz2lab:invalidXyzData';
    msg = 'Incorrect number of columns in XYZ data.';
    error(eid,'%s',msg);
end

if nargin < 2
    wp = whitepoint;
else
    checkinput(wp,{'double'},{'real','2d','nonsparse','finite','row',...
                        'positive'},'xyz2lab','WP',2);
    if size(wp,2) ~= 3
        eid = 'Images:xyz2lab:invalidWhitePointData';
        msg = 'Incorrect number of columns in WP.';
        error(eid,'%s',msg);
    end
end

% normalize by white point
n = size(xyz,1);
xyz = xyz ./ repmat(wp',1,n)';

% cube root normalized xyz
fxyz_n = xyz .^ (1/3);
% if normalized x, y, or z less than or equal to 216 / 24389 apply function 2  
L = xyz <= 216 / 24389;
% function 2
k = 841 / 108;
fxyz_n(L) = k * xyz(L) + 16/116;
clear xyz L;

lab = zeros(n,3);
% calculate L*  
lab(:,1) = 116 * fxyz_n(:,2) - 16;
% calculate a*  
lab(:,2) = 500 * (fxyz_n(:,1) - fxyz_n(:,2));
% calculate b*  
lab(:,3) = 200 * (fxyz_n(:,2) - fxyz_n(:,3));
