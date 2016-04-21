% function [sysout,sig,sysfact] = srelbal(sys,tol)
%
% SYSTEM行列の状態空間モデルSYSの打切られた確率的平衡化実現を求めます。
% SYSのすべての固有値の実数部は、負でなければなりません。結果は、TOLより
% も大きいHankel特異値を残し、他を打切ります。出力引数SYSFACTは、SYS~*
% SYS = SYSFACT*SYSFACT~を満足する安定な最小位相システムです。TOLが省略
% されると、max(SIG(1)*1.0E-12,1.0E-16)に設定されます。SIGは、STRUNC(SYS
% OUT,K)を使って達成可能な相対誤差です。
%
% 参考: SFRWTBAL, SFRWTBLD, SNCFBAL, SRELBAL, SYSBAL, SRESID, TRUNC.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
