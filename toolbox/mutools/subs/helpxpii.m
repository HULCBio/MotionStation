function [ldpim,matinfo] = helpxpii(pim)
% function [ldpim,matinfo] = helpxpii(pim)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

ldpim=[]; matinfo=[];

if ~isempty(pim)
    ldpim = pim(1);
    num = pim(3);
    repindex = pim(4:3+num);
    rows = max(repindex);
    [ss,idx] = sort(repindex);
    rowd = pim(4+1*num:3+2*num);
    cold = pim(4+2*num:3+3*num);
    lenv = abs(rowd).*cold;
    startstop = cumsum([4+3*num;lenv]);
    strt = startstop(1:num);
    stp = startstop(2:num+1)-1;
    matinfo  = [2*ones(rows,1) ones(rows,1) zeros(rows,2)];
    matinfo(ss,1) = strt(idx);
    matinfo(ss,2) = stp(idx);
    matinfo(ss,3) = rowd(idx);
    matinfo(ss,4) = cold(idx);
end