function n = noverflows(Hq)
%NOVERFLOWS  Return number of elements overflows from QFILT.
%   NOVERFLOWS(Hq) returns the total number overflows from the input,
%   output, multiplicand, product and sum quantizers from the last
%   invocation of FILTER on the QFILT object Hq.
%
%   Example:
%     w = warning('on');
%     [b,a] = butter(4,.5);
%     Hq = qfilt('ref',{b,a});
%     y = filter(Hq,randn(100,1));
%     noverflows(Hq)
%     warning(w);
%
%   See also QFILT, QFILT/FILTER.

%   Thomas A. Bryan, 10 December 1999
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2004/04/12 23:25:15 $

n = Hq.report.input.nover + ...
    Hq.report.output.nover;
for k=1:length(Hq.report.product)
  n = n + Hq.report.multiplicand(k).nover + ...
      Hq.report.product(k).nover + Hq.report.sum(k).nover; 
end
