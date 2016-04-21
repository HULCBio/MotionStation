% QUADL  適応 Lobatto 求積法を使って、数値的な積分を行います
% 
% Q = QUADL(FUN,A,B) は、A から B まで、高次の再帰適応求積法を使って、
% 1.e-6 の誤差内で、関数 FUN の積分を近似します。関数 Y = FUN(X) は、
% ベクトル引数 X を入力し、結果のベクトル Y を出力します。ベクトル 
% Y は、X の各要素での計算した被積分値を要素にしています。  
%
% Q = QUADL(FUN,A,B,TOL) は、デフォルトの1e-6 の代わりに TOL を絶対
% 誤差許容範囲として使います。TOL の値を大きくすると、関数の計算回数
% が減り、高速になりますが、精度は低下します。
%
% [Q,FCNT] = QUADL(...) は、関数計算の回数を出力します。
%
% 非ゼロの TRACE を使った QUADL(FUN,A,B,TOL,TRACE) は、リカーシブ計算
% の間に、[fcnt a b-a Q] の値を示します。
%
% QUADL(FUN,A,B,TOL,TRACE,P1,P2,...) は、付加的な引数 P1, P2, ... を関数
% FUN に直接渡し、FUN(X,P1,P2,...) とします。TOL や TRACE に対して、空行列
% を渡すことは、デフォルト値を使うことを意味しています。
%
% ベクトル引数と共に計算できるように、FUN の定義の中で、配列演算子 .*, 
% ./, .^ を使います。
%
% 関数 QUAD は、低精度、または、スムーズでない被積分関数に、より効率的に
% 働きます。
%
% 例題:
%       FUN は、以下のように設定することができます。
%
%       インラインオブジェクト:
%          F = inline('1./(x.^3-2*x-5)');
%          Q = quadl(F,0,2);
%
%       関数ハンドル:
%          Q = quadl(@myfun,0,2);
%          ここで、myfun.m はM-ファイルです。
%             function y = myfun(x)
%             y = 1./(x.^3-2*x-5);
%
% 参考 ： QUAD, DBLQUAD, TRIPLEQUAD, INLINE, @.


%   Based on "adaptlob" by Walter Gautschi.
%   Ref: W. Gander and W. Gautschi, "Adaptive Quadrature Revisited", 1998.
%   http://www.inf.ethz.ch/personal/gander
%   Copyright 1984-2004 The MathWorks, Inc. 
