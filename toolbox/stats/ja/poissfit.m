% POISSFIT   Poisson データに対するパラメータ推定と信頼区間
% 
% POISSFIT(X) は、X のデータを与えた Poisson 分布のパラメータ推定を
% 計算します。
% 
% [LAMBDAHAT, LAMBDACI] = POISSFIT(X,ALPHA) は、与えられたデータの最尤
% 推定値と 100(1-ALPHA)% の信頼区間を計算します。デフォルトでは、
% ALPHA = 0.05 で、95% の信頼区間に対応します。
% 
% 参考 : POISSCDF, POISSINV, POISSPDF, POISSRND, POISSTAT, MLE. 


%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:14:47 $
