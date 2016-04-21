% SMOOTH  データの平滑化
% Z = SMOOTH(Y) は、データ Y の平滑化を行います。
%
% Z = SMOOTH(Y,SPAN) は、使用する点数を設定する SPAN を使って、データ Y 
% を平滑化して、その結果を要素とする Z を出力します。
%
% Z = SMOOTH(Y,SPAN,METHOD) は、指定した METHOD を使って、データ Y を平
% 滑化します。デフォルトの手法は、移動平均です。使用可能な方法は、つぎ
% のものです。
%
%      'moving'   - 移動平均
%      'lowess'   - 局所的な重みを適用した最小二乗(線形近似)
%      'loess'    - 局所的な重みを適用した最小二乗(2次方程式近似)
%      'sgolay'   - Savitzky-Golay
%      'rlowess'  - 局所的な重みを適用した最小二乗のロバスト手法
%                   (線形近似)
%      'rloess'   - 局所的な重みを適用した最小二乗のロバスト手法
%                   (2次方程式近似)
%
% Z = SMOOTH(Y,METHOD) は、デフォルトの SPAN 値5を使います。
%
% Z = SMOOTH(Y,SPAN,'sgolay',DEGREE) と Z = SMOOTH(Y,'sgolay',DEGREE) 
% は、Savitzky-Golay 法で使われる多項式の次数を設定します。デフォルト
% の DEGREE は2で、DEGREE は、SPAN より小さく設定する必要があります。
%
% Z = SMOOTH(X,Y,...) は、X 座標を指定します。X が正でない場合、X 座標
% を必要とする手法では、X = 1:N を仮定しています。ここで、N は、Y の長
% さです。
%
% 注意：
%   1. X が一様分布しないように設定されている場合、デフォルトの手法は、
%     'lowess'です。
%
%   2. 移動平均と Savitzky-Golay 法では、SPAN は奇数である必要があります。
%      SPAN を偶数にすると、1引かれます。
%
%   3. SPAN が、Y の長さより長い場合、Y の長さになるようにします。
%
%   4. (ロバスト) lowess 法や (ロバスト) loess 法の場合、データセットで
%       の総数に対する割合で SPAN を設定することもできます。SPAN が1以
%       下の場合、百分率として扱います。
%
% 例題：
%
% Z = SMOOTH(Y) は、span = 5, X=1:length(Y) を使った移動平均を使います。
%
% Z = SMOOTH(Y,7) は、span = 7, X=1:length(Y) を使った移動平均を使います。 
%
% Z = SMOOTH(Y,'sgolay') は、DEGREE=2, SPAN = 5, X = 1:length(Y) を使った
% Savitzky-Golay 法を使います。
%
% Z = SMOOTH(X,Y,'lowess') は、SPAN = 5 を使った lowess を使います。
%
% Z = SMOOTH(X,Y,SPAN,'rloess') は、ロバスト loess 法を使います。
%
% Z = SMOOTH(X,Y) は、X が、等間隔分布をしない場合、span = 5 を使った 
% lowess 法を使います。
%
% Z = SMOOTH(X,Y,8,'sgolay') は、span = 7 (8 は、偶数なので1を引いたも
% の)を使った Savitzky-Golay 法を使います。
%
% Z = SMOOTH(X,Y,0.3,'loess') は、データの 30% を span とする loess 法を
% 使います。span = ceil(0.3*length(Y))。
%
% 参考   SPLINE

% $Revision: 1.2.4.1 $
%   Copyright 2001-2004 The MathWorks, Inc.
