%
% function [k] = hinffi_c(p,ncon,f,r12)
%
% Form the controller given the xinf solution, f and r12.
%

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [k] = hinffi_c(p,ncon,f,r12)
[a,bp,cp,dp,b1,b2,c1,d11,d12,ndata] = hinffi_p(p,ncon);
np1 = ndata(1);
np2 = ndata(2);
nm1 = ndata(3);
nm2 = ndata(4);
np = max(size(a));
%
% form the submatrices f11,f12,f2 and h11,h12,h2
%
f1=f(1:nm1,:);
f2=f((nm1+1):(nm1+nm2),:);
%
% create t2 = d12'*d11
%
t2 = d12'*d11;
%
%  form controller k
%
 k = [ (t2*f1+f2) -t2];
 k = r12*k;
%
%