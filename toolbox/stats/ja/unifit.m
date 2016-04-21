% UNIFIT   一様分布データに対するパラメータ推定
% 
% UNIFIT(X,ALPHA) は、ベクトル X のデータを与えて、一様分布のパラメータの
% 最尤推定値を計算します。 
% 
% [AHAT,BHAT,ACI,BCI] = UNIFIT(X,ALPHA) は、与えられたデータの最尤推定値と 
% 100(1-ALPHA)% の信頼区間を計算します。デフォルトでは、ALPHA =0.05 で、
% 95% の信頼区間に対応します。
%
% 参考 : UNIFCDF, UNIFINV, UNIFPDF, UNIFRND, UNIFSTAT, MLE. 


%   B.A. Jones 1-30-95
%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:09:43 $
