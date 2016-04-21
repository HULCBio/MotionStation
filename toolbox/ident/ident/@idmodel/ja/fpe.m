% FPE は、モデルから最終予測誤差を抽出します。
%
%    FPE = FPE(Model)
%
% Model = あるIDMODEL (GREYBOX; IDARX; IDPOLY または IDSS)
%
%   FPE = 赤池の最終予測誤差 = V*(1+d/N)/(1-d/N)
% 
% ここで、V は損失関数、d は推定するパラメータの数、N は推定に使用するデ
% ータ数です。
%
% 参考:  AIC



%   Copyright 1986-2001 The MathWorks, Inc.
