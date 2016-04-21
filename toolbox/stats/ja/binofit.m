% BINOFIT   二項データに対するパラメータ推定と信頼区間
%
% BINOFIT(X,N) は、ベクトル X で与えられたデータに対して、二項分布となる
% 確率を推定します。
% 
% [PHAT, PCI] = BINOFIT(X,N,ALPHA) は、与えられたデータに対して、最尤
% 推定値と 100(1-ALPHA)% の信頼区間を出力します。デフォルトでは、オプ
% ションパラメータの ALPHA = 0.05 は、95% の信頼区間に対応します。
% 
% 参考 : BINOCDF, BINOINV, BINOPDF, BINORND, BINOSTAT, MLE. 


%   B.A. Jones 7-27-94
%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:10:16 $
