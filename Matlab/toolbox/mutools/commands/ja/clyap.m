% function [X,resid] = clyap(A,C))
%
% Lyapunov方程式A'*X + X*A + C'C = 0を解きます。CLYAPは、コレスキ因子を
% 使って、Lyapunov方程式を解くために、サブルーチンSJH6を呼び出します。
% RESIDは、残差の誤差のノルムです。%	norm(A'*X + X*A + C'C)
%
% 参考: RIC_EIG, RIC_SCHR, SJH6, SYLV.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
