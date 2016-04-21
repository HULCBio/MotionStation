% WEIBFIT   Weibullデータに対するパラメータ推定と信頼区間
% 
% WEIBFIT(DATA,ALPHA) は、ベクトル DATA のデータを与えて、Weibull分布の
% パラメータの最尤推定値を計算します。 
% 
% [PHAT, PCI] = WEIBFIT(DATA,ALPHA) は、与えられたデータの最尤推定値と
% 100(1-ALPHA)% の信頼区間を計算します。デフォルトでは、ALPHA =0.05 で、
% 95% の信頼区間に対応します。
%
% 参考 : WEIBCDF, WEIBINV, WEIBPDF, WEIBPLOT, WEIBRND, WEIBSTAT, MLE. 


%   Copyright 1993-2003 The MathWorks, Inc. 
% $Revision: 1.6 $  $Date: 2003/02/12 17:16:10 $
