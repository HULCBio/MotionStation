function v = issos(Hq)
%ISSOS True for second-order-section filter.
%   ISSOS(Hq) returns 1 if all sections of quantized filter Hq have
%   order less than or equal to two, and 0 otherwise.
%
%   Example:
%     warning off
%     [b,a] = butter(5,.5);
%     Hq = sos(qfilt('ref',{b,a}));
%     v = issos(Hq)
%
%   See also QFILT, QFILT/ORDER.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/14 15:31:18 $

v = max(order(Hq,1:numberofsections(Hq)))<=2;
