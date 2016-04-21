function xyzd = xyz2double(xyz)
%XYZ2DOUBLE Convert XYZ data to double.
%   XYZD = XYZ2DOUBLE(XYZ) converts an M-by-3 or M-by-N-by-3 array of XYZ
%   color values to double. XYZD has the same size as XYZ.
%
%   XYZ encoding conventions
%   ------------------------
%   The Image Processing Toolbox follows the convention that
%   double-precision XYZ arrays contain 1931 CIE XYZ values.
%   XYZ arrays that are uint16 follow the convention in the ICC profile
%   specification (ICC.1:2001-4, www.color.org) for representing XYZ
%   values as unsigned 16-bit integers.  There is no standard
%   representation of XYZ values as unsigned 8-bit integers.  The ICC
%   encoding convention is illustrated by this table:
%
%       Value (X, Y, or Z)     uint16 value
%       ------------------     ------------
%       0.0                        0
%       1.0                    32768
%       1.0 + (32767/32768)    65535
%
%   Class Support
%   -------------
%   XYZ is a uint16 or double array that must be real and nonsparse.
%   XYZD is double.
%
%   Example
%   -------
%   Convert uint16-encoded XYZ values to double.
%
%       xyz2double(uint16([100 32768 65535]))
%
%   See also APPLYCFORM, LAB2DOUBLE, LAB2UINT8, LAB2UINT16, MAKECFORM, 
%            WHITEPOINT, XYZ2UINT16.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2003/08/23 05:54:49 $

checknargin(1, 1, nargin, mfilename);
checkinput(xyz, {'uint8', 'uint16', 'double'}, {'real', 'nonsparse'}, ...
           mfilename, 'XYZ', 1);

if ~ ( ((ndims(xyz) == 2) && (size(xyz,2) == 3)) || ...
        ((ndims(xyz) == 3) && (size(xyz,3) == 3)) )
    eid = 'Images:xyz2double:invalidInputSize';
    msg = 'XYZ must be Px3 or MxNx3.';
    error(eid,'%s',msg);
end

input_size = size(xyz);
xyz = reshape(xyz, [], 3);

xyzd = encode_color(xyz, 'xyz', class(xyz), 'double');

xyzd = reshape(xyzd, input_size);
