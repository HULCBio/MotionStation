% MLE   最尤推定
%
% PHAT = MLE(DIST,DATA) は、ベクトル DATA 内のサンプルを使って、DIST で
% 設定されている分布に対する最尤推定値を出力します。
%  
% [PHAT, PCI] = MLE(DIST,DATA,ALPHA,P1) は、与えられたデータの最尤推定値と
% 100(1-ALPHA)%の信頼区間を出力します。ALPHA はオプションです。デフォルト
% では、ALPHA = 0.05で、95%の信頼区間に対応します。P1 は、二項分布のみで
% 使われるもので、試行回数を与えるオプション引数です。
%
% DIST は、以下のいずれかです。:
%      'beta'
%      'bernoulli'
%      'bino' または 'binomial'
%      'ev' または 'extreme value'
%      'exp' または 'exponential'
%      'gam' または 'gamma'
%      'geo' または 'geometric'
%      'norm' または 'normal'
%      'poiss' または 'poisson'
%      'rayl' または 'rayleigh'
%      'unid' または 'discrete uniform'
%      'unif' または 'uniform'
%      'wbl' または 'weibull'
%
% 参考 : BETAFIT, BINOFIT, EXPFIT, GAMFIT, NORMFIT, POISSFIT,
%        RAYLFIT, WBLFIT, UNIFIT.


%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:06:27 $
