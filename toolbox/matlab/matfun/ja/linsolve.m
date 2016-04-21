%LINSOLVE 線形システム A*X=B を解きます
% X = LINSOLVE(A,B) は、A が 正方行列の場合、部分ピボットを用いる 
% LU 分解を使用し、そうでない場合、列ピボットを用いる QR 分解を使用
% して、線形システム A*X=B を解きます。A が、正方行列に対して ill 
% conditionedであり、矩形行列に対してランク落ちの場合、ワーニングが
% 表示されます。
%
% [X, R] = LINSOLVE(A,B) は、これらのワーニングを表示せず、正方行列に
% 対する A の条件数の逆数 R、および、A が 矩形行列の場合、A のランクを
% 出力します。
%   
% X = LINSOLVE(A,B,OPTS) は、構造体 OPTS により記述される、行列 A の特性
% により決定される適当なソルバを用いて線形システム A*X=B を解きます。
% OPTS のフィールドは、論理値を含む必要があります。
% すべてのフィールドの値は、デフォルトで false です。
% A がそのような特性をもつかどうかを確かめるテストは行われません。
%
% 以下は、使用可能なフィールド名とそれに対応する行列の特性の
% リストです。
%
% フィールド名 : 行列特性
% ------------------------------------------------
%  LT         : 下三角
%  UT         : 上三角
%  UHESS      : 上 Hessenberg
%  SYM        : 実対称 または 複素 Hermitian
%  POSDEF     : 正定
%  RECT       : 一般行列
%  TRANSA     : (共役) A の転置
%   
% つぎの表は、オプションの可能な組合せをすべて挙げています。
%
%  LT  UT  UHESS  SYM  POSDEF  RECT  TRANSA
%  ----------------------------------------
%  T   F   F      F    F       T/F   T/F
%  F   T   F      F    F       T/F   T/F
%  F   F   T      F    F       F     T/F
%  F   F   F      T    T       F     T/F
%  F   F   F      F    F       T/F   T/F
%
% 例題: 
%  A = triu(rand(5,3)); x = [1 1 1 0 0]'; b = A'*x;
%  y1 = (A')\b         
%  opts.UT = true; opts.TRANSA = true;
%  y2 = linsolve(A,b,opts)
%  
% 参考 MLDIVIDE, SLASH.

%   Copyright 1984-2003 The MathWorks, Inc. 
