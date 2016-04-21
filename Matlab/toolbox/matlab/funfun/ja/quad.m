% QUAD   数値積分, 適応Simpson求積
%
% Q = QUAD(FUN,A,B) は、適応リカーシブなSimpson法を使って、相対誤
% 差が1e-3以内になるように、F(X) の積分を A から B まで近似します。
% 関数 Y = FUN(X) は、ベクトル引数X を受け入れ、X の要素において計算
% された被積分関数である結果のベクトル Y を出力します。  
%
% Q = QUAD(FUN,A,B,TOL) は、デフォルトである1.e-6 の代わりに絶対許容
% 誤差 TOL を利用します。TOL を大きい値にすると、関数計算の回数が減り、
% 計算は速くなりますが、結果の精度は低くなります。MATLAB 5.3 の関数
% QUAD は、信頼性の低いアルゴリズムを利用しており、デフォルトの許容誤
% 差は 1.e-3 でした。
%
% [Q,FCNT] = QUAD(...) は、関数の計算回数を出力します。
%
% QUAD(FUN,A,B,TOL,TRACE) は、TRACE がゼロでない場合は、リカーシブな
% 作業を行っている間、[fcnt a b-a Q] の値を示します。
%
% QUAD(FUN,A,B,TOL,TRACE,P1,P2,...) は、FUN(X,P1,P2,...) に引数 P1, P2, ...
% を直接渡します。TOL や TRACE のデフォルト値を使うためには、空行列
% ([])を渡してください。
%
% ベクトル引数を使って計算できるように、FUN の定義の中で、配列演算子 .*, 
% ./, .^ を使います。
%
% 関数 QUADL は、高精度とスムーズな被積分関数により、効率的に実行される
% 場合があります。
%
% 例題:
%       FUN は、以下のように指定することができます。
%
%       インラインオブジェクト:
%          F = inline('1./(x.^3-2*x-5)');
%          Q = quad(F,0,2);
%
%       関数ハンドル:
%          Q = quad(@myfun,0,2);
%          where myfun.m is an M-file:
%             function y = myfun(x)
%             y = 1./(x.^3-2*x-5);
%
% 参考 QUADV, QUADL, DBLQUAD, TRIPLEQUAD, INLINE, @.

%   Based on "adaptsim" by Walter Gander.  
%   Ref: W. Gander and W. Gautschi, "Adaptive Quadrature Revisited", 1998.
%   http://www.inf.ethz.ch/personal/gander
%   Copyright 1984-2004 The MathWorks, Inc. 
