function lowhigh = stretchlim(varargin)
%STRETCHLIM Find limits to contrast stretch an image.
%   LOW_HIGH = STRETCHLIM(I,TOL) returns a pair of intensities that can be
%   used by IMADJUST to increase the contrast of an image.
%
%   TOL = [LOW_FRACT HIGH_FRACT] specifies the fraction of the image to
%   saturate at low and high intensities. 
%
%   If TOL is a scalar, TOL = LOW_FRACT, and HIGH_FRACT = 1 - LOW_FRACT,
%   which saturates equal fractions at low and high intensities.
%
%   If you omit the argument, TOL defaults to [0.01 0.99], saturating 2%.
%
%   If TOL = 0, LOW_HIGH = [min(I(:)) max(I(:))].
%
%   LOW_HIGH = STRETCHLIM(RGB,TOL) returns a 2-by-3 matrix of intensity
%   pairs to saturate each plane of the RGB image. TOL specifies the same
%   fractions of saturation for each plane.
%
%   Class Support
%   -------------
%   The input image can be of class uint8, uint16, or double. The output
%   intensities are of class double and have values between 0 and 1.
%
%   Example
%   -------
%       I = imread('pout.tif');
%       J = imadjust(I,stretchlim(I),[]);
%       imview(I), imview(J)
%
%   See also BRIGHTEN, HISTEQ, IMADJUST.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.7.4.5 $ $Date: 2003/12/13 02:48:40 $

[img,tol] = ParseInputs(varargin{:});

if isa(img,'uint8')
    nbins = 256;
else
    nbins = 65536;
end

tol_low = tol(1);
tol_high = tol(2);
p = size(img,3);

for i = 1:p                          % Find limits, one plane at a time
    N = imhist(img(:,:,i),nbins);
    cdf = cumsum(N)/sum(N);
    ilow = find(cdf>tol_low, 1, 'first');
    ihigh = find(cdf>=tol_high, 1, 'first');   
    if ilow==ihigh               
      ilowhigh(:,i) = [1; nbins]; % limits are same, use default   
    else
      ilowhigh(:,i) = [ilow;ihigh];
    end
end   

lowhigh = (ilowhigh - 1)/(nbins-1);  % convert to range [0 1]

  
%-----------------------------------------------------
% Subfunction ParseInputs
%
function [img,tol] = ParseInputs(varargin)

img = [];
tol = [.01 .99];  % default 
msg = '';

checknargin(1, 2, nargin, mfilename);

img = varargin{1};

if nargin > 1
    tol = varargin{2};
    switch numel(tol)
      case 1
        tol(2) = 1 - tol;
        
      case 2
        if (tol(1) >= tol(2))
            msgId = 'Images:stretchlim:invalidTolOrder';
            msg = 'TOL(1) must be less than TOL(2).';
            error(msgId,'%s',msg);
        end
      otherwise
        msgId = 'Images:stretchlim:invalidTolSize';
        msg = 'TOL must have 1 or 2 elements.';
        error(msgId,'%s',msg);
    end
end

if ( any(tol < 0) || any(tol > 1) || any(isnan(tol)) )
    msgId = 'Images:stretchlim:tolOutOfRange';
    msg = 'TOL must be in the range [0 1].';
    error(msgId,'%s',msg);
end

checkinput(img, {'uint8', 'uint16', 'double'}, {'real', 'nonsparse'}, ...
           mfilename, 'I or RGB', 1);

if (ndims(img) > 3) 
    msgId = 'Images:stretchlim:dimTooHigh';
    msg = 'STRETCHLIM only supports individual images.';
    error(msgId,'%s',msg);
end

