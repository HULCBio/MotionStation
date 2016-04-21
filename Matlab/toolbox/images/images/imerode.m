function B = imerode(A,se,varargin)
%IMERODE Erode image.
%   IM2 = IMERODE(IM,SE) erodes the grayscale, binary, or packed binary image
%   IM, returning the eroded image, IM2.  SE is a structuring element
%   object, or array of structuring element objects, returned by the
%   STREL function.
%
%   If IM is logical and the structuring element is flat, IMERODE
%   performs binary erosion; otherwise it performs grayscale erosion.  If
%   SE is an array of structuring element objects, IMERODE performs
%   multiple erosions of the input image, using each structuring element
%   in succession.
%
%   IM2 = IMERODE(IM,NHOOD) erodes the image IM, where NHOOD is an array
%   of 0s and 1s that specifies the structuring element.  This is
%   equivalent to the syntax IMERODE(IM,STREL(NHOOD)).  IMERODE uses this
%   calculation to determine the center element, or origin, of the
%   neighborhood:  FLOOR((SIZE(NHOOD) + 1)/2).
%
%   IM2 = IMERODE(IM,SE,PACKOPT,M) or IMERODE(IM,NHOOD,PACKOPT,M) specifies
%   whether IM is a packed binary image and, if it is, provides the row
%   dimension, M, of the original unpacked image.  PACKOPT can have
%   either of these values:
%
%       'ispacked'    IM is treated as a packed binary image as produced
%                     by BWPACK.  IM must be a 2-D uint32 array and SE
%                     must be a flat 2-D structuring element.  If the
%                     value of PACKOPT is 'ispacked', SHAPE must be
%                     'same'.
%
%       'notpacked'   IM is treated as a normal array.  This is the
%                     default value.
%
%   If PACKOPT is 'ispacked', you must specify a value for M.
%
%   IM2 = IMERODE(...,SHAPE) determines the size of the output image.  
%   SHAPE can have either of these values:
%
%       'same'        Make the output image the same size as the input
%                     image.  This is the default value.  If the value of
%                     PACKOPT is 'ispacked', SHAPE must be 'same'.
%
%       'full'        Compute the full erosion.
%
%   Class Support
%   -------------
%   IM can be numeric or logical and it can be of any dimension.  If IM is
%   logical and the structuring element is flat, then output will be
%   logical; otherwise the output will have the same class as the input.  If
%   the input is packed binary, then the output is also packed binary. 
%
%   Examples
%   --------
%   Erode the binary image in text.png with a vertical line:
%
%       originalBW = imread('text.png');
%       se = strel('line',11,90);
%       erodedBW = imerode(originalBW,se);
%       imview(originalBW)
%       imview(erodedBW)
%
%   Erode the grayscale image in cameraman.tif with a rolling ball:
%
%       originalI = imread('cameraman.tif');
%       se = strel('ball',5,5);
%       erodedI = imerode(originalI,se);
%       imview(originalI), imview(erodedI)
%
%   See also BWPACK, BWUNPACK, CONV2, FILTER2, IMCLOSE, IMDILATE, IMOPEN,
%            STREL.

%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.14.4.4 $  $Date: 2003/08/23 05:52:28 $

% Testing notes
% Syntaxes
% --------
% B = imerode(A,se)
% B = imerode(A,se,packopt)
% B = imerode(A,se,packopt,M)
% B = imerode(...,padopt)
%
% A:       numeric or logical, real, full, N-D array.  May be empty.
%          May contain Infs.  May not contain NaNs.  Required.
%
% se:      A single STREL object, a STREL array, or a real, full, double,
%          N-D array containing 0s and 1s.  If se is an empty array of
%          strels, then B should be the same as A, unless the input is
%          logical and not packed, in which case B should be
%          uint8(A ~= 0).  If se contains no neighbors (e.g.,
%          strel(zeros(3,3))), then B should be filled with the maximum
%          value for its type.  Required.
%
% packopt: Either 'ispacked' or 'notpacked'.  May be abbreviated; case
%          insensitive match.  Optional.  Defaults to 'notpacked' if not
%          specified.
%
% M:       Integer specifying the unpacked row dimension of the input
%          image.  Required if packopt is 'ispacked'; otherwise
%          optional and not used.
%
% padopt:  Either 'same' or 'full'.  May be abbreviated; case insensitive
%          match.  Optional.  Defaults to 'same' if not specified.
%
% B:       Array of the same size and class as A.  Exception: if A is
%          logical and the strel is all flat and packopt is 'notpacked',
%          then B is a logical array.
%
% Key logic branches:
%
% se:      flat or nonflat?
% se:      array or single strel?
% se:      decomposed or nondecomposed?
% se:      2-D or N-D?
% A:       logical or nonlogical?
% A:       uint8 or not?
% A:       uint32 or not?
% packopt: 'ispacked' or 'notpacked'?
% padopt:  'full' or 'same'?

checknargin(2,5,nargin,mfilename);

B = morphop(A,se,'erode',mfilename,varargin{:});
