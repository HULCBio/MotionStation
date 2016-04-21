% function [outbasic,err] = fmfixbas(a,augbasic,sol,nvar,ncon)
%
%  *****  UNTESTED  *****
%
% Fix a feasible basis when the slack variables are in the basis.
% FMFIXBAS uses a QR decomposition to get a well-conditioned basis.
%
% See Also: MFLINP.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [outbasic,err] = mffixbas(a,augbasic,sol,nvar,ncon)

 err = 0;
 outbasic=augbasic;
 trouble = find(outbasic>nvar);
 if norm(sol(trouble))>1e-12
   err = 1;
 else
   ok = find(outbasic<=nvar);
   oknotused = comple(outbasic(ok),nvar);%keyboard
   [q1,r1,e1]=qr(a(:,outbasic(ok)));
   [q2,r2,e2]=qr(q1(:,length(ok)+1:ncon)'*a(:,oknotused));
   for i=1:length(trouble)
      outbasic(trouble(i))=oknotused(find(e2(:,i)));
   end
 end
%keyboard
%
%