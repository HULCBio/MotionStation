function f = firlp2lp(h)
%FIRLP2LP  FIR Type I lowpass to lowpass transformation.
%   F = FIRLP2LP(H) performs a lowpass to lowpass transformation
%   on the filter object H and returns a new filter object F. See
%   the help for FILTERDESIGN/FIRLP2LP for more info.
%
%   See also QFILT/FIRLP2HP, ZEROPHASE, QFILT/IIRLP2LP, QFILT/IIRLP2HP,
%            QFILT/IIRLP2BP, QFILT/IIRLP2BS.

%   Author(s): R. Losada
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 15:31:48 $ 

error(nargchk(1,1,nargin));

f = firxform(h,@firlp2lp);
