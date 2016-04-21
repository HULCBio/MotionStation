function r = isreal(Hq)
%ISREAL True for quantized filter with real coefficients.
%   ISREAL(Hq) returns 1 if all filter coefficients in quantized filter
%   Hq have zero imaginary part.  Otherwise, a 0 is returned.
% 
%   ~ISREAL(Hq) detects complex filters (i.e., filters that have any
%   coefficients with a non-zero imaginary part).
%
%   Example:
%     Hq = qfilt;
%     isreal(Hq)
%
%   See also QFILT/ISALLPASS, QFILT/ISFIR, QFILT/ISLINPHASE,
%   QFILT/ISMAXPHASE, QFILT/ISMINPHASE, QFILT/ISSTABLE.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.17 $  $Date: 2002/04/14 15:30:37 $

coeff = get(Hq,'ReferenceCoefficients');
r = isrealcell(coeff);
