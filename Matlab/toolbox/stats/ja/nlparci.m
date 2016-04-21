% NLPARCI   非線形モデルのパラメータの信頼区間
%
% CI = NLPARCI(BETA,RESID,J) は、解での残差の二乗和 RESID と ヤコビアン
% 行列 J を与えて、非線形最小二乗パラメータ推定 BETA での95%の信頼区間 
% CI を出力します。
% 
% 信頼区間の計算は、J の行数が BETA の長さより長い場合、有効です。
% 
% NLPARCI は、入力として、NLINFIT の出力を使います。
% 
% 例題：
%      [beta,resid,J]=nlinfit(input,output,'f',betainit);
%      ci = nlparci(beta,resid,J);
% 
% 参考 : NLINFIT.


%   Bradley Jones 1-28-94
%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:14:09 $
