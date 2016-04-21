% function [sysout,sig] = sysbal(sys,tol)
%
% SYSTEM行列の状態空間モデルの打切られた平衡化実現を計算します。Aの固有
% 値の実数部は、負でなければなりません。結果は、TOLよりも大きいHankel特
% 異値を残し、他を打切ります。TOLが省略されると、max(sig(1)*1.0E-12,1.
% 0E-16)に設定されます。
%
% 参考：HANKMR, REORDSYS, FRWTBAL, SFRWTBLD, SNCFBAL,
%       SRELBAL, SRESID, SVD, TRUNC.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
