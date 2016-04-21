function B = imtophat(A,SE)
%IMTOPHAT Perform top hat filtering.
%   IM2 = IMTOPHAT(IM,SE) performs morphological top hat filtering on the
%   grayscale or binary input image IM using the structuring element SE,
%   where SE is returned by STREL.  SE must be a single structuring
%   element object, not an array containing multiple structuring element
%   objects.
%
%   IM2 = IMTOPHAT(IM,NHOOD), where NHOOD is an array of 0s and 1s that
%   specifies the size and shape of the structuring element, is the same
%   as IM2 = IMTOPHAT(IM,STREL(NHOOD)).
%
%   Class Support
%   -------------
%   IM can be numeric or logical and must be nonsparse.  The output image
%   has the same class as the input image.  If the input is binary
%   (logical), then the structuring element must be flat.
%
%   Example
%   -------
%   Tophat filtering can be used to correct uneven illumination when the
%   background is dark.  This example uses tophat filtering with a disk to
%   remove the uneven background illumination from the rice.png image, and
%   then it uses imadjust and stretchlim to make the result more easily
%   visible.
%
%   original = imread('rice.png');
%   imview(original)
%   se = strel('disk',12);
%   tophatFiltered = imtophat(original,se);
%   imview(tophatFiltered)
%   contrastAdjusted = imadjust(tophatFiltered);
%   imview(contrastAdjusted)
%
%   See also IMBOTHAT, STREL.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.9.4.4 $  $Date: 2003/08/23 05:52:46 $

% Testing notes
% =============
% IM     - N-D numeric nonsparse array
%          real
%          Inf's ok
%          NaN's ok for binary, but not allowed for grayscale
%          empty ok
%
% SE     - 1-by-1 STREL object or double array containing 0s and 1s.
%          must be flat for binary image
%
% IM2    - same size as IM
%          uint8 logical if islogical(IM) & isflat(SE); otherwise same class
%          as IM.

checknargin(2,2,nargin,mfilename);
checkinput(A, {'numeric' 'logical'}, {'real' 'nonsparse'}, mfilename, ...
           'IM', 1);

SE = strelcheck(SE,mfilename,'SE',2);

if islogical(A) && ~isflat(SE)
    eid = 'Images:imtophat:binaryImageWithNonflatStrel';
    msg = 'The structuring element, SE, must be flat if the input image, IM, is binary';
    error(eid,'%s',msg);
end

if islogical(A)
    B = A & ~imopen(A,SE);
else
    B = imsubtract(A, imopen(A,SE));
end

