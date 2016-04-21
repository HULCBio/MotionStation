% RAYLFIT   Rayleigh分布しているデータに対するパラメータ推定と信頼区間
%
% RAYLFIT(DATA,ALPHA)は、ベクトルDATAで与えられたデータのRayleigh分布
% のパラメータの最尤推定を出力します。
%
% [PHAT, PCI] = RAYLFIT(DATA,ALPHA)は、データを与えて、MLEと 100(1-ALPHA)% 
% の信頼区間を出力します。デフォルトでは、オプションのパラメータ ALPHA は
% 0.05で、95%の信頼区間に対応します。
%
% 参考 : RAYLCDF, RAYLINV, RAYLPDF, RAYLRND, RAYLSTAT, MLE.


%   Tom Lane 11-10-99
%   Copyright 1993-2002 The MathWorks, Inc. 
% $Revision: 1.3 $  $Date: 2003/04/21 19:42:43 $
