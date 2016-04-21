% NLPREDCI   非線形最小二乗予測の信頼区間
%
% [YPRED, DELTA] = NLPREDCI(FUN,X,BETA,RESID,J) は、予測値(YPRED)と、
% 入力値 X の関数 F に対する95%の信頼区間の半値幅(half-widths)(DELTA)を
% 出力します。この関数を使用する前に、推定された係数値 BETA と、残差 
% RESID、ヤコビアン J を取得し、非線形最小二乗によって FUN に近似する
% ために、NLINFIT を使用してください。
%
% [YPRED, DELTA] = NLPREDCI(FUN,X,BETA,RESID,J,ALPHA,SIMOPT,PREDOPT) は、
% 信頼限界をコントロールします。ALPHA は、信頼レベルを 100(1-ALPHA)% 
% として定義され、0.05がデフォルトです。SIMOPT は、同期である信頼限界
% に対して 'on'、非同期な信頼限界に対して 'off'(デフォルト) です。
% PREDOPT は、X で推定されたカーブ(関数値)に対する信頼区間には 'curve'
% (デフォルト)、または、X の新たな観測に対する信頼区間には、'observation'
% を設定します。
%
% 信頼区間の計算は、RESID の長さが BETA の長さよりも長く、J がフル列
% ランクの場合、システムに対する信頼区間の計算は有効です。
% 
% 例題:
%      [beta,resid,J]  = nlinfit(input,output,@f,betainit);
%      [yp, ci] = nlpredci(@f,newx,beta,resid,J);
%
% 参考 : NLINFIT, NLPARCI, NLINTOOL.


%   Bradley Jones 1-28-94
%   Copyright 1993-2002 The MathWorks, Inc. 
% $Revision: 1.6 $  $Date: 2003/02/12 17:14:12 $
