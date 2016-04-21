% function syshat = sfrwtbld(sys,wt1,wt2)
%
% (WT1~)*SYS*(WT2~)の安定部を計算します。ルーチンは、つぎのようなSYSHAT
% を得るためにSFRWTBALと共に使われます。
%
%  >>[sys1,sig1] = sfrwtbal(sys,wt1,wt2);
%  >>sys1hat = strunc(sys1,k)
% または
%  >>sys1hat = hankmr(sys1,sig1,k)
%  >>syshat = sfrwtbld(sys1hat,wt1,wt2);
%
% 結果の誤差は、周波数応答の計算を直接使って評価されます。
%
% 参考: HANKMR, SDECOMP, SFRWTBAL, SNCFBAL, SRELBAL, SYSBAL, 
%       SRESID, TRUNC.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
