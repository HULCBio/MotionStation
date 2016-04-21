% function [outbasic,err] = fmfixbas(a,augbasic,sol,nvar,ncon)
%
% 使われていない変数が基底にあるときに、可能な基底を固定します。条件数の
% 良い基底を得るために、QR分解を使います。
%% 236 %%%%%%%%%%%%%%%

%   $Revision: 1.6.2.2 $  $Date: 2004/03/10 21:30:26 $
%   Copyright 1991-2002 by MUSYN Inc. and The MathWorks, Inc. 
