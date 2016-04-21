function qcoeff = numberofsections(Hq)
%NUMBEROFSECTIONS  Number of sections in a quantized filter.
%   NUMBEROFSECTIONS(Hq) returns the number of sections in a quantized
%   filter.  The number of sections is determined by the reference
%   coefficients.  See QFILT/REFERENCECOEFFICIENTS for more detail.
%
%   Example:
%     [b,a] = butter(7,.5);
%     Hq = sos(qfilt('df2t',{b,a}))
%     numberofsections(Hq)
%
%   See also QFILT, QFILT/GET, QFILT/SET, QFILT/REFERENCECOEFFICIENTS,
%   QFILT/SOS, QFILTCONSTRUCTION.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/14 15:30:28 $

qcoeff = get(Hq,'numberofsections');
