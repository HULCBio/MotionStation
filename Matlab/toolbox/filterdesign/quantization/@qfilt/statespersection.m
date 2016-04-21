function qcoeff = statespersection(Hq)
%STATESPERSECTION  Number of states per section of a quantized filter. 
%   STATESPERSECTION(Hq) returns the number of states in each section of a
%   quantized filter.  The number of states in each section is determined by the
%   filter structure and the reference coefficients.  See QFILT/FILTERSTRUCTURE
%   and QFILT/REFERENCECOEFFICIENTS for more detail.
%
%   Example:
%     [b,a] = butter(7,.5);
%     Hq = sos(qfilt('df2t',{b,a}))
%     statespersection(Hq)
%
%   See also QFILT, QFILT/GET, QFILT/SET, QFILT/FILTERSTRUCTURE,
%   QFILT/REFERENCECOEFFICIENTS, QFILT/SOS, QFILTCONSTRUCTION.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/14 15:29:53 $

qcoeff = get(Hq,'statespersection');
