% ROBUSTFIT   ロバスト線形回帰
%
% B = ROBUSTFIT(X,Y)は、線形モデル Y=Xb の推定のためにロバスト回帰を実行
% することで得られた回帰係数のベクトル B を返します(X はnxpの行列、Y は
% nx1の観測ベクトルです)。このアルゴリズムは、bisquare重み関数として繰り
% 返し重みを適用された最小二乗を用います。
%
% B = ROBUSTFIT(X,Y,'WFUN',TUNE,'CONST')は、重み関数 'WFUN' とtuning定数
% TUNE を使います。'WFUN' は、以下のいずれかになります。
%     'andrews'、'bisquare'、'cauchy'、'fair'、'huber'、
%     'logistic'、'talwar'、'welsch'
% 代わりに、'WFUN' は、入力として 残差のベクトルをとり、出力として重み
% のベクトルを生成する関数をかくことができます。残差は、重み関数をコール
% する前に、tuning定数と誤差項の標準偏差によってスケールされます。
% 'WFUN' は、@(例えば、@myfun)を使用したり、あるいは、インライン関数と
% して指定することができます。TUNE は、重みを計算する前に残差のベクトル
% で分割されるtuning定数で、'WFUN' が関数として指定されたときに必要に
% なります。'CONST' は、定数項を加えるために 'on' (デフォルト)とするか、
% あるいは、定数項を省略するために 'off' とすることができます。 
% 定数項の係数は、B の最初の要素です(X の行列内に直接1つの列を入力しないで
% ください)。
%
% [B,STATS] = ROBUSTFIT(...)はまた、つぎのフィールドをもつSTATS構造体を
% 返します。
%       stats.ols_s     最小二乗フィットからのsigma評価(rmse) 
%       stats.robust_s  sigmaのロバスト評価 
%       stats.mad_s     sigmaのMAD評価。反復フィッティングの間、残差を
%                       スケーリングするために使用されます。 
%       stats.s         sigmaの最終評価。robust_sとols_sとrobust_sの重み
%                       平均の大きい方の値
%       stats.se        推定係数の標準誤差 
%       stats.t         stats.seとbの比 
%       stats.p         stats.tに対するp値 
%       stats.coeffcorr 推定係数の相関の評価 
%       stats.w         ロバストフィッテイングの重みベクトル 
%       stats.h         最小二乗フィッティングに対するリべレッジベクトル
%       stats.dfe       誤差に対する自由度 
%       stats.R         行列XのQR分解のR因子 
% ROBUSTFIT は、係数評価の分散共分散行列を V=inv(X'*X)*STATS.S^2 と評価し
% ます。標準誤差と相関は、V から導かれます。


%   Tom Lane 2-11-2000
%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.2 $  $Date: 2003/02/12 17:07:03 $
