%PCHIP  区分的キュービックエルミート内挿多項式の計算
% PP = PCHIP(X,Y) は、位置 X での Y の値に対する、shape-preserving の
% 区分的キュービックエルミート内挿の区分的多項式を与えます。これは、後で、
% PPVAL とスプラインユーティリティ UNMKPP で使用できます。
% X は、ベクトルでなければなりません。
% Y がベクトルの場合、 Y(j) は、 X(j) で一致する値がとられます。従って、
% Y は、X と同じ長さである必要があります。
% Y が行列 または ND 配列の場合、Y(:,...,:,j) は、X(j) で一致する値として
% とられ、そのため、Y の最後の次元は length(X) に等しくなる必要があります。
%   
% YY = PCHIP(X,Y,XX) は、YY = PPVAL(PCHIP(X,Y),XX) と同じです。従って、
% YY に、XX での補間の値を与えます。
%
% PCHIP では、内挿関数 p(x) がつぎの条件を満足します。
% 各サブ区間 X(k) <= x <= X(k+1) 上で、p(x) は、両端点で与えられた値とある
% 勾配に対するキュービックエルミート内挿です。そのため、p(x) は Y を内挿し、
% すなわち、p(X(j)) = Y(:,j) で、1階微分 Dp(x) は連続ですが、D^2p(x) は多分
% 連続ではありません。これは、X(j)でジャンプする可能性があります。 
% X(j) での勾配は、p(x) が"形を保存"したり単調さをもつ"ように選択されます。
% これは、データが単調である区間で、p(x) になることを意味しています。すなわち、
% データが極値をもつ点で p(x) になります。
%
% PCHIP を SPLINE と比較します。
% SPLINE で与えられる関数 s(x) は、X(j) での勾配が D^2s(x) が連続になる
% ように選択する部分以外は、全く同じ方法で作成されます。これは、つぎの
% ような影響を示します。
% SPLINE  は、より平滑化されます。すなわち、D^2s(x) は連続です。
% SPLINE は、データが平滑化関数の値の場合は、より正確になります。
% PCHIP は、データが平滑化されていない場合は、オーバーシュートはなく、
% 振動しません。
% PCHIP は、設定が簡単です。
% 2つの方法は、計算量は同じです。
%
% 例題:
%
%     x = -3:3;
%     y = [-1 -1 -1 0 1 1 1];
%     t = -3:.01:3;
%     plot(x,y,'o',t,[pchip(x,y,t); spline(x,y,t)])
%     legend('data','pchip','spline',4)
%
% 入力 x, y, xx のサポートクラス
%      float: double, single
%
% 参考 INTERP1, SPLINE, PPVAL, UNMKPP.

% 参考文献:
%   F. N. Fritsch and R. E. Carlson, "Monotone Piecewise Cubic
%   Interpolation", SIAM J. Numerical Analysis 17, 1980, 238-246.
%   David Kahaner, Cleve Moler and Stephen Nash, Numerical Methods
%   and Software, Prentice Hall, 1988.
%
%   Copyright 1984-2004 The MathWorks, Inc.
