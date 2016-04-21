function xyz = lab2xyz(lab,wp)
%LAB2XYZ Converts CIELAB to CIEXYZ
%   XYZ = LAB2XYZ(LAB,WP) converts 1976 CIELAB tristimulus values to
%   1931 CIEXYZ as specified by ISO 13655:1996 in annex B
%   Both XYZ and LAB are n x 3 vectors, WP is a 1 x 3 vector
%
%   xyz = LAB2XYZ(LAB) converts Lab to XYZ with the white reference
%   illuminant set to D50
%
%   xyz = LAB2XYZ(LAB,WP) converts Lab to XYZ with the white reference
%   WP.
%
%   Example: 
%       d50 = whitepoint;
%       xyz = lab2xyz([100 0 0],d50)
%           0.9642    1.0000    0.8249

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2003/08/01 18:11:20 $
%   Author:  Scott Gregory, 10/18/02
%   Revised: Toshia McCabe, 12/02/02 

%Check input arguments
checknargin(1,2,nargin,'lab2xyz');
checkinput(lab,{'double'},{'real','2d','nonsparse','finite'},...
           'lab2xyz','LAB',1);
if size(lab,2) ~= 3
    eid = 'Images:lab2xyz:invalidLabData';
    msg = 'Incorrect number of columns in LAB data.';
    error(eid,'%s',msg);
end
  
if nargin < 2
    wp = whitepoint;
else
    checkinput(wp,{'double'},{'real','2d','nonsparse','finite','row',...
                        'positive'},'lab2xyz','WP',2);
    if size(wp,2) ~= 3
        eid = 'Images:lab2xyz:invalidWhitePointData';
        msg = 'Incorrect number of columns in WP.';
        error(eid,'%s',msg);
    end
end

n = size(lab,1);
fxyz = zeros(n,3);   
fxyz_n(:,2) = (lab(:,1) + 16) / 116;  
fxyz_n(:,1) = (lab(:,2) / 500) + fxyz_n(:,2);   
fxyz_n(:,3) = fxyz_n(:,2) - (lab(:,3) / 200);

xyz = fxyz_n .^3;
k = 841 / 108;
l = fxyz_n <= 6/29;
xyz(l) = (fxyz_n(l) -(16/116)) / k;
clear fxyz_n l;

% scale by white point
xyz = xyz .* repmat(wp',1,n)';
