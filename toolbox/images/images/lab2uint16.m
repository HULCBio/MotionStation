function lab16 = lab2uint16(lab)
%LAB2UINT16 Convert L*a*b* data to uint16.
%   LAB16 = LAB2UINT16(LAB) converts an M-by-3 or M-by-N-by-3 array of
%   L*a*b* color values to uint16.  LAB16 has the same size as LAB.
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
%   nonsparse.  LAB16 is uint16.
%
%   Example
%   -------
%   Convert full intensity neutral color (white) from double to uint16.
%
%       lab2uint16([100 0 0])
%
%   See also APPLYCFORM, LAB2DOUBLE, LAB2UINT8, MAKECFORM, WHITEPOINT,
%            XYZ2DOUBLE, XYZ2UINT16.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2003/08/23 05:52:57 $

checknargin(1, 1, nargin, mfilename);
checkinput(lab, {'uint8', 'uint16', 'double'}, {'real', 'nonsparse'}, ...
           mfilename, 'LAB', 1);

if ~ ( ((ndims(lab) == 2) && (size(lab,2) == 3)) || ...
        ((ndims(lab) == 3) && (size(lab,3) == 3)) )
    eid = 'Images:lab2uint16:invalidInputSize';
    msg = 'LAB must be Px3 or MxNx3.';
    error(eid,'%s',msg);
end

input_size = size(lab);
lab = reshape(lab, [], 3);

lab16 = encode_color(lab, 'lab', class(lab), 'uint16');

lab16 = reshape(lab16, input_size);
