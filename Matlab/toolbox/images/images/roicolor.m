function dout=roicolor(a,low,high)
%ROICOLOR Select region of interest based on color.
%   ROICOLOR selects a region of interest within an indexed or
%   intensity image and returns a binary image. (You can use the
%   returned image as a mask for masked filtering using
%   ROIFILT2.)
%
%   BW = ROICOLOR(A,LOW,HIGH) returns a region of interest
%   selected as those pixels that lie within the colormap range
%   [LOW HIGH]:
%
%       BW = (A >= LOW) & (A <= HIGH);
%
%   BW is a binary image with 0's outside the region of interest
%   and 1's inside.
%
%   BW = ROICOLOR(A,V) returns a region of interest selected as
%   those pixels in A that match the values in vector V. BW is a
%   binary image with 1's where the values of A match the values
%   of V.
%
%   Class Support
%   -------------
%   The input image A must be numeric. The output image BW is 
%   of class logical.
%
%   Example
%   -------
%       I = imread('rice.png');
%       BW = roicolor(I,128,255);
%       imview(I), imview(BW)
%
%   See also ROIPOLY.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 5.21.4.5 $  $Date: 2003/08/23 05:54:38 $

error(nargchk(2,3,nargin,'struct'));

if ndims(a)>2
    eid = sprintf('Images:%s:moreThan2D',mfilename);
    error(eid,'%s',...
          'Images with dimensions greater than two are not supported.');
end

if nargin==2,
    v = low(:);
    d = repmat(false, size(a));
    for i=1:length(v),
        d(:) = d | (a==v(i));
    end
else
    d = (a >= low) & (a <= high);
end

if nargout==0,
    b = ones(size(a));
    b(d) = a(d);
    if min(a(:))<1, 
        imagesc(b);
    else 
        image(b), 
    end
    return
end
dout = d;
