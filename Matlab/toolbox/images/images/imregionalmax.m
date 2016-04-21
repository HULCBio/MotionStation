function BW = imregionalmax(varargin)
%IMREGIONALMAX Compute regional maxima of I.
%   BW = IMREGIONALMAX(I) computes the regional maxima of I.
%   IMREGIONALMAX returns a binary image, BW, the same size as I, that
%   identifies the locations of the regional maxima in I.  In BW, pixels
%   that are set to 1 identify regional maxima; all other pixels are set
%   to 0.  
%
%   Regional maxima are connected components of pixels with the same
%   intensity value, t, whose external boundary pixels all have a value
%   less than t.
%
%   By default, IMREGIONALMAX uses 8-connected neighborhoods for 2-D
%   images and 26-connected neighborhoods for 3-D images.  For higher
%   dimensions, IMREGIONALMAX uses CONNDEF(NDIMS(I),'maximal').
%
%   BW = IMREGIONALMAX(I,CONN) computes the regional maxima of I using
%   the specified connectivity.  CONN may have the following scalar
%   values:
%
%       4     two-dimensional four-connected neighborhood
%       8     two-dimensional eight-connected neighborhood
%       6     three-dimensional six-connected neighborhood
%       18    three-dimensional 18-connected neighborhood
%       26    three-dimensional 26-connected neighborhood
%
%   Connectivity may be defined in a more general way for any dimension by
%   using for CONN a 3-by-3-by- ... -by-3 matrix of 0s and 1s.  The 1-valued
%   elements define neighborhood locations relative to the center element of
%   CONN.  CONN must be symmetric about its center element.
%
%   Class support
%   -------------
%   I can be of any nonsparse numeric class and any dimension.  BW is
%   logical.
%
%   Example
%   -------
%       A = 10*ones(10,10);
%       A(2:4,2:4) = 22;    % maxima 12 higher than surrounding pixels
%       A(6:8,6:8) = 33;    % maxima 23 higher than surrounding pixels
%       A(2,7) = 44;
%       A(3,8) = 45;
%       A(4,9) = 44
%       regmax = imregionalmax(A)
%
%   See also CONNDEF, IMRECONSTRUCT, IMREGIONALMIN.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.2 $  $Date: 2003/05/03 17:51:02 $

% Input and output specs
% ----------------------
% I:     N-D, full, real matrix
%        uint8, uint16, or double
%        logical ok, but ignored
%        Empty ok
%        Infs ok
%        NaNs not allowed.
% 
% CONN:  connectivity
% 
% BW:    logical uint8, same size as I
%        contains only 0s and 1s.

checknargin(1,2,nargin,mfilename);
checkinput(varargin{1}, {'numeric','logical'}, {'real','nonsparse'}, mfilename, ...
            'I', 1);
I = varargin{1};

if (nargin > 1)
  checkconn(varargin{2},mfilename,'CONN',2);
  conn = varargin{2};
  BW = imregionalmaxmex(I,conn);
else
  BW = imregionalmaxmex(I);
end
