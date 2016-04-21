% CORDEXCH   D-最適計画 (座標交換アルゴリズム)
%
% [SETTINGS, X] = CORDEXCH(NFACTORS,NRUNS,MODEL) は、要因NFACTORSに対して、
% NRUNSをもつD-最適計画を作成します。SETTINGS は、計画のための要因設定
% 行列であり、X は、(計画行列と呼ばれることがある)項の値の行列です。
% MODEL は、回帰モデルの次数をコントロールするオプションの引数です。
% MODEL は、つぎの文字列のいずれかになります。:
%
%     'linear'        定数、線形項をもつ(デフォルト)
%     'interaction'   定数、線形、クロス積の項をもつ
%     'quadratic'     相互項に、二乗項を加える
%     'purequadratic' 定数、線形、二乗項をもつ
%
% MODEL は、関数 X2FX で使用できる要素構成からなる行列の型でも設定できます。
%
% [SETTINGS, X] = CORDEXCH(...,'PARAM1',VALUE1,'PARAM2',VALUE2,...)は、
% パラメータ/値の組を使って、計画作成のコントロールをします。
% 使用可能なパラメータは、つぎのようになります。:
%
%      パラメータ   値
%      'display'    繰り返しカウンタ(デフォルト = 'on')の表示をコントロール
%                   するために、'on' 、あるいは、'off'のいずれかになります。
%      'init'       NRUNS×NFACTORS 行列としての初期計画
%                   (デフォルトは、ランダムに選択された点集合です)。
%      'maxiter'    繰り返しの最大回数 (デフォルト = 10)。
%
% 関数CORDEXCH は、座標交換アルゴリズムを使用して、 D-最適計画を行います。
% これは、出発点の計画を作成し、それから、この計画を使用して推定される係数
% の変動を減らすために、各計画点の各座標を交換することにより、繰り返します。
%
% 参考 : ROWEXCH, DAUGMENT, DCOVARY, X2FX.


%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:11:18 $ 
