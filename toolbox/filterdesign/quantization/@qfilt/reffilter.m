function Hqr = reffilter(Hq)
%REFFILTER   Return the reference filter for the QFILT.

%   Author(s): J. Schickler
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:26:06 $

Hqr = copyobj(Hq);

% Overwrite with doubles.
set(Hqr, 'quantizer', 'double');

% [EOF]
