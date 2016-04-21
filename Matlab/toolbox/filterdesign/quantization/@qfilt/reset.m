function reset(Hq)
%RESET  Resets quantizers in the object.
%   RESET(Hq) resets all the quantizers in QFILT object Hq except for the
%   coefficients. 
%
%   Example:
%     w = warning('on');
%     Hq = qfilt;
%     y = filter(Hq,randn(100,1));
%     reset(Hq)
%     qreport(Hq)
%     warning(w);
%
%   See also QFILT, QFILT/FILTER, QREPORT.

%   Thomas A. Bryan, 31 August 1999
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.7.4.2 $  $Date: 2004/04/12 23:26:07 $

reset(Hq.inputformat,Hq.outputformat,Hq.multiplicandformat, ...
    Hq.productformat,Hq.sumformat);

Hq.report = qreportinit(numberofsections(Hq),Hq.report.coefficient);
if ~isempty(inputname(1))
  assignin('caller',inputname(1),Hq);
end
