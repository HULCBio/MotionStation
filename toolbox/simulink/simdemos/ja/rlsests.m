% RLSESTS   システム同定を行うS-function
%
% このM-ファイルは、Simulink S-functionブロックで利用するために設計され
% ています。
% 指数データ重み付き逐次最小二乗パラメータ推定アルゴリズムを利用して、
% パラメータ推定を行います。
%   
% 入力引数は、以下のとおりです。
%
%     nstates:        状態ベクトル内の状態数。
%     lambda:         指数データ重みファクタ。
%     dt:             サンプル点の間隔(秒)。
%
% RLS推定子は、つぎの方程式により定義されます。
% 
%    theta[k]  =  theta[k-1] + ....
% 
%
%      1      P(k-2) * phi(k-1) * [y(k) - phi(k-1)'theta(k-1)]
%   -------  * -------------------------------------------------
%   lambda         lambda + phi(k-1)' * P(k-2) *phi(k-1)
%
%   	         1       P(k-2) * phi(k-1) * phi(k-1)' * P(k-2)
%     P(k-1)  =  ------ * ----------------------------------------
%   	       lambda    lambda + phi(k-1)' * P(k-2) * phi(k-1)
%
%   ここで:
%
%     theta:	推定パラメータ
%     phi:		状態ベクトル
%     P:		共分散行列
%     lambda:	指数データ重みファクタ
%
%
% 参考 : SFUNTMPL., "Adaptive Filtering, Prediction, and Control",
%        G. C. Goodwin & K. S. Sin.


%   Copyright 1990-2002 The MathWorks, Inc.
