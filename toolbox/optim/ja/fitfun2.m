% FITFUN2   データの関数近似による誤差を出力するための DATDEMO により使用
%
% FITFUN2 は、DATADEMO で使用されます。FITFUN2(lam,Data,Plothandle) は、
% データとlam のカレントの関数値との間の誤差を出力します。FITFUN2 は、
% n 個の線形パラメータと n 個の非線形パラメータをもち、つぎの形式の関数
% を仮定しています。
%
%     y =  c(1)*exp(-lam(1)*t) + ... + c(n)*exp(-lam(n)*t)
%
% 線形パラメータ c を解くには、A のj 列目が、exp(-lam(j)*t) (tはベクトル)
% となる行列を定義し、線形最小二乗法を使って、A*c = y を c について解きます。


%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2003/05/01 13:01:41 $
