function Lab = lch2lab(lch)
%LCH2LAB Converts CIELAB Lightness, Chroma, Hue to CIELAB
%   LAB = LCH2LAB(lch) converts CIELAB Lightness, Chroma,   
%   Hue (in degrees -180 to +180) to 1976 CIELAB.
%   Both lch and lab are n x 3 vectors
%
%   Example: 
%       lch = lch2lab([ 90.0000   14.1421   45.0000])
%           90.0000   10.0000   10.0000

%   $Revision: 1.1.6.2 $  $Date: 2003/05/03 17:52:10 $
%   Copyright 1993-2003 The MathWorks, Inc.
%   Author:  Scott Gregory, 10/18/02
%   Revised: Toshia McCabe, 11/15/02

% Check input arguments
checknargin(1,1,nargin,'lchlab');
checkinput(lch,{'double'},{'real','2d','nonsparse','finite'},...
           'lch2lab','LCH',1);
if size(lch,2) ~= 3
    eid = 'Images:lch2lab:invalidLchData';
    msg = 'Incorrect number of columns in LCH data.';
    error(eid,'%s',msg);
end

Lab = zeros(size(lch));
Lab(:,1) = lch(:,1);
Lab(:,2) = cos((pi/180) * lch(:,3)) .* lch(:,2);
Lab(:,3) = sin((pi/180) * lch(:,3)) .* lch(:,2);