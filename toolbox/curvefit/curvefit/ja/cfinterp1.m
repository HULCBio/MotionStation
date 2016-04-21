% CFINTERP1 1-次元内挿(テーブルルックアップ)
% YI = CFINTERP1(X,Y,XI) は、ベクトル XI で設定されている点に対して、関
% 数 Y の値を基にして、YI を内挿を使って求めます。ベクトル X は、データ 
% Y が与えられている点を指定します。Y が行列の場合、内挿は、Y の各列に対
% して行われ、YI は、length(XI) 行 size(Y,2) 列の行列になります。
%
% YI = CFINTERP1(Y,XI) は、X = 1:N を仮定しています。ここで、N は、Y が
% ベクトルの場合、length(Y) で、行列の場合、SIZE(Y,1)です。
%
% 内挿は、"テーブルルックアップ"と同様な演算を行います。"テーブルルック
% アップ"の項に記述されているように、"テーブル"は [X,Y] で、CFINTERP1 は、
% X の中から XI の要素を探し、その位置をベースに、Y の要素群の中で内挿さ
% れた値 YI を出力します。
%
% YI = CFINTERP1(X,Y,XI,'method') は、指定した 'method'を使います。
% デフォルトでは、線形内挿です。利用可能な方法は、つぎのものです。
%
%     'nearest'  - 最近傍内挿
%     'linear'   - 線形内挿
%     'spline'   - 区分的なキュービックスプライン内挿(SPLINE)
%     'pchip'    - 区分的なキュービックエルミート内挿(PCHIP)
%     'cubic'    - 'pchip' と同じ
%     'v5cubic'  - MATLAB 5 で使われているキュービック内挿で、外挿ができ
%                  ません。そして、X が等間隔でない場合、'spline'を使って
%                  ください。
%
% YI = CFINTERP1(Y,XI,'method') は、X = 1:N を仮定しています。ここで、
% N は、Y がベクトルの場合、length(Y) で、行列の場合、SIZE(Y,1) です。
%
% YI = CFINTERP1(X,Y,XI,'method','extrap') は、X で設定した範囲外のXI の
% 要素に対しては、指定した方法を使って、外挿します。一方、YI = CFINTERP1
% (X,Y,XI,'method',EXTRAPVAL) は、EXTRAPVAL を使って、これらの値を置き換
% えます。NaN と 0 は、EXTRAVAL に、よく使われます。4つの入力引数をもつデ
% フォルトの外挿の挙動は、'spline'と'pchip'に対して、'extrap'で、他の方法
% については、EXTRAPVAL = NaN です。
%
% 例題として、粗いデータについて正弦波を作成し、その間を埋める細かいデー
% タを使って、内挿を行います。
% 
%       x = 0:10; y = sin(x); xi = 0:.25:10;
%       yi = cfinterp1(x,y,xi); plot(x,y,'o',xi,yi)
%
% CFINTERP1 は、内挿された関数の pp-型を出力する機能をもっています。
% このシンタックスは、つぎのものです。
%
%   F = CFINTERP1(X,Y,'method','pp') 
%
% 'pp' は、YI = CFINTERP1(Y,XI,'method');と区別できる必要があります。
%
% F = CFINTERP1(Y,'method') では、'pp' は必要ありません。ここで、X は与
% えられていません。X は、1:length(Y) と仮定しています。
%
% F = CFINTERP1(Y) では、X も method も与えられていません。X は、
% 1:length(Y) で、method は、'linear' と仮定しています。
%
% 参考   INTERP1Q, INTERPFT, SPLINE, INTERP2, INTERP3, INTERPN.

% $Revision: 1.2.4.1 $
%   Copyright 2001-2004 The MathWorks, Inc.
