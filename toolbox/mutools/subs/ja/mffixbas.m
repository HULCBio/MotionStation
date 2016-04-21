% function [outbasic,err] = fmfixbas(a,augbasic,sol,nvar,ncon)
%
%  *****  UNTESTED  *****
%
% 使われていない変数が基底にあるときに、可能な基底を固定します。FMFIXBAS
% は、条件数の良い基底を得るために、QR分解を使います。
%
% 参考: MFLINP.

%   $Revision: 1.6.2.2 $  $Date: 2004/03/10 21:31:16 $
%   Copyright 1991-2002 by MUSYN Inc. and The MathWorks, Inc. 
