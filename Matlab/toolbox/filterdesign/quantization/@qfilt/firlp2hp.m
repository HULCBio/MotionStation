function f = firlp2hp(h,varargin)
%FIRLP2HP  FIR Type I lowpass to highpass transformation.
%   F = FIRLP2HP(H) performs a lowpass to highpass transformation
%   on the filter object H and returns a new filter object F. See
%   the help for FILTERDESIGN/FIRLP2HP for more info.
%
%   F = FIRLP2HP(H,'wide') performs a lowpass to wideband highpass
%   transformation.
%
%   See also QFILT/FIRLP2LP, ZEROPHASE, QFILT/IIRLP2LP, QFILT/IIRLP2HP,
%            QFILT/IIRLP2BP, QFILT/IIRLP2BS.

%   Author(s): R. Losada
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/14 15:31:51 $ 

error(nargchk(1,2,nargin));

f = firxform(h,@firlp2hp,varargin{:});
