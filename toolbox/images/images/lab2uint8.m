function lab8 = lab2uint8(lab)
%LAB2UINT8 Convert L*a*b* data to uint8.
%   LAB8 = LAB2UINT8(LAB) converts an M-by-3 or M-by-N-by-3 array of
%   L*a*b* color values to uint8.  LAB8 has the same size as LAB.
%
%   L*a*b* encoding conventions
%   ---------------------------
%   The Image Processing Toolbox follows the convention that
%   double-precision L*a*b* arrays contain 1976 CIE L*a*b* values.
%   L*a*b* arrays that are uint8 or uint16 follow the convention in the
%   ICC profile spec (ICC.1:2001-4, www.color.org) for representing
%   L*a*b* values as unsigned 8-bit or 16-bit integers.  The ICC encoding
%   convention is illustrated by these tables:
%
%       Value (L*)             uint8 value         uint16 value
%       ----------             -----------         ------------
%         0.0                    0                     0
%       100.0                  255                 65280
%       100.0 + (25500/65280)  none                65535
%
%       Value (a* or b*)       uint8 value         uint16 value
%       ----------------       -----------         ------------
%       -128.0                   0                     0
%          0.0                 128                 32768
%        127.0                 255                 65280
%        127.0 + (255/256)     none                65535
%
%   Class Support
%   -------------
%   LAB is a uint8, uint16, or double array that must be real and
%   nonsparse.  LAB8 is uint8.
%
%   Example
%   -------
%   Convert full intensity neutral color (white) from double to uint8.
%
%       lab2uint8([100 0 0])
%
%   See also APPLYCFORM, LAB2DOUBLE, LAB2UINT16, MAKECFORM, WHITEPOINT,
%            XYZ2DOUBLE, XYZ2UINT16.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2003/12/13 02:43:13 $

checknargin(1, 1, nargin, mfilename);
checkinput(lab, {'uint8', 'uint16', 'double'}, {'real', 'nonsparse'}, ...
           mfilename, 'LAB', 1);

if ~ ( ((ndims(lab) == 2) && (size(lab,2) == 3)) || ...
        ((ndims(lab) == 3) && (size(lab,3) == 3)) )
    eid = 'Images:lab2uint8:invalidInputSize';
    msg = 'LAB must be Px3 or MxNx3.';
    error(eid,'%s',msg);
end

input_size = size(lab);
lab = reshape(lab, [], 3);

lab8 = encode_color(lab, 'lab', class(lab), 'uint8');

lab8 = reshape(lab8, input_size);

