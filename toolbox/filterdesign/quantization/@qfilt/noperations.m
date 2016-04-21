function n = noperations(Hq)
%NOPERATIONS  Number of product and sum operations.
%   NOPERATIONS(Hq) returns the total number of quantization operations
%   from the product and sum quantizers from the last invocation of
%   FILTER on the QFILT object Hq.
%
%   Example:
%     w = warning('on');
%     [b,a] = butter(4,.5);
%     Hq = qfilt('ref',{b,a});
%     y = filter(Hq,randn(100,1));
%     noperations(Hq)
%     warning(w);
%
%   See also QFILT, QFILT/FILTER.

%   Thomas A. Bryan, 10 December 1999
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.2 $  $Date: 2004/04/12 23:25:12 $

n = 0;
for k=1:length(Hq.report.product)
  n = n + Hq.report.product(k).noperations + Hq.report.sum(k).noperations;
end
