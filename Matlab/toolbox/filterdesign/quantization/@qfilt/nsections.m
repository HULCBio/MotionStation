function n = nsections(Hq)
%NSECTIONS  Number of sections in a quantized filter.
%   NSECTIONS(Hq) returns the number of sections in a quantized
%   filter.  The number of sections is determined by the reference
%   coefficients.  See QFILT/REFERENCECOEFFICIENTS for more detail.
%
%   Example:
%     [b,a] = butter(7,.5);
%     Hq = sos(qfilt('df2t',{b,a}))
%     nsections(Hq)
%
%   See also QFILT, QFILT/GET, QFILT/SET, QFILT/REFERENCECOEFFICIENTS,
%   QFILT/SOS, QFILTCONSTRUCTION.

%   Author(s): J. Schickler
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 15:32:08 $

n = get(Hq,'numberofsections');