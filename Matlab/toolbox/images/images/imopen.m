function B = imopen(varargin)
%IMOPEN Open image.
%   IM2 = IMOPEN(IM,SE) performs morphological opening on the grayscale
%   or binary image IM with the structuring element SE.  SE must be a
%   single structuring element object, as opposed to an array of
%   objects.
%
%   IM2 = IMOPEN(IM,NHOOD) performs opening with the structuring element
%   STREL(NHOOD), where NHOOD is an array of 0s and 1s that specifies the
%   structuring element neighborhood.
%
%   Class Support
%   -------------
%   IM can be any numeric or logical class and any dimension, and must be
%   nonsparse.  If IM is logical, then SE must be flat.  IM2 has the same
%   class as IM.
%
%   Example
%   -------
%   Remove snowflakes having a radius less than 5 pixels by opening it with a
%   disk-shaped structuring element having a 5 pixel radius.
%
%       original = imread('snowflakes.png');
%       se = strel('disk',5);
%       afterOpening = imopen(original,se);
%       imview(original), imview(afterOpening,[])
%
%   See also IMCLOSE, IMDILATE, IMERODE, STREL.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.8.4.3 $  $Date: 2003/08/23 05:52:37 $

[A,SE,pre_pack] = ParseInputs(varargin{:});

M = size(A,1);
if pre_pack
    A = bwpack(A);
    packopt = 'ispacked';
else
    packopt = 'notpacked';
end

B = imdilate(imerode(A,SE,packopt,M),SE,packopt,M);

if pre_pack
    B = bwunpack(B,M);
end

function [A,se,pre_pack] = ParseInputs(varargin)

checknargin(2,2,nargin,mfilename);

% Get the required inputs and check them for validity.
A = varargin{1};
checkinput(A, {'numeric' 'logical'}, {'real' 'nonsparse'}, mfilename, ...
           'I or BW', 1);
se = strelcheck(varargin{2}, mfilename, 'SE', 2);
if length(se(:)) > 1
    eid = 'Images:imopen:nonscalarStrel';
    msg = 'SE must be a single STREL rather than a STREL array.';
    error(eid,'%s',msg);
end

strel_is_flat = isflat(se);
input_is_logical = islogical(A);
input_is_2d = ndims(A) == 2;
strel_is_2d = ndims(getnhood(se)) == 2;
is_binary_op = input_is_logical;

if input_is_logical && ~strel_is_flat
    eid = 'Images:imopen:binaryImageWithNonflatStrel';
    msg = 'Cannot open a binary image with a nonflat structuring element.';
    error(eid,'%s',msg);
end

pre_pack = is_binary_op && input_is_2d && strel_is_2d;
